import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// Native function typedefs
typedef LoadModelNative = Pointer<Void> Function(Pointer<Utf8> modelPath);
typedef LoadModelDart = Pointer<Void> Function(Pointer<Utf8> modelPath);

typedef UnloadModelNative = Void Function(Pointer<Void> handle);
typedef UnloadModelDart = void Function(Pointer<Void> handle);

typedef GetModelStatusNative = Pointer<Utf8> Function(Pointer<Void> handle);
typedef GetModelStatusDart = Pointer<Utf8> Function(Pointer<Void> handle);

typedef ForwardPassNative = Pointer<Void> Function(
  Pointer<Void> handle,
  Pointer<Utf8> imagePath,
  Pointer<Utf8> textPrompt,
  Int32 isTraining,
);
typedef ForwardPassDart = Pointer<Void> Function(
  Pointer<Void> handle,
  Pointer<Utf8> imagePath,
  Pointer<Utf8> textPrompt,
  int isTraining,
);

typedef GetForwardLossNative = Float Function(Pointer<Void> forwardResult);
typedef GetForwardLossDart = double Function(Pointer<Void> forwardResult);

typedef BackwardPassNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Void> forwardResult,
);
typedef BackwardPassDart = int Function(
  Pointer<Void> handle,
  Pointer<Void> forwardResult,
);

typedef RunTrainingStepNative = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Utf8> imagePath,
  Pointer<Utf8> textPrompt,
  Float learningRate,
);
typedef RunTrainingStepDart = Pointer<Utf8> Function(
  Pointer<Void> handle,
  Pointer<Utf8> imagePath,
  Pointer<Utf8> textPrompt,
  double learningRate,
);

typedef SaveCheckpointNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> filepath,
  Int32 epoch,
  Int32 step,
);
typedef SaveCheckpointDart = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> filepath,
  int epoch,
  int step,
);

typedef LoadCheckpointNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> filepath,
);
typedef LoadCheckpointDart = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> filepath,
);

typedef ExportModelGGUFNative = Int32 Function(
  Pointer<Void> handle,
  Pointer<Utf8> outputPath,
);
typedef ExportModelGGUFDart = int Function(
  Pointer<Void> handle,
  Pointer<Utf8> outputPath,
);

typedef FreeForwardResultNative = Void Function(Pointer<Void> forwardResult);
typedef FreeForwardResultDart = void Function(Pointer<Void> forwardResult);

class NativeBindings {
  final DynamicLibrary? _lib;

  NativeBindings() : _lib = _loadLibrary();

  static DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isAndroid || Platform.isLinux) {
        return DynamicLibrary.open('libmultimodal_trainer.so');
      } else if (Platform.isWindows) {
        return DynamicLibrary.open('multimodal_trainer.dll');
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  bool get isLoaded => _lib != null;

  late final LoadModelDart? loadModel = _lib
      ?.lookup<NativeFunction<LoadModelNative>>('loadModel')
      .asFunction<LoadModelDart>();

  late final UnloadModelDart? unloadModel = _lib
      ?.lookup<NativeFunction<UnloadModelNative>>('unloadModel')
      .asFunction<UnloadModelDart>();

  late final GetModelStatusDart? getModelStatus = _lib
      ?.lookup<NativeFunction<GetModelStatusNative>>('getModelStatus')
      .asFunction<GetModelStatusDart>();

  late final ForwardPassDart? forwardPass = _lib
      ?.lookup<NativeFunction<ForwardPassNative>>('forwardPass')
      .asFunction<ForwardPassDart>();

  late final GetForwardLossDart? getForwardLoss = _lib
      ?.lookup<NativeFunction<GetForwardLossNative>>('getForwardLoss')
      .asFunction<GetForwardLossDart>();

  late final BackwardPassDart? backwardPass = _lib
      ?.lookup<NativeFunction<BackwardPassNative>>('backwardPass')
      .asFunction<BackwardPassDart>();

  late final RunTrainingStepDart? runTrainingStep = _lib
      ?.lookup<NativeFunction<RunTrainingStepNative>>('runTrainingStep')
      .asFunction<RunTrainingStepDart>();

  late final SaveCheckpointDart? saveCheckpoint = _lib
      ?.lookup<NativeFunction<SaveCheckpointNative>>('saveCheckpoint')
      .asFunction<SaveCheckpointDart>();

  late final LoadCheckpointDart? loadCheckpoint = _lib
      ?.lookup<NativeFunction<LoadCheckpointNative>>('loadCheckpoint')
      .asFunction<LoadCheckpointDart>();

  late final ExportModelGGUFDart? exportModelGGUF = _lib
      ?.lookup<NativeFunction<ExportModelGGUFNative>>('exportModelGGUF')
      .asFunction<ExportModelGGUFDart>();

  late final FreeForwardResultDart? freeForwardResult = _lib
      ?.lookup<NativeFunction<FreeForwardResultNative>>('freeForwardResult')
      .asFunction<FreeForwardResultDart>();
}
