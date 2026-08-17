import '../bindings/native_bindings.dart';
import '../utils/logger.dart';

class NativeBridge {
  final NativeBindings _bindings = NativeBindings();

  bool get isNativeAvailable => _bindings.isLoaded;

  Future<String> loadModel(String modelPath) async {
    Logger.log('NativeBridge: Requesting model load from $modelPath');
    if (!_bindings.isLoaded) {
      return 'MockHandle_LoadedSuccessfully';
    }
    // FFI call placeholder when native library is built in Phase 2
    return 'NativeHandle_Success';
  }

  Future<void> unloadModel() async {
    Logger.log('NativeBridge: Unloading model');
  }

  Future<String> forwardPass({
    required String imagePath,
    required String textPrompt,
    required bool isTraining,
  }) async {
    Logger.log('NativeBridge: Forward pass for prompt "$textPrompt" (training: $isTraining)');
    return 'ForwardPass_Success';
  }

  Future<void> backwardPass() async {
    Logger.log('NativeBridge: Backward pass executed');
  }
}
