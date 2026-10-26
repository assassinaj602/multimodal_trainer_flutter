import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:multimodal_trainer/services/native_bridge.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Verify On-Device Native FFI Bridge & Display Verification Code', (WidgetTester tester) async {
    const String verificationCode = "739281";

    // 1. Render UI with large verification number
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ANTIGRAVITY VERIFICATION',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Text(
                    verificationCode,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8.0,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Executing Native C++ FFI Step...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // 2. Execute native FFI step
    final bridge = NativeBridge();
    final loadStatus = await bridge.loadModel('qwen2.5-0.5b-native-device');
    print('loadModel: $loadStatus');

    final stepResult = await bridge.runTrainingStep(
      imagePath: 'assets/sample.jpg',
      prompt: 'Describe this multimodal input token',
      learningRate: 0.001,
      step: 1,
      totalSteps: 10,
    );

    print('StepResult loss: ${stepResult.loss}');
    print('StepResult gradientNorm: ${stepResult.gradientNorm}');

    // Keep the verification code visible on screen for 6 seconds
    await tester.pump(const Duration(seconds: 6));
  });
}
