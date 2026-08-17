class TrainingConfig {
  int numEpochs;
  int batchSize;
  double learningRate;
  String datasetPath;
  String modelPath;

  TrainingConfig({
    this.numEpochs = 5,
    this.batchSize = 1,
    this.learningRate = 0.001,
    this.datasetPath = 'assets/datasets/sample_dataset.json',
    this.modelPath = 'assets/models/qwen3.5-2b.gguf',
  });
}
