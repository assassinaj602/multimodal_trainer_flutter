import 'package:flutter/material.dart';
import '../models/training_status.dart';

class ProgressSection extends StatelessWidget {
  final TrainingStatus status;

  const ProgressSection({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Training Progress',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (status.progress / 100).clamp(0.0, 1.0),
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${status.progress.toStringAsFixed(1)}%'),
                Text('Epoch: ${status.currentEpoch}/${status.totalEpochs}'),
                Text('Step: ${status.currentStep}/${status.totalSteps}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Loss: ${status.currentLoss?.toStringAsFixed(4) ?? "-"}'),
                Text('State: ${status.state.name}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
