import 'package:flutter/material.dart';
import '../models/model_info.dart';

class ModelStatusCard extends StatelessWidget {
  final ModelStatus status;

  const ModelStatusCard({super.key, required this.status});

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
            Row(
              children: [
                Icon(
                  status.isLoaded ? Icons.check_circle : Icons.offline_bolt,
                  color: status.isLoaded ? Colors.greenAccent : Colors.orangeAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ${status.isLoaded ? "Model Loaded ✓" : "Ready / Standby"}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Model Target: ${status.modelName}'),
            Text('Estimated Size: ${status.size}'),
            Text('Memory Allocation: ${status.memoryUsage} / ${status.totalMemory}'),
            Text('Model Target Path: ${status.modelPath}', overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
