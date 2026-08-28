import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogViewer extends StatefulWidget {
  final List<String> logs;

  const LogViewer({super.key, required this.logs});

  @override
  State<LogViewer> createState() => _LogViewerState();
}

class _LogViewerState extends State<LogViewer> {
  final ScrollController _scrollController = ScrollController();

  void _copyAllLogs() {
    if (widget.logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No logs to copy'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    final allLogs = widget.logs.join('\n');
    Clipboard.setData(ClipboardData(text: allLogs));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied ${widget.logs.length} log lines to clipboard!'),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LogViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.logs.length != oldWidget.logs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.terminal, color: Colors.greenAccent),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Console & Logs',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.logs.length} lines',
                      style: const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.copy_all, size: 18, color: Colors.cyanAccent),
                      tooltip: 'Copy All Logs',
                      visualDensity: VisualDensity.compact,
                      onPressed: _copyAllLogs,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 140,
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: widget.logs.isEmpty
                  ? const Center(
                      child: Text(
                        'Awaiting model or training events...',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    )
                  : SelectionArea(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.logs.length,
                        itemBuilder: (context, index) {
                          final log = widget.logs[index];
                          Color logColor = Colors.greenAccent;
                          if (log.contains('Error')) {
                            logColor = Colors.redAccent;
                          } else if (log.contains('Loading') || log.contains('Dataset')) {
                            logColor = Colors.cyanAccent;
                          } else if (log.contains('Loss')) {
                            logColor = Colors.amberAccent;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: logColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
