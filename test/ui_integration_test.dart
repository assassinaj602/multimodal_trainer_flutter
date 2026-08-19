import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multimodal_trainer/main.dart';
import 'package:multimodal_trainer/screens/dataset_screen.dart';
import 'package:multimodal_trainer/screens/graph_screen.dart';
import 'package:multimodal_trainer/screens/training_screen.dart';

void main() {
  testWidgets('Phase 4: UI Navigation & Interactive Screen Tests', (WidgetTester tester) async {
    await tester.pumpWidget(const MultimodalTrainerApp());
    await tester.pumpAndSettle();

    // 1. Verify Home dashboard elements render
    expect(find.text('MobileFineTuner — Qwen3.5-2B'), findsOneWidget);
    expect(find.text('Model Target: Qwen3.5-2B'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    // 2. Navigate to Trainer tab
    await tester.tap(find.byIcon(Icons.fitness_center));
    await tester.pumpAndSettle();
    expect(find.byType(TrainingScreen), findsOneWidget);

    // 3. Navigate to Dataset tab
    await tester.tap(find.byIcon(Icons.folder_copy));
    await tester.pumpAndSettle();
    expect(find.byType(DatasetScreen), findsOneWidget);
    expect(find.text('Dataset Explorer & Pipeline'), findsOneWidget);

    // 4. Navigate to Analytics tab
    await tester.tap(find.byIcon(Icons.analytics));
    await tester.pumpAndSettle();
    expect(find.byType(GraphScreen), findsOneWidget);
    expect(find.text('Loss & Convergence Analytics'), findsOneWidget);

    // 5. Navigate back to Dashboard and test Start Training trigger
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Confirm state has progressed
    expect(find.text('Live Loss Curve'), findsOneWidget);
  });
}
