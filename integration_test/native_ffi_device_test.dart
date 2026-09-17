import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';
import 'package:multimodal_trainer/services/trainer_service.dart';
import 'package:multimodal_trainer/models/dataset_info.dart';
import 'package:multimodal_trainer/models/training_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verify On-Device Native FFI Bridge & Real Training Step', (WidgetTester tester) async {
    print('=== INTEGRATION TEST: ON-DEVICE NATIVE FFI VERIFICATION ===');
    final bridge = NativeBridge();
    print('NativeBridge isNativeAvailable: ${bridge.isNativeAvailable}');
    expect(bridge.isNativeAvailable, isTrue, reason: 'libmultimodal_trainer.so must be loaded on Android device');

    // 1. Explicitly load native model handle
    final loadStatus = await bridge.loadModel('qwen2.5-0.5b-native-device');
    print('loadModel returned: $loadStatus');
    expect(loadStatus.startsWith('NativeHandle_Loaded_'), isTrue, reason: 'Must return valid pointer address');

    // 2. Query model status from C++
    final statusJson = await bridge.getModelStatus();
    print('getModelStatus returned JSON: $statusJson');
    expect(statusJson.contains('Qwen-Multimodal-Native'), isTrue);

    // 3. Execute real multimodal training step through FFI
    print('Executing real FFI runTrainingStep...');
    final stepResult = await bridge.runTrainingStep(
      imagePath: 'assets/sample.jpg',
      prompt: 'Describe this multimodal input token',
      learningRate: 0.001,
      step: 1,
      totalSteps: 10,
    );

    print('StepResult loss: ${stepResult.loss}');
    print('StepResult gradientNorm: ${stepResult.gradientNorm}');
    print('StepResult success: ${stepResult.success}');

    expect(stepResult.success, isTrue, reason: 'C++ training step must succeed');
    expect(stepResult.loss, greaterThan(0.0), reason: 'Cross-entropy loss must be positive');
    expect(stepResult.gradientNorm, greaterThan(0.0), reason: 'Autograd projector gradient norm must be positive');

    print('=== ON-DEVICE FFI BRIDGE VERIFICATION COMPLETED SUCCESSFULLY ===');
  });
}
