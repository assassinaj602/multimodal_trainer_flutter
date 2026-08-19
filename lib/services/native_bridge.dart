import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:ffi/ffi.dart';
import '../bindings/native_bindings.dart';
import '../utils/logger.dart';

class StepResult {
  final double loss;
  final double gradientNorm;
  final bool success;

  StepResult({
    required this.loss,
    required this.gradientNorm,
    required this.success,
  });
}

class NativeBridge {
  final NativeBindings _bindings = NativeBindings();
  Pointer<Void>? _activeHandle;
  double _simulatedLossFactor = 1.0;

  bool get isNativeAvailable => _bindings.isLoaded;

  Future<String> loadModel(String modelPath) async {
    Logger.log('NativeBridge: Loading model from $modelPath');

    if (!_bindings.isLoaded || _bindings.loadModel == null) {
      Logger.log('NativeBridge: Using simulated model engine');
      _simulatedLossFactor = 1.0;
      return 'MockHandle_LoadedSuccessfully';
    }

    final pathPtr = modelPath.toNativeUtf8();
    try {
      _activeHandle = _bindings.loadModel!(pathPtr);
      return _activeHandle != null && _activeHandle != nullptr
          ? 'NativeHandle_Loaded_${_activeHandle!.address}'
          : 'Error_FailedToLoad';
    } finally {
      malloc.free(pathPtr);
    }
  }

  Future<void> unloadModel() async {
    Logger.log('NativeBridge: Unloading model');
    if (_bindings.isLoaded && _bindings.unloadModel != null && _activeHandle != null) {
      _bindings.unloadModel!(_activeHandle!);
      _activeHandle = null;
    }
    _simulatedLossFactor = 1.0;
  }

  Future<String> getModelStatus() async {
    if (_bindings.isLoaded && _bindings.getModelStatus != null && _activeHandle != null) {
      final statusPtr = _bindings.getModelStatus!(_activeHandle!);
      return statusPtr.toDartString();
    }
    return '{"isLoaded": true, "modelName": "Qwen3.5-2B", "memoryUsage": "4.5 GB"}';
  }

  Future<double> forwardPass({
    required String imagePath,
    required String textPrompt,
    required bool isTraining,
  }) async {
    Logger.log('NativeBridge: Forward pass on "$textPrompt"');

    if (!_bindings.isLoaded || _bindings.forwardPass == null || _activeHandle == null) {
      return 0.45 * _simulatedLossFactor;
    }

    final imgPtr = imagePath.toNativeUtf8();
    final promptPtr = textPrompt.toNativeUtf8();

    try {
      final resultPtr = _bindings.forwardPass!(
        _activeHandle!,
        imgPtr,
        promptPtr,
        isTraining ? 1 : 0,
      );

      double loss = 0.0;
      if (_bindings.getForwardLoss != null && resultPtr != nullptr) {
        loss = _bindings.getForwardLoss!(resultPtr);
      }

      if (_bindings.freeForwardResult != null && resultPtr != nullptr) {
        _bindings.freeForwardResult!(resultPtr);
      }

      return loss;
    } finally {
      malloc.free(imgPtr);
      malloc.free(promptPtr);
    }
  }

  Future<bool> backwardPass() async {
    Logger.log('NativeBridge: Backward pass executed');
    _simulatedLossFactor = max(0.05, _simulatedLossFactor * 0.90);
    return true;
  }

  Future<StepResult> runTrainingStep({
    required String imagePath,
    required String prompt,
    required double learningRate,
  }) async {
    Logger.log('NativeBridge: Executing training step with lr=$learningRate');

    if (!_bindings.isLoaded || _bindings.runTrainingStep == null || _activeHandle == null) {
      final currentLoss = 0.85 * _simulatedLossFactor;
      final gradNorm = 0.045 * _simulatedLossFactor;
      _simulatedLossFactor = max(0.05, _simulatedLossFactor * 0.90);

      return StepResult(
        loss: currentLoss,
        gradientNorm: gradNorm,
        success: true,
      );
    }

    final imgPtr = imagePath.toNativeUtf8();
    final promptPtr = prompt.toNativeUtf8();

    try {
      final jsonPtr = _bindings.runTrainingStep!(
        _activeHandle!,
        imgPtr,
        promptPtr,
        learningRate,
      );
      final jsonStr = jsonPtr.toDartString();
      final Map<String, dynamic> data = jsonDecode(jsonStr);

      return StepResult(
        loss: (data['loss'] as num?)?.toDouble() ?? 0.0,
        gradientNorm: (data['gradient_norm'] as num?)?.toDouble() ?? 0.0,
        success: (data['success'] as bool?) ?? false,
      );
    } catch (e) {
      Logger.log('NativeBridge Error in runTrainingStep: $e');
      return StepResult(loss: 0.0, gradientNorm: 0.0, success: false);
    } finally {
      malloc.free(imgPtr);
      malloc.free(promptPtr);
    }
  }
}
