import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'providers/model_provider.dart';
import 'providers/training_provider.dart';

import 'screens/home_screen.dart';
import 'services/dataset_service.dart';
import 'services/model_service.dart';
import 'services/native_bridge.dart';
import 'services/trainer_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MultimodalTrainerApp());
}

class MultimodalTrainerApp extends StatelessWidget {
  final NativeBridge? nativeBridge;

  const MultimodalTrainerApp({super.key, this.nativeBridge});

  @override
  Widget build(BuildContext context) {
    final bridge = nativeBridge ?? NativeBridge();
    final modelService = ModelService(bridge);
    final trainerService = TrainerService(bridge);
    final datasetService = DatasetService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ModelProvider(modelService)),
        ChangeNotifierProvider(create: (_) => TrainingProvider(trainerService, datasetService)),
      ],
      child: MaterialApp(
        title: 'Multimodal Trainer',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
