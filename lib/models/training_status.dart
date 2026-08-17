enum TrainingState { initial, running, paused, completed, error }

class TrainingStatus {
  final TrainingState state;
  final int currentEpoch;
  final int totalEpochs;
  final int currentStep;
  final int totalSteps;
  final double progress;
  final double? currentLoss;
  final double? currentAccuracy;
  final String? errorMessage;

  TrainingStatus({
    required this.state,
    this.currentEpoch = 0,
    this.totalEpochs = 0,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.progress = 0.0,
    this.currentLoss,
    this.currentAccuracy,
    this.errorMessage,
  });

  factory TrainingStatus.initial() => TrainingStatus(state: TrainingState.initial);
  
  factory TrainingStatus.running({
    int epoch = 0,
    int totalEpochs = 1,
    int step = 0,
    int totalSteps = 1,
    double progress = 0.0,
    double? loss,
    double? accuracy,
  }) =>
      TrainingStatus(
        state: TrainingState.running,
        currentEpoch: epoch,
        totalEpochs: totalEpochs,
        currentStep: step,
        totalSteps: totalSteps,
        progress: progress,
        currentLoss: loss,
        currentAccuracy: accuracy,
      );

  factory TrainingStatus.completed() => TrainingStatus(state: TrainingState.completed, progress: 100.0);
  
  factory TrainingStatus.error(String message) =>
      TrainingStatus(state: TrainingState.error, errorMessage: message);
}
