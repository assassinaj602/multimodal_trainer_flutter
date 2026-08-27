import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_trainer/services/multimodal_sate_adapter.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';
import 'package:multimodal_trainer/services/validation_service.dart';
import 'package:sate_ai/sate_ai.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SATE AI Multimodal Validation & Fault Injection Tests', () {
    late NativeBridge nativeBridge;
    late ValidationService validationService;

    setUp(() {
      nativeBridge = NativeBridge();
      validationService = ValidationService(nativeBridge);
    });

    test('MultimodalSateAdapter implements AIModelAdapter correctly', () async {
      final adapter = MultimodalSateAdapter(
        nativeBridge: nativeBridge,
        modelPath: 'assets/models/qwen3.5-2b.gguf',
        modelId: 'test-qwen-adapter',
      );

      expect(adapter.modelId, 'test-qwen-adapter');
      expect(await adapter.isHealthy(), isTrue);
      expect(adapter.isDegraded, isFalse);

      final output = await adapter.runInference(AIInput(text: 'What is in this picture?'));
      expect(output.text, contains('Qwen3.5-2B Multimodal Response'));
      expect(output.confidence, greaterThan(0.0));
      expect(output.metadata?['modelId'], 'test-qwen-adapter');

      // Test memory pressure simulation & degradation
      await adapter.simulateMemoryPressure(300);
      expect(adapter.isDegraded, isTrue);
      expect(await adapter.isHealthy(), isFalse);

      // Test recovery after reset
      await adapter.reset();
      expect(adapter.isDegraded, isFalse);
      expect(await adapter.isHealthy(), isTrue);
    });

    test('Pre-Training Stress Test runs with SATE AI injectors', () async {
      final report = await validationService.runPreTrainingValidation(
        modelPath: 'assets/models/qwen3.5-2b.gguf',
      );

      expect(report.modelId, 'qwen3.5-2b-pretraining');
      expect(report.results.length, equals(5));
      expect(report.toMarkdown(), contains('SATE AI Stress Test Report'));

      for (final res in report.results) {
        expect(res.inferenceTime, isNotNull);
      }
    });

    test('Post-Training Verification runs with SATE AI injectors', () async {
      final report = await validationService.runPostTrainingValidation(
        modelPath: 'assets/models/qwen3.5-2b.gguf',
      );

      expect(report.modelId, 'qwen3.5-2b-posttraining');
      expect(report.results.length, equals(4));
      expect(report.toMarkdown(), contains('qwen3.5-2b-posttraining'));
    });
  });
}
