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
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Trainer'),
          NavigationDestination(icon: Icon(Icons.folder_copy), label: 'Dataset'),
          NavigationDestination(icon: Icon(Icons.analytics), label: 'Analytics'),
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
        title: const Text('MobileFineTuner — Qwen3.5-2B'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'Multimodal Trainer',
                applicationVersion: '1.0.0 (Phase 4)',
                applicationLegalese: 'Duke Kunshan University — Edge Intelligence Lab',
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
                  onStart: () => provider.startTraining(),
                  onPause: () => provider.pauseTraining(),
                  onStop: () => provider.stopTraining(),
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
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
