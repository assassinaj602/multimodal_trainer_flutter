import 'package:flutter/material.dart';
import '../models/training_config.dart';

class TrainingControls extends StatefulWidget {
  final TrainingConfig config;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final bool isRunning;

  const TrainingControls({
    super.key,
    required this.config,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.isRunning,
  });

  @override
  State<TrainingControls> createState() => _TrainingControlsState();
}

class _TrainingControlsState extends State<TrainingControls> {
  late TextEditingController _epochsController;
  late TextEditingController _batchSizeController;
  late TextEditingController _lrController;

  @override
  void initState() {
    super.initState();
    _epochsController = TextEditingController(text: widget.config.numEpochs.toString());
    _batchSizeController = TextEditingController(text: widget.config.batchSize.toString());
    _lrController = TextEditingController(text: widget.config.learningRate.toString());
  }

  @override
  void dispose() {
    _epochsController.dispose();
    _batchSizeController.dispose();
    _lrController.dispose();
    super.dispose();
  }

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
              'Training Parameters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _epochsController,
                    decoration: const InputDecoration(
                      labelText: 'Epochs',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      widget.config.numEpochs = int.tryParse(val) ?? widget.config.numEpochs;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _batchSizeController,
                    decoration: const InputDecoration(
                      labelText: 'Batch Size',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      widget.config.batchSize = int.tryParse(val) ?? widget.config.batchSize;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lrController,
              decoration: const InputDecoration(
                labelText: 'Learning Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) {
                widget.config.learningRate = double.tryParse(val) ?? widget.config.learningRate;
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: widget.isRunning ? null : widget.onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: widget.isRunning ? widget.onPause : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
                ElevatedButton.icon(
                  onPressed: widget.isRunning ? widget.onStop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
