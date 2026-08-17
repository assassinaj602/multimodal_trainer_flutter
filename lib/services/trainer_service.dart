import 'native_bridge.dart';

class TrainerService {
  final NativeBridge _bridge;

  TrainerService(this._bridge);

  Future<double> runStep({
    required String imagePath,
    required String prompt,
  }) async {
    await _bridge.forwardPass(
      imagePath: imagePath,
      textPrompt: prompt,
      isTraining: true,
    );
    await _bridge.backwardPass();
    return 0.45; // Dummy loss value for skeleton pipeline testing
  }
}
