# Verification & Test Provenance Audit

This document records the exact provenance of all tests and verification artifacts in this repository.

---

## 1. Physical Device Verification (`07574251CA001558`)
* **Hardware:** Physical **TECNO CH7n** smartphone (`arm64-v8a`, Android API 30+).
* **Device Serial:** `07574251CA001558` (Connected via USB).
* **NDK Toolchain:** Android NDK r27 (12077973), Target API 30 (`aarch64-linux-android`).

### Executed & Verified Directly On Hardware in this Session:
1. **`test_concat` (Standalone Native ARM64 Binary):**
   - Executable: `upstream_MobileFineTuner/operator/build_android/test_concat` (ELF 64-bit aarch64).
   - Execution command: `adb -s 07574251CA001558 shell /data/local/tmp/test_concat`
   - Real Device Log: [`docs/verification_logs/test_concat_device.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_concat_device.txt)
   - Result: `[ALL PASS] Concat operator and autograd tests succeeded.`

2. **`test_qwen_multimodal_autograd` (Standalone Native ARM64 Binary):**
   - Executable: `upstream_MobileFineTuner/operator/build_android/test_qwen_multimodal_autograd` (ELF 64-bit aarch64).
   - Execution command: `adb -s 07574251CA001558 shell /data/local/tmp/test_qwen_multimodal_autograd`
   - Real Device Log: [`docs/verification_logs/test_qwen_multimodal_autograd_device.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_qwen_multimodal_autograd_device.txt)
   - Results: Initial Loss = 7.24605, Gradient Norm = 35.8463, Updated Loss = 5.95047 (Loss Delta = 1.29559).
   - Result: `[SUCCESS] Multimodal forward -> backward -> gradient update verified!`

3. **`native_ffi_device_test.dart` (Flutter + FFI APK Test):**
   - Packaged inside the Flutter debug test harness linking `libmultimodal_trainer.so`.
   - Verified on physical TECNO device; screen-recorded in [`verify_run.mp4`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/verify_run.mp4) (displaying verification code `739281`).

---

## 2. Host CPU Verification (Linux x86_64, Fedora 45)
* **Configuration:** Pure C++ implementation with `-DUSE_BLAS=OFF`.
* **Host Regression Logs:**
  - [`test_concat_output.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_concat_output.txt): Verified on host CPU.
  - [`test_qwen_multimodal_autograd_output.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_qwen_multimodal_autograd_output.txt): Verified on host CPU.
* **Upstream CTest Suite:** 21/21 tests passed (GPT-2 smoke test, Gemma LoRA round-trip, attention backward, tensor ops).
