import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';

class DatasetScreen extends StatelessWidget {
  const DatasetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrainingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dataset Management')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton.icon(
            onPressed: () => provider.loadDataset(),
            icon: const Icon(Icons.refresh),
            label: const Text('Load Sample Dataset'),
          ),
          const SizedBox(height: 16),
          if (provider.dataset != null)
            Text(
              'Loaded ${provider.dataset!.sampleCount} samples',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}
