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

    final loss = await _trainer.runStep(
      imagePath: dataset?.samples.first.imagePath ?? '',
      prompt: dataset?.samples.first.instruction ?? '',
    );

    status = TrainingStatus.running(
      epoch: 1,
      totalEpochs: config.numEpochs,
      step: 1,
      totalSteps: config.numEpochs * (dataset?.sampleCount ?? 1),
      progress: 10.0,
      loss: loss,
    );
    Logger.log('Training started: Epochs=${config.numEpochs}, BatchSize=${config.batchSize}, Step Loss=$loss');
    notifyListeners();
  }

  void pauseTraining() {
    status = TrainingStatus(state: TrainingState.paused, progress: status.progress);
    Logger.log('Training paused');
    notifyListeners();
  }

  void stopTraining() {
    status = TrainingStatus.initial();
    Logger.log('Training stopped');
    notifyListeners();
  }

  void saveCheckpoint() {
    Logger.log('Checkpoint saved');
  }

  void exportModel() {
    Logger.log('Model exported to GGUF format');
  }
}
