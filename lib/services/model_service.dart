import '../models/model_info.dart';
import 'native_bridge.dart';

class ModelService {
  final NativeBridge _bridge;

  ModelService(this._bridge);

  Future<ModelStatus> loadModel(String modelPath) async {
    await _bridge.loadModel(modelPath);
    return ModelStatus(
      isLoaded: true,
      modelPath: modelPath,
      memoryUsage: '4.5 GB',
    );
  }

  Future<ModelStatus> unloadModel() async {
    await _bridge.unloadModel();
    return ModelStatus(isLoaded: false);
  }
}
