# On-Device Verification Logs

## 1. Physical Device Specification
- **Device Model:** TECNO CH7n (Android arm64-v8a)
- **Device Serial:** `07574251CA001558`
- **NDK Toolchain:** Android NDK r27 (12077973), Target API 30 (`aarch64-linux-android`)

## 2. On-Device Integration Test Verification
- **Test File:** `integration_test/native_ffi_device_test.dart`
- **Execution Run:** Captured in `verify_run.mp4` (showing on-screen verification code `739281` and `libmultimodal_trainer.so` execution).
- **Core Pipeline Tested:**
  1. `loadModel('qwen2.5-0.5b-native-device')`
  2. `getModelStatus()` returning native handle JSON
  3. `runTrainingStep()` executing genuine multimodal sequence projection, splicing, forward, backward pass, and parameter update through `dart:ffi`.

## 3. Standalone C++ Binary Verification
Precompiled ARM64 ELF binaries located in `upstream_MobileFineTuner/operator/build_android/`:
- `test_concat`: 5,497,024 bytes (ELF 64-bit LSB pie executable, ARM aarch64)
- `test_qwen_multimodal_autograd`: 7,531,344 bytes (ELF 64-bit LSB pie executable, ARM aarch64)

### Execution Commands on Device:
```bash
# Push binaries to physical device
adb -s 07574251CA001558 push upstream_MobileFineTuner/operator/build_android/test_concat /data/local/tmp/
adb -s 07574251CA001558 push upstream_MobileFineTuner/operator/build_android/test_qwen_multimodal_autograd /data/local/tmp/

# Grant execution permissions
adb -s 07574251CA001558 shell chmod +x /data/local/tmp/test_concat
adb -s 07574251CA001558 shell chmod +x /data/local/tmp/test_qwen_multimodal_autograd

# Run test_concat
adb -s 07574251CA001558 shell /data/local/tmp/test_concat

# Run test_qwen_multimodal_autograd
adb -s 07574251CA001558 shell /data/local/tmp/test_qwen_multimodal_autograd
```
Raw outputs matching these executions are documented in:
- `test_concat_output.log`
- `test_qwen_multimodal_autograd_output.log`
