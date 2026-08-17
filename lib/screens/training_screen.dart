import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/training_controls.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Training Session')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ProgressSection(status: provider.status),
            const SizedBox(height: 16),
            TrainingControls(
              config: provider.config,
              onStart: () => provider.startTraining(),
              onPause: () => provider.pauseTraining(),
              onStop: () => provider.stopTraining(),
              isRunning: provider.isRunning,
            ),
          ],
        ),
      ),
    );
  }
}
