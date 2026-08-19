import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_trainer/models/dataset_info.dart';
import 'package:multimodal_trainer/models/training_config.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';
import 'package:multimodal_trainer/services/trainer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 5: End-to-End Multimodal Training Validation', () {
    late NativeBridge bridge;
    late TrainerService trainer;
    late Directory tempDir;

    setUp(() async {
      bridge = NativeBridge();
      trainer = TrainerService(bridge);
      tempDir = await Directory.systemTemp.createTemp('mft_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('100-Step Full Training Loop with Loss Convergence', () async {
      await bridge.loadModel('assets/models/qwen3.5-2b.gguf');

      // 10 samples x 10 epochs = 100 steps
      final samples = List.generate(
        10,
        (i) => DatasetSample(
          imagePath: 'assets/sample_data/sample${i + 1}.jpg',
          instruction: 'Multimodal Instruction #$i',
          response: 'Target model response #$i',
        ),
      );
      final dataset = MultimodalDataset(samples: samples);
      final config = TrainingConfig(numEpochs: 10, batchSize: 1, learningRate: 0.001);

      final losses = <double>[];
      final events = <TrainingStepEvent>[];

      await for (final event in trainer.trainStream(dataset: dataset, config: config)) {
        events.add(event);
        losses.add(event.loss);
      }

      // 1. Verify all 100 steps ran
      expect(events.length, equals(100));
      expect(events.last.epoch, equals(10));
      expect(events.last.progress, equals(100.0));

      // 2. Verify loss convergence
      final initialLoss = losses.take(5).reduce((a, b) => a + b) / 5;
      final finalLoss = losses.skip(95).reduce((a, b) => a + b) / 5;
      expect(finalLoss, lessThan(initialLoss));
      expect(events.last.gradientNorm, isNonNegative);
    });

    test('Checkpoint Serialization and Restoration Test', () async {
      await bridge.loadModel('assets/models/qwen3.5-2b.gguf');

      final checkpointPath = '${tempDir.path}/test_checkpoint.mftc';

      // Save checkpoint
      final saveOk = await trainer.saveCheckpoint(
        filepath: checkpointPath,
        epoch: 3,
        step: 30,
      );
      expect(saveOk, isTrue);
      expect(await File(checkpointPath).exists(), isTrue);

      // Load checkpoint
      final loadOk = await trainer.loadCheckpoint(filepath: checkpointPath);
      expect(loadOk, isTrue);

      // Invalid path error handling
      final invalidOk = await trainer.loadCheckpoint(filepath: '${tempDir.path}/nonexistent.mftc');
      expect(invalidOk, isFalse);
    });

    test('Model Export as GGUF Format Test', () async {
      await bridge.loadModel('assets/models/qwen3.5-2b.gguf');

      final exportPath = '${tempDir.path}/qwen3.5_2b_exported.gguf';

      final exportOk = await trainer.exportModel(outputPath: exportPath);
      expect(exportOk, isTrue);
      expect(await File(exportPath).exists(), isTrue);
      expect(await File(exportPath).length(), greaterThan(0));
    });
  });
}
