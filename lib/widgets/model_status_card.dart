import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/model_info.dart';
import '../providers/model_provider.dart';

class ModelStatusCard extends StatelessWidget {
  final ModelStatus status;

  const ModelStatusCard({super.key, required this.status});

  void _showPathDialog(BuildContext context, ModelProvider modelProvider) {
    final controller = TextEditingController(text: status.modelPath);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Model Weight Path'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Target VLM: Qwen3.5-2B (~4.5 GB)\nEnter local file path or asset path:',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Model Path (.gguf)',
                hintText: '/sdcard/Download/qwen3.5-2b.gguf',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPath = controller.text.trim();
              if (newPath.isNotEmpty) {
                modelProvider.loadModel(newPath);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Load Model'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modelProvider = Provider.of<ModelProvider>(context, listen: false);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status.isLoaded ? Icons.check_circle : Icons.model_training,
                      color: status.isLoaded ? Colors.greenAccent : Colors.orangeAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Target VLM: ${status.modelName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Change Model Path',
                  onPressed: () => _showPathDialog(context, modelProvider),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Model Size: ${status.size} (Unquantized VLM weights)'),
            Text('Host Memory: ${status.memoryUsage} / ${status.totalMemory}'),
            Text('Active Path: ${status.modelPath}', overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => modelProvider.loadModel(status.modelPath),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Initialize Model Context'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
