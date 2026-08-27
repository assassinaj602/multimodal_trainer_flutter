import 'package:sate_ai/sate_ai.dart';
import 'multimodal_sate_adapter.dart';
import 'native_bridge.dart';

/// Service orchestrating SATE AI fault injection and stress validation for the
/// on-device Multimodal VLM training pipeline.
class ValidationService {
  final NativeBridge nativeBridge;

  ValidationService(this.nativeBridge);

  /// Runs comprehensive pre-training stress validation using SATE AI injectors.
  Future<StressReport> runPreTrainingValidation({
    required String modelPath,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final adapter = MultimodalSateAdapter(
      nativeBridge: nativeBridge,
      modelPath: modelPath,
      modelId: 'qwen3.5-2b-pretraining',
    );

    final injectors = <FaultInjector>[
      MemoryPressureInjector(model: adapter, limitMb: 150),
      MalformedInputInjector(),
      QuantizationDriftInjector(
        model: adapter,
        driftFactor: 0.05,
        degradationThreshold: 0.35,
      ),
      LatencyInjector(
        model: adapter,
        baseDelayMs: 50,
        incrementMs: 25,
      ),
      GpuMemoryPressureInjector(limitMb: 100),
    ];

    return await SateAI.stress(
      model: adapter,
      injectors: injectors,
      timeout: timeout,
    );
  }

  /// Runs post-training verification using SATE AI to ensure model stability and confidence.
  Future<StressReport> runPostTrainingValidation({
    required String modelPath,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final adapter = MultimodalSateAdapter(
      nativeBridge: nativeBridge,
      modelPath: modelPath,
      modelId: 'qwen3.5-2b-posttraining',
    );

    final injectors = <FaultInjector>[
      MemoryPressureInjector(model: adapter, limitMb: 120),
      ConfidenceThresholdInjector(model: adapter, threshold: 0.5),
      ThermalThrottleInjector(
        model: adapter,
        maxTemperature: 75,
        temperatureStep: 5,
      ),
      GpuMemoryPressureInjector(limitMb: 100),
    ];

    return await SateAI.stress(
      model: adapter,
      injectors: injectors,
      timeout: timeout,
    );
  }
}
