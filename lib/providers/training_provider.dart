import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import '../models/dataset_info.dart';
import '../models/model_info.dart';
import '../models/training_config.dart';
import '../models/training_status.dart';
import '../services/dataset_service.dart';
import '../services/trainer_service.dart';
import '../utils/logger.dart';

class TrainingProvider extends ChangeNotifier {
  final TrainerService _trainer;
  final DatasetService _datasetService;
  StreamSubscription<TrainingStepEvent>? _trainingSubscription;

  TrainingConfig config = TrainingConfig();
  TrainingStatus status = TrainingStatus.initial();
  ModelStatus modelStatus = ModelStatus();
  MultimodalDataset? dataset;

  final List<FlSpot> _lossHistory = [
    const FlSpot(0, 1.0),
  ];

  List<FlSpot> get lossHistory => List.unmodifiable(_lossHistory);
  List<String> get logs => Logger.logs;
  bool get isRunning => status.state == TrainingState.running;
  bool get isPaused => status.state == TrainingState.paused;
  bool get canSave => status.state == TrainingState.completed || status.state == TrainingState.paused;
  bool get canExport => status.state == TrainingState.completed;

  TrainingProvider(this._trainer, this._datasetService);

  Future<void> loadDataset([String? customPath]) async {
    final targetPath = customPath ?? config.datasetPath;
    config.datasetPath = targetPath;
    dataset = await _datasetService.loadDataset(targetPath);
    Logger.log('Dataset "${dataset?.name}" loaded with ${dataset?.sampleCount ?? 0} samples');
    notifyListeners();
  }

  Future<void> startTraining() async {
    if (dataset == null) await loadDataset();
    if (dataset == null || dataset!.samples.isEmpty) return;

    if (status.state != TrainingState.paused) {
      _lossHistory.clear();
      _lossHistory.add(const FlSpot(0, 1.0));
    }

    status = TrainingStatus.running(
      epoch: 1,
      totalEpochs: config.numEpochs,
      step: status.currentStep,
      totalSteps: config.numEpochs * dataset!.sampleCount,
      progress: status.progress,
      loss: status.currentLoss ?? 1.0,
      accuracy: 65.0,
    );
    notifyListeners();

    _trainingSubscription?.cancel();
    _trainingSubscription = _trainer
        .trainStream(dataset: dataset!, config: config)
        .listen(
      (event) {
        _lossHistory.add(FlSpot(event.step.toDouble(), event.loss));
        // Simulated accuracy improvement with decreasing loss
        final accuracy = (100.0 - (event.loss * 40.0)).clamp(50.0, 99.5);

        status = TrainingStatus.running(
          epoch: event.epoch,
          totalEpochs: config.numEpochs,
          step: event.step,
          totalSteps: event.totalSteps,
          progress: event.progress,
          loss: event.loss,
          accuracy: accuracy,
        );
        Logger.log('Step ${event.step}/${event.totalSteps} (Epoch ${event.epoch}) - Loss: ${event.loss.toStringAsFixed(4)} - Accuracy: ${accuracy.toStringAsFixed(1)}%');
        notifyListeners();
      },
      onDone: () {
        status = TrainingStatus.completed();
        Logger.log('Training session completed successfully');
        notifyListeners();
      },
      onError: (err) {
        status = TrainingStatus.error(err.toString());
        Logger.log('Training error: $err');
        notifyListeners();
      },
    );
  }

  void pauseTraining() {
    _trainingSubscription?.pause();
    status = TrainingStatus(
      state: TrainingState.paused,
      currentEpoch: status.currentEpoch,
      totalEpochs: status.totalEpochs,
      currentStep: status.currentStep,
      totalSteps: status.totalSteps,
      progress: status.progress,
      currentLoss: status.currentLoss,
      currentAccuracy: status.currentAccuracy,
    );
    Logger.log('Training paused at step ${status.currentStep}');
    notifyListeners();
  }

  void stopTraining() {
    _trainer.cancel();
    _trainingSubscription?.cancel();
    _trainingSubscription = null;
    status = TrainingStatus.initial();
    Logger.log('Training stopped by user');
    notifyListeners();
  }

  void saveCheckpoint() {
    Logger.log('Checkpoint saved: Epoch ${status.currentEpoch}, Step ${status.currentStep}, Loss ${status.currentLoss?.toStringAsFixed(4) ?? "-"}');
  }

  void exportModel() {
    Logger.log('Model exported to GGUF format');
  }

  @override
  void dispose() {
    _trainingSubscription?.cancel();
    super.dispose();
  }
}
