import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dataset_info.dart';

class DatasetService {
  Future<MultimodalDataset> loadDataset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonData = jsonDecode(jsonString);
      final samples = jsonData.map((item) => DatasetSample.fromJson(item)).toList();
      return MultimodalDataset(samples: samples);
    } catch (e) {
      return MultimodalDataset(samples: [
        DatasetSample(
          imagePath: 'assets/sample_data/sample1.jpg',
          instruction: 'Sample multimodal query',
          response: 'Sample response output',
        ),
      ]);
    }
  }
}
