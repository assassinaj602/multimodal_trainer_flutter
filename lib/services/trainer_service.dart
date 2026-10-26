import 'dart:async';
import '../models/dataset_info.dart';
import '../models/training_config.dart';
import '../utils/logger.dart';
import 'native_bridge.dart';

class TrainingStepEvent {
  final int epoch;
  final int step;
  final int totalSteps;
  final double loss;
  final double gradientNorm;
  final double accuracy;
  final double progress;

  TrainingStepEvent({
    required this.epoch,
    required this.step,
    required this.totalSteps,
    required this.loss,
    required this.gradientNorm,
    this.accuracy = 0.0,
    required this.progress,
  });
}

class TrainerService {
  final NativeBridge _bridge;
  bool _isCancelled = false;

  TrainerService(this._bridge);

  Future<double> runStep({
    required String imagePath,
    required String prompt,
    String response = '',
    double learningRate = 0.001,
  }) async {
    final step = await _bridge.runTrainingStep(
      imagePath: imagePath,
      prompt: prompt,
      responseLabel: response,
      learningRate: learningRate,
    );
    return step.loss;
  }

  Stream<TrainingStepEvent> trainStream({
    required MultimodalDataset dataset,
    required TrainingConfig config,
    Duration stepDelay = Duration.zero,
  }) async* {
    _isCancelled = false;
    final totalSteps = config.numEpochs * dataset.sampleCount;
    int currentStep = 0;

    Logger.log('TrainerService: Starting training loop ($totalSteps total steps across ${config.numEpochs} epochs)');

    for (int epoch = 1; epoch <= config.numEpochs; ++epoch) {
      for (int i = 0; i < dataset.samples.length; ++i) {
        if (_isCancelled) {
          Logger.log('TrainerService: Training cancelled by user');
          return;
        }

        final sample = dataset.samples[i];
        final stepResult = await _bridge.runTrainingStep(
          imagePath: sample.imagePath,
          prompt: sample.instruction,
          responseLabel: sample.response,
          learningRate: config.learningRate,
          step: currentStep + 1,
          totalSteps: totalSteps,
        );

        if (stepDelay > Duration.zero) {
          await Future.delayed(stepDelay);
        }

        currentStep++;
        final progress = (currentStep / (totalSteps > 0 ? totalSteps : 1)) * 100.0;

        yield TrainingStepEvent(
          epoch: epoch,
          step: currentStep,
          totalSteps: totalSteps,
          loss: stepResult.loss,
          gradientNorm: stepResult.gradientNorm,
          accuracy: stepResult.accuracy,
          progress: progress,
        );
      }
    }

    Logger.log('TrainerService: Training stream completed successfully');
  }

  Future<bool> saveCheckpoint({
    required String filepath,
    required int epoch,
    required int step,
  }) async {
    return _bridge.saveCheckpoint(filepath: filepath, epoch: epoch, step: step);
  }

  Future<bool> loadCheckpoint({
    required String filepath,
  }) async {
    return _bridge.loadCheckpoint(filepath: filepath);
  }

  Future<bool> exportModel({
    required String outputPath,
  }) async {
    return _bridge.exportModelGGUF(outputPath: outputPath);
  }

  void cancel() {
    _isCancelled = true;
  }
}
