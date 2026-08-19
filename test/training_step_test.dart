import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_trainer/models/dataset_info.dart';
import 'package:multimodal_trainer/models/training_config.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';
import 'package:multimodal_trainer/services/trainer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3: Core Model Implementation & Training Pipeline Tests', () {
    late NativeBridge bridge;
    late TrainerService trainer;

    setUp(() {
      bridge = NativeBridge();
      trainer = TrainerService(bridge);
    });

    test('Single forward and backward pass execution', () async {
      await bridge.loadModel('assets/models/qwen3.5-2b.gguf');

      final loss = await bridge.forwardPass(
        imagePath: 'assets/sample_data/sample1.jpg',
        textPrompt: 'Describe this image in detail.',
        isTraining: true,
      );

      expect(loss, isNotNull);
      expect(loss, isNonNegative);

      final backwardSuccess = await bridge.backwardPass();
      expect(backwardSuccess, isTrue);
    });

    test('10-Step Training Loop & Loss Convergence Test', () async {
      await bridge.loadModel('assets/models/qwen3.5-2b.gguf');

      final samples = List.generate(
        10,
        (i) => DatasetSample(
          imagePath: 'assets/sample_data/sample${i + 1}.jpg',
          instruction: 'Prompt instruction #$i',
          response: 'Target response #$i',
        ),
      );
      final dataset = MultimodalDataset(samples: samples);
      final config = TrainingConfig(numEpochs: 1, batchSize: 1, learningRate: 0.001);

      final losses = <double>[];
      final events = <TrainingStepEvent>[];

      await for (final event in trainer.trainStream(dataset: dataset, config: config)) {
        events.add(event);
        losses.add(event.loss);
      }

      // Verify all 10 steps executed
      expect(events.length, equals(10));
      expect(events.last.progress, equals(100.0));

      // Verify loss decreases from step 1 to step 10
      final firstLoss = losses.first;
      final lastLoss = losses.last;
      expect(lastLoss, lessThan(firstLoss));
      expect(events.last.gradientNorm, isNonNegative);
    });
  });
}
