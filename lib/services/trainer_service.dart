import 'native_bridge.dart';

class TrainerService {
  final NativeBridge _bridge;

  TrainerService(this._bridge);

  Future<double> runStep({
    required String imagePath,
    required String prompt,
  }) async {
    final loss = await _bridge.forwardPass(
      imagePath: imagePath,
      textPrompt: prompt,
      isTraining: true,
    );
    await _bridge.backwardPass();
    return loss;
  }
}
