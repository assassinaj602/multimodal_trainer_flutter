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

  Map<String, dynamic> toJson() => {
        'image': imagePath,
        'instruction': instruction,
        'response': response,
      };
}

class MultimodalDataset {
  final String name;
  final List<DatasetSample> samples;

  MultimodalDataset({
    this.name = 'Qwen3.5-VL Fine-Tuning Corpus',
    required this.samples,
  });

  int get sampleCount => samples.length;

  List<DatasetSample> getPreviewSamples({int count = 5}) {
    return samples.take(count).toList();
  }
}
