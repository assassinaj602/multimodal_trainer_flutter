# 🚀 Multimodal Trainer Flutter (Qwen3.5-2B)

**MobileFineTuner Extension for Vision-Language Model (VLM) Fine-Tuning**  
*Duke Kunshan University — Edge Intelligence Lab*

---

## 📌 Project Overview
This project extends **MobileFineTuner** with Vision-Language Model (VLM) training capabilities using **Qwen3.5-2B**, integrated via **llama.cpp** and **libmtmd** native libraries over `dart:ffi`. 

The primary goal of this phase is to establish the end-to-end forward/backward fine-tuning pipeline correctness in an Android Emulator environment.

---

## 📐 Development Status & Checklist

### Phase 1: Project Setup & Environment Configuration ✅
- [x] Flutter project structure initialized with `com.duke.multimodal`
- [x] Android SDK `minSdkVersion` configured to **30** (Android 11+)
- [x] Dependencies added (`provider`, `ffi`, `path_provider`, `fl_chart`, `cupertino_icons`)
- [x] Native C++ CMake bridge directory setup (`android/app/src/main/cpp/`)
- [x] Asset pipeline configured (`assets/models/`, `assets/datasets/`, `assets/sample_data/`)
- [x] Basic Flutter skeleton app UI created (Material 3 Theme, Provider State Management)

### Phase 2: Native C++ Library Integration ✅
- [x] Integrated `llama.cpp` C/C++ engine and headers (`llama.h`, `ggml.h`)
- [x] Integrated `libmtmd` vision encoder interface for Qwen3.5-VL (`mtmd.h`)
- [x] Integrated `MobileFineTuner` autograd and backward engine (`autograd.h`)
- [x] Configured native bridge via CMake (`CMakeLists.txt` compiling `libmultimodal_trainer.so`)
- [x] Implemented native C exports: `loadModel()`, `unloadModel()`, `getModelStatus()`, `forwardPass()`, `backwardPass()`
- [x] Generated Dart FFI bindings (`native_bindings.dart`) and `NativeBridge` service

### Phase 3: Core Model Implementation & Training Pipeline ✅
- [x] Implemented multimodal forward pass in C++ combining image features and token embeddings
- [x] Implemented autograd backward propagation and gradient accumulation
- [x] Implemented `run_training_step()` in C++ and `runTrainingStep` native FFI export
- [x] Implemented stream-based asynchronous `trainStream` in `TrainerService`
- [x] Created 10-sample multimodal test dataset in `assets/datasets/sample_dataset.json`
- [x] Verified 10-step training loop with loss convergence in unit test suite

### Phase 4: Data Pipeline & UI Integration ✅
- [x] Implemented complete dataset loading and preview pipeline in `DatasetService`
- [x] Created interactive UI screens: `HomeScreen` (with NavigationBar), `TrainingScreen`, `DatasetScreen`, `GraphScreen`
- [x] Built real-time `fl_chart` loss visualization component (`LossGraph`) with live step updates
- [x] Implemented auto-scrolling monospace console stream viewer (`LogViewer`) with color-coded tags
- [x] Wired reactive `TrainingProvider`, `ModelProvider`, and `AppState` with full state management
- [x] Verified full UI navigation, dataset interaction, and training loop via `ui_integration_test.dart`

---

## 💻 Android Emulator / AVD Recommended Configuration
- **Device Spec**: Pixel 4 / Pixel 6
- **API Level**: API 30+ (Android 11 or higher)
- **Architecture**: `x86_64`
- **RAM**: 8GB
- **Internal Storage**: 20GB
- **Graphics Acceleration**: Hardware - GLES 2.0 / Automatic

---

## 🛠️ Build Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Analyze code:**
   ```bash
   flutter analyze
   ```

3. **Run tests:**
   ```bash
   flutter test
   ```

4. **Run on Android Emulator:**
   ```bash
   flutter run
   ```
