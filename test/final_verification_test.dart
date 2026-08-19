import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_trainer/models/training_config.dart';
import 'package:multimodal_trainer/services/dataset_service.dart';
import 'package:multimodal_trainer/services/model_service.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';
import 'package:multimodal_trainer/services/trainer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 6: Final Verification & System Sanity Suite', () {
    late NativeBridge bridge;
    late ModelService modelService;
    late TrainerService trainerService;
    late DatasetService datasetService;
    late Directory tempDir;

    setUp(() async {
      bridge = NativeBridge();
      modelService = ModelService(bridge);
      trainerService = TrainerService(bridge);
      datasetService = DatasetService();
      tempDir = await Directory.systemTemp.createTemp('final_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Full End-to-End Multimodal Fine-Tuning Life Cycle', () async {
      // 1. Model Initialization
      final modelStatus = await modelService.loadModel('assets/models/qwen3.5-2b.gguf');
      expect(modelStatus.isLoaded, isTrue);

      // 2. Dataset Loading & Inspection
      final dataset = await datasetService.loadDataset('assets/datasets/sample_dataset.json');
      expect(dataset.sampleCount, greaterThanOrEqualTo(10));
      expect(dataset.getPreviewSamples(count: 3).length, equals(3));

      // 3. Training Execution with Multi-Step Loss Convergence
      final config = TrainingConfig(numEpochs: 2, batchSize: 1, learningRate: 0.001);
      final events = <TrainingStepEvent>[];

      await for (final event in trainerService.trainStream(dataset: dataset, config: config)) {
        events.add(event);
      }

      expect(events.length, equals(20));
      expect(events.last.loss, lessThan(events.first.loss));

      // 4. Checkpoint Serialization & Recovery
      final ckptPath = '${tempDir.path}/final_ckpt.mftc';
      final saveOk = await trainerService.saveCheckpoint(filepath: ckptPath, epoch: 2, step: 20);
      expect(saveOk, isTrue);

      final loadOk = await trainerService.loadCheckpoint(filepath: ckptPath);
      expect(loadOk, isTrue);

      // 5. GGUF Model Export
      final exportPath = '${tempDir.path}/qwen3.5_finetuned.gguf';
      final exportOk = await trainerService.exportModel(outputPath: exportPath);
      expect(exportOk, isTrue);

      // 6. Model Unloading & Cleanup
      final unloadedStatus = await modelService.unloadModel();
      expect(unloadedStatus.isLoaded, isFalse);
    });
  });
}
