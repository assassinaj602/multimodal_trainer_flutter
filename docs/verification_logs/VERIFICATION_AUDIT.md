# Verification & Test Provenance Audit

This document records the exact provenance of all tests and verification artifacts in this repository to maintain complete engineering accuracy.

---

## 1. Physical Device Verification (`07574251CA001558`)
* **Hardware:** Physical **TECNO CH7n** smartphone (`arm64-v8a`, Android API 30+).
* **Test Executed On Device:** `integration_test/native_ffi_device_test.dart`
  - Compiled and packaged inside the Flutter debug APK loading `libmultimodal_trainer.so`.
  - Executed directly on hardware; recorded in [`verify_run.mp4`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/verify_run.mp4) (displaying on-screen verification code `739281`).
  - Verified native FFI symbol loading, model initialization, multimodal step execution, and gradient calculation on Android ARM64.

---

## 2. Host CPU Verification (Linux x86_64, October 26, 2026)
* **Environment:** Linux x86_64 (Fedora 45, GCC 16.2.1, Ninja 1.13.2).
* **Configuration:** Pure C++ implementation with `-DUSE_BLAS=OFF`.
* **Provenance of `.txt` Log Files:**
  - [`test_concat_output.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_concat_output.txt): Generated on the **Linux host CPU**.
  - [`test_qwen_multimodal_autograd_output.txt`](file:///home/assassinaj602/Projects/New%20folder%20%284%29/github_pr/mobile_fine_tuner/multimodal_trainer_flutter/docs/verification_logs/test_qwen_multimodal_autograd_output.txt): Generated on the **Linux host CPU**.
* **Note:** These two logs are **host runs** that verify mathematical correctness of the autograd algorithms. They were **not** executed via ADB on the physical device in this session.

---

## 3. Precompiled Device Binaries & Deployment Guide
The standalone test executables have already been compiled for Android ARM64 using NDK r27:
- `upstream_MobileFineTuner/operator/build_android/test_concat` (5.5 MB, ELF 64-bit aarch64)
- `upstream_MobileFineTuner/operator/build_android/test_qwen_multimodal_autograd` (7.5 MB, ELF 64-bit aarch64)

### To run them directly on the physical phone over USB:
```bash
# 1. Connect phone and verify
adb devices
# Expected output: 07574251CA001558 device

# 2. Push executables to phone scratch directory
adb -s 07574251CA001558 push upstream_MobileFineTuner/operator/build_android/test_concat /data/local/tmp/
adb -s 07574251CA001558 push upstream_MobileFineTuner/operator/build_android/test_qwen_multimodal_autograd /data/local/tmp/

# 3. Mark executable
adb -s 07574251CA001558 shell chmod +x /data/local/tmp/test_concat
adb -s 07574251CA001558 shell chmod +x /data/local/tmp/test_qwen_multimodal_autograd

# 4. Execute on device and save raw output
adb -s 07574251CA001558 shell /data/local/tmp/test_concat | tee docs/verification_logs/test_concat_device.txt
adb -s 07574251CA001558 shell /data/local/tmp/test_qwen_multimodal_autograd | tee docs/verification_logs/test_qwen_multimodal_autograd_device.txt
```
