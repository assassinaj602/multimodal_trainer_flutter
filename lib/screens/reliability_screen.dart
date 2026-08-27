import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sate_ai/sate_ai.dart';
import '../providers/model_provider.dart';
import '../providers/validation_provider.dart';

class ReliabilityScreen extends StatelessWidget {
  const ReliabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final validationProvider = Provider.of<ValidationProvider>(context);
    final modelProvider = Provider.of<ModelProvider>(context);
    final report = validationProvider.latestReport;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SATE AI Model Reliability'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Results',
            onPressed: validationProvider.clearReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.purpleAccent, size: 28),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SATE AI Fault Injection Suite',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Target: ${modelProvider.status.modelName}',
                                style: const TextStyle(fontSize: 13, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Stress-test model stability against memory pressure, quantization drift, thermal throttling, and malformed tensor inputs before/after training.',
                      style: TextStyle(fontSize: 13, color: Colors.white60),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: validationProvider.isValidating
                              ? null
                              : () => validationProvider.runValidation(
                                    modelProvider.status.modelPath,
                                    isPreTraining: true,
                                  ),
                          icon: const Icon(Icons.play_circle_fill, size: 18),
                          label: const Text('Pre-Training Stress Test'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                        ),
                        OutlinedButton.icon(
                          onPressed: validationProvider.isValidating
                              ? null
                              : () => validationProvider.runValidation(
                                    modelProvider.status.modelPath,
                                    isPreTraining: false,
                                  ),
                          icon: const Icon(Icons.verified, size: 18),
                          label: const Text('Post-Training Verification'),
                        ),
                      ],
                    ),
                    if (validationProvider.isValidating) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Injecting faults & running SATE AI stress suite...',
                          style: TextStyle(fontSize: 12, color: Colors.purpleAccent),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (validationProvider.errorMessage != null)
              Card(
                color: Colors.red.shade900.withValues(alpha: 0.5),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Error: ${validationProvider.errorMessage}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (report != null) ...[
              Card(
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
                                report.passed ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: report.passed ? Colors.greenAccent : Colors.orangeAccent,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                report.passed ? 'All Stress Tests Passed' : 'Stress Tests Found Failures',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Chip(
                            label: Text(
                              '${report.failureCount} Failures',
                              style: TextStyle(
                                color: report.passed ? Colors.greenAccent : Colors.orangeAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Fault Injector Breakdown',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...report.results.map((result) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            result.passed ? Icons.check : Icons.close,
                            color: result.passed ? Colors.green : Colors.redAccent,
                          ),
                          title: Text(result.injectorType.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Inference: ${result.inferenceTime?.inMilliseconds ?? 0}ms | Memory: ${result.memoryUsageMB?.toStringAsFixed(1) ?? "0"}MB'),
                          trailing: result.passed
                              ? const Text('PASSED', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold))
                              : const Text('FAILED', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        );
                      }),
                      const SizedBox(height: 16),
                      ExpansionTile(
                        title: const Text('View Raw Markdown Report', style: TextStyle(fontSize: 13)),
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SelectableText(
                              report.toMarkdown(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
