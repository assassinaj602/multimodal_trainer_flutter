import 'package:flutter/material.dart';
import '../widgets/loss_graph.dart';

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loss & Convergence Graphs')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: LossGraph(),
      ),
    );
  }
}
