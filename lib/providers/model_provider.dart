import 'package:flutter/foundation.dart';
import '../models/model_info.dart';
import '../services/model_service.dart';

class ModelProvider extends ChangeNotifier {
  final ModelService _modelService;
  ModelStatus _status = ModelStatus();

  ModelProvider(this._modelService);

  ModelStatus get status => _status;

  Future<void> loadModel(String path) async {
    _status = await _modelService.loadModel(path);
    notifyListeners();
  }

  Future<void> unloadModel() async {
    _status = await _modelService.unloadModel();
    notifyListeners();
  }
}
