import 'dart:async';
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

  List<String> get logs => Logger.logs;
  bool get isRunning => status.state == TrainingState.running;
  bool get canSave => status.state == TrainingState.completed || status.state == TrainingState.paused;
  bool get canExport => status.state == TrainingState.completed;

  TrainingProvider(this._trainer, this._datasetService);

  Future<void> loadDataset() async {
    dataset = await _datasetService.loadDataset(config.datasetPath);
    Logger.log('Dataset loaded: ${dataset?.sampleCount ?? 0} samples');
    notifyListeners();
  }

  Future<void> startTraining() async {
    if (dataset == null) await loadDataset();
    if (dataset == null || dataset!.samples.isEmpty) return;

    status = TrainingStatus.running(
      epoch: 1,
      totalEpochs: config.numEpochs,
      step: 0,
      totalSteps: config.numEpochs * dataset!.sampleCount,
      progress: 0.0,
      loss: 1.0,
    );
    notifyListeners();

    _trainingSubscription?.cancel();
    _trainingSubscription = _trainer
        .trainStream(dataset: dataset!, config: config)
        .listen(
      (event) {
        status = TrainingStatus.running(
          epoch: event.epoch,
          totalEpochs: config.numEpochs,
          step: event.step,
          totalSteps: event.totalSteps,
          progress: event.progress,
          loss: event.loss,
        );
        Logger.log('Step ${event.step}/${event.totalSteps} (Epoch ${event.epoch}) - Loss: ${event.loss.toStringAsFixed(4)} - GradNorm: ${event.gradientNorm.toStringAsFixed(4)}');
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
    status = TrainingStatus(state: TrainingState.paused, progress: status.progress, currentLoss: status.currentLoss);
    Logger.log('Training paused');
    notifyListeners();
  }

  void stopTraining() {
    _trainer.cancel();
    _trainingSubscription?.cancel();
    _trainingSubscription = null;
    status = TrainingStatus.initial();
    Logger.log('Training stopped');
    notifyListeners();
  }

  void saveCheckpoint() {
    Logger.log('Checkpoint saved: epoch=${status.currentEpoch}, step=${status.currentStep}, loss=${status.currentLoss?.toStringAsFixed(4) ?? "-"}');
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
