import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

class NativeBindings {
  final DynamicLibrary? _lib;

  NativeBindings() : _lib = _loadLibrary();

  static DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isAndroid) {
        return DynamicLibrary.open('libmultimodal_trainer.so');
      } else if (Platform.isLinux) {
        return DynamicLibrary.open('libmultimodal_trainer.so');
      }
    } catch (e) {
      // Library not loaded yet in stub/mock stage
      return null;
    }
    return null;
  }

  bool get isLoaded => _lib != null;

  late final Pointer<Utf8> Function(Pointer<Utf8> modelPath)? loadModel = _lib?.lookup<NativeFunction<Pointer<Utf8> Function(Pointer<Utf8>)>>('loadModel').asFunction();

  late final void Function(Pointer<Utf8> handle)? unloadModel = _lib?.lookup<NativeFunction<Void Function(Pointer<Utf8>)>>('unloadModel').asFunction();
}
