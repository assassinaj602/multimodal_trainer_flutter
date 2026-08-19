import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';
import '../widgets/log_viewer.dart';
import '../widgets/loss_graph.dart';
import '../widgets/model_status_card.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/training_controls.dart';
import 'dataset_screen.dart';
import 'graph_screen.dart';
import 'training_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const _DashboardView(),
      const TrainingScreen(),
      const DatasetScreen(),
      const GraphScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedNavIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Trainer'),
          NavigationDestination(icon: Icon(Icons.folder_copy_outlined), selectedIcon: Icon(Icons.folder_copy), label: 'Dataset'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Analytics'),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MobileFineTuner — Qwen3.5-2B',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About Project',
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Multimodal Trainer',
                applicationVersion: '1.0.0 (Release Candidate)',
                applicationLegalese: 'Duke Kunshan University — Edge Intelligence Lab\nQwen3.5-2B VLM Fine-Tuning Pipeline',
              );
            },
          ),
        ],
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
                  onStart: () {
                    provider.startTraining();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Multimodal fine-tuning pipeline initialized'),
                        backgroundColor: Colors.deepPurple,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  onPause: () {
                    provider.pauseTraining();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Training loop paused'),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  onStop: () {
                    provider.stopTraining();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Training session terminated'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  isRunning: provider.isRunning,
                ),
                const SizedBox(height: 16),
                ProgressSection(status: provider.status),
                const SizedBox(height: 16),
                LossGraph(points: provider.lossHistory),
                const SizedBox(height: 16),
                LogViewer(logs: provider.logs),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: provider.canSave
                          ? () async {
                              final ok = await provider.saveCheckpoint();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok ? 'Checkpoint saved successfully!' : 'Failed to save checkpoint'),
                                    backgroundColor: ok ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Checkpoint'),
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.canExport
                          ? () async {
                              final ok = await provider.exportModel();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(ok ? 'Model exported to GGUF format!' : 'Failed to export model'),
                                    backgroundColor: ok ? Colors.blueAccent : Colors.red,
                                  ),
                                );
                              }
                            }
                          : null,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Export Model'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
