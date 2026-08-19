# 🏛️ Architecture & System Design

**MobileFineTuner Multimodal Extension — Qwen3.5-2B (Flutter / C++ FFI)**  
*Duke Kunshan University — Edge Intelligence Lab*

---

## 1. High-Level Architecture Overview

The system bridges a reactive Flutter cross-platform UI with a high-performance native C++ engine via `dart:ffi`.

```mermaid
graph TD
    subgraph Flutter UI & Dart Layer
        A[HomeScreen / TrainingScreen] -->|State / Actions| B[TrainingProvider]
        B -->|Config / Dataset| C[TrainerService]
        C -->|Pointers / Buffers| D[NativeBridge]
        D -->|C ABI Invocation| E[NativeBindings dart:ffi]
    end

    subgraph Native C++ Layer libmultimodal_trainer.so
        E -->|loadModel / forwardPass / backwardPass| F[native_lib.cpp]
        F --> G[Model Manager model.cpp]
        F --> H[Vision Encoder encoder.cpp]
        F --> I[Trainer Engine trainer.cpp]
        
        G --> J[llama.cpp GGUF Engine]
        H --> K[libmtmd Vision Adapter]
        I --> L[MobileFineTuner Autograd & Optimizer]
    end

    subgraph Hardware & System
        J --> M[Android Emulator / VM CPU x86_64]
        L --> M
    end
```

---

## 2. Multimodal Data & Tensor Flow

```mermaid
sequenceDiagram
    autonumber
    participant UI as Flutter UI (TrainingScreen)
    participant Srv as TrainerService (Dart)
    participant FFI as NativeBridge (dart:ffi)
    participant Cpp as Native Core (trainer.cpp)
    participant VLM as libmtmd / llama.cpp
    participant Grad as MobileFineTuner Autograd

    UI->>Srv: startTraining(config, dataset)
    loop Each Sample in Dataset
        Srv->>FFI: runTrainingStep(imagePath, prompt, lr)
        FFI->>Cpp: runTrainingStep(handle, img, txt, lr)
        Cpp->>VLM: Encode Image Patches (libmtmd)
        Cpp->>VLM: Tokenize Prompt (llama_tokenize)
        Cpp->>VLM: Project Combined Embeddings (mtmd_combine)
        Cpp->>VLM: Forward Decode & Compute Logits (llama_decode)
        Cpp->>Grad: Compute Loss & Loss Gradients
        Cpp->>Grad: Backpropagate across Attention & Multimodal Layers
        Cpp->>Grad: Apply Optimizer Step (Parameter Update)
        Cpp-->>FFI: Return JSON {loss, gradient_norm, success}
        FFI-->>Srv: Yield TrainingStepEvent
        Srv-->>UI: Update Live Loss Graph & Progress Indicators
    end
```

---

## 3. Component Details

### 3.1 Flutter UI Layer
- **`TrainingProvider`**: Manages stream subscriptions, `fl_chart` loss history series, accuracy metrics, and step time estimates.
- **`LossGraph`**: GPU-accelerated real-time loss curve rendering with responsive downsampling and tooltips.
- **`LogViewer`**: Terminal log viewer with color tagging.
- **`DatasetScreen`**: In-app dataset preview and sample inspector.

### 3.2 `dart:ffi` Bridge Layer
- Native UTF-8 string allocation with immediate `malloc.free` cleanup to guarantee zero memory leaks.
- Opaque C handle management (`ModelHandle*`) isolating native heap structures from the Dart garbage collector.

### 3.3 C++ Native Core
- **`llama.cpp` Subsystem**: GGUF weight loader, KV-cache manager, context evaluator, and vocabulary mapper.
- **`libmtmd` Subsystem**: Vision transformer patch extractor (spatial token projector for Qwen3.5-VL).
- **`MobileFineTuner` Autograd Subsystem**: Dynamic computation graph evaluator, gradient accumulation buffers, and SGD/Adam optimizer.
- **Checkpoint & Export**: Binary state serialization (`MFTC` magic format) and full GGUF format model exporter.
