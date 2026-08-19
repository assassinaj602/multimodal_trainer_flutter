import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/dataset_info.dart';
import '../utils/logger.dart';

class DatasetService {
  Future<MultimodalDataset> loadDataset(String path) async {
    Logger.log('DatasetService: Loading dataset from "$path"');
    try {
      String content;
      if (path.startsWith('assets/')) {
        content = await rootBundle.loadString(path);
      } else {
        final file = File(path);
        if (await file.exists()) {
          content = await file.readAsString();
        } else {
          content = await rootBundle.loadString('assets/datasets/sample_dataset.json');
        }
      }

      final List<dynamic> jsonData = jsonDecode(content);
      final samples = jsonData.map((item) => DatasetSample.fromJson(item)).toList();
      Logger.log('DatasetService: Successfully parsed ${samples.length} multimodal samples');
      return MultimodalDataset(
        name: path.split('/').last.replaceAll('.json', ''),
        samples: samples,
      );
    } catch (e) {
      Logger.log('DatasetService: Error loading dataset ($e), using default sample entries');
      return MultimodalDataset(
        name: 'Default Test Dataset',
        samples: List.generate(
          10,
          (i) => DatasetSample(
            imagePath: 'assets/sample_data/sample${i + 1}.jpg',
            instruction: 'Instruction sample #${i + 1}',
            response: 'Target model response #${i + 1}',
          ),
        ),
      );
    }
  }

  Future<List<DatasetSample>> getBatch(MultimodalDataset dataset, int batchSize, int offset) async {
    return dataset.samples.skip(offset).take(batchSize).toList();
  }
}
