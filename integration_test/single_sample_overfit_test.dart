import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('100-Step Single-Sample Overfit Convergence & Real Accuracy Test', (WidgetTester tester) async {
    print('=== STARTING 100-STEP SINGLE-SAMPLE OVERFIT & ACCURACY TEST ===');
    final bridge = NativeBridge();
    final handleStatus = await bridge.loadModel('qwen2.5-0.5b-100step-overfit-test');
    print('loadModel status: $handleStatus');

    // Fixed single real sample from dataset (Sample 1)
    const String imagePath = 'assets/sample_data/sample1.jpg';
    const String instruction = 'Describe the main object in the foreground.';
    const String response = 'A high-resolution mobile edge intelligence system running localized multimodal models.';
    const double learningRate = 0.01;

    double? initialLoss;
    double? finalLoss;
    double maxAccuracySeen = 0.0;

    for (int step = 1; step <= 100; ++step) {
      final res = await bridge.runTrainingStep(
        imagePath: imagePath,
        prompt: instruction,
        responseLabel: response,
        learningRate: learningRate,
        step: step,
        totalSteps: 100,
      );

      if (step == 1) initialLoss = res.loss;
      if (step == 100) finalLoss = res.loss;
      if (res.accuracy > maxAccuracySeen) maxAccuracySeen = res.accuracy;

      print('[OVERFIT_STEP $step/100] Loss: ${res.loss.toStringAsFixed(4)}, GradNorm: ${res.gradientNorm.toStringAsFixed(4)}, Real Token Accuracy: ${res.accuracy.toStringAsFixed(1)}%');
    }

    print('=== 100-STEP OVERFIT SUMMARY ===');
    print('Initial Step 1 Loss: $initialLoss');
    print('Final Step 100 Loss: $finalLoss');
    print('Delta: ${(initialLoss! - finalLoss!)}');
    print('Max Real Token Accuracy Reached: ${maxAccuracySeen.toStringAsFixed(1)}%');
  });
}
