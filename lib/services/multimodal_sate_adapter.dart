import 'package:sate_ai/sate_ai.dart';
import 'native_bridge.dart';

/// Multimodal AIModelAdapter connecting SATE AI fault injection framework
/// to the MobileFineTuner native bridge and Qwen3.5-2B runtime.
class MultimodalSateAdapter implements AIModelAdapter {
  final NativeBridge nativeBridge;
  final String modelPath;

  @override
  final String modelId;

  double _currentMemoryMB = 0;
  double _currentGPUMemoryMB = 0;
  bool _isDegraded = false;
  bool _isHealthy = true;

  MultimodalSateAdapter({
    required this.nativeBridge,
    required this.modelPath,
    this.modelId = 'qwen3.5-2b-multimodal',
  });

  @override
  double get currentMemoryMB => _currentMemoryMB;

  @override
  double get currentGPUMemoryMB => _currentGPUMemoryMB;

  @override
  bool get isDegraded => _isDegraded;

  @override
  Future<AIOutput> runInference(AIInput input) async {
    if (_isDegraded) {
      throw const AIInferenceError(
        'MultimodalSateAdapter is in degraded state. Call reset() before retrying.',
      );
    }

    final stopwatch = Stopwatch()..start();

    try {
      final prompt = input.text ?? 'Describe image features';

      // Execute single step inference/forward check via NativeBridge
      final stepResult = await nativeBridge.runTrainingStep(
        imagePath: 'assets/sample_data/sample.jpg',
        prompt: prompt,
        learningRate: 0.001,
      );

      stopwatch.stop();

      final confidence = (0.98 - (_currentMemoryMB / 800.0)).clamp(0.1, 1.0);

      return AIOutput(
        text: 'Qwen3.5-2B Multimodal Response for: "$prompt" (loss: ${stepResult.loss.toStringAsFixed(4)})',
        inferenceTime: stopwatch.elapsed,
        confidence: confidence,
        metadata: {
          'runtime': 'MobileFineTuner (libmtmd + llama.cpp)',
          'modelId': modelId,
          'modelPath': modelPath,
          'loss': stepResult.loss,
          'gradientNorm': stepResult.gradientNorm,
          'memoryMB': _currentMemoryMB,
          'gpuMemoryMB': _currentGPUMemoryMB,
        },
      );
    } catch (e, st) {
      stopwatch.stop();
      throw AIInferenceError('Multimodal inference error: $e', st);
    }
  }

  @override
  Future<void> simulateMemoryPressure(int mb) async {
    _currentMemoryMB += mb.toDouble();
    if (_currentMemoryMB > 250) {
      _isDegraded = true;
      _isHealthy = false;
    }
    await Future.delayed(const Duration(milliseconds: 5));
  }

  @override
  Future<void> simulateGPUMemoryPressure(int mb) async {
    _currentGPUMemoryMB += mb.toDouble();
    if (_currentGPUMemoryMB > 250) {
      _isDegraded = true;
      _isHealthy = false;
    }
    await Future.delayed(const Duration(milliseconds: 5));
  }

  @override
  Future<void> reset() async {
    _currentMemoryMB = 0;
    _currentGPUMemoryMB = 0;
    _isDegraded = false;
    _isHealthy = true;
    await Future.delayed(const Duration(milliseconds: 5));
  }

  @override
  Future<bool> isHealthy() async {
    return _isHealthy &&
        !_isDegraded &&
        _currentMemoryMB < 250 &&
        _currentGPUMemoryMB < 250;
  }
}
