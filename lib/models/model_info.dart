class ModelInfo {
  final String name;
  final String path;
  final String size;
  final bool isLoaded;

  ModelInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.isLoaded,
  });
}

class ModelStatus {
  final bool isLoaded;
  final String modelName;
  final String size;
  final String memoryUsage;
  final String totalMemory;
  final String modelPath;

  ModelStatus({
    this.isLoaded = false,
    this.modelName = 'Qwen3.5-2B',
    this.size = '4.5 GB',
    this.memoryUsage = '0 MB',
    this.totalMemory = '8 GB',
    this.modelPath = 'assets/models/qwen3.5-2b.gguf',
  });
}
