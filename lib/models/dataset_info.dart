class DatasetSample {
  final String imagePath;
  final String instruction;
  final String response;

  DatasetSample({
    required this.imagePath,
    required this.instruction,
    required this.response,
  });

  factory DatasetSample.fromJson(Map<String, dynamic> json) {
    return DatasetSample(
      imagePath: json['image'] ?? '',
      instruction: json['instruction'] ?? '',
      response: json['response'] ?? '',
    );
  }
}

class MultimodalDataset {
  final List<DatasetSample> samples;

  MultimodalDataset({required this.samples});
  
  int get sampleCount => samples.length;
}
