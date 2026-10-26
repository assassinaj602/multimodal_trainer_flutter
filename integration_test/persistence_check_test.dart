import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Execute 5 Consecutive Training Steps to Verify Parameter Persistence', (WidgetTester tester) async {
    final bridge = NativeBridge();
    final handleStatus = await bridge.loadModel('qwen2.5-0.5b-persistence-test');
    print('loadModel status: $handleStatus');

    for (int step = 1; step <= 5; ++step) {
      final res = await bridge.runTrainingStep(
        imagePath: 'assets/sample.jpg',
        prompt: 'Sample Prompt Step $step',
        learningRate: 0.001,
        step: step,
        totalSteps: 5,
      );
      print('Step $step: loss=${res.loss}, gradNorm=${res.gradientNorm}');
    }
  });
}
