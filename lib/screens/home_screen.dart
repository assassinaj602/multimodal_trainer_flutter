import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../widgets/log_viewer.dart';
import '../widgets/loss_graph.dart';
import '../widgets/model_status_card.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/training_controls.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multimodal Trainer - Qwen3.5-2B'),
        centerTitle: true,
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModelStatusCard(status: provider.modelStatus),
                const SizedBox(height: 16),
                TrainingControls(
                  config: provider.config,
                  onStart: () => provider.startTraining(),
                  onPause: () => provider.pauseTraining(),
                  onStop: () => provider.stopTraining(),
                  isRunning: provider.isRunning,
                ),
                const SizedBox(height: 16),
                ProgressSection(status: provider.status),
                const SizedBox(height: 16),
                const LossGraph(),
                const SizedBox(height: 16),
                LogViewer(logs: provider.logs),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: provider.canSave ? () => provider.saveCheckpoint() : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Checkpoint'),
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.canExport ? () => provider.exportModel() : null,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Export Model'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
