#include "model/model.h"
#include "trainer/trainer.h"
#include <android/log.h>
#include <cstring>

#define LOG_TAG "MultimodalTrainerNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

// 1. Model management
__attribute__((visibility("default")))
void* loadModel(const char* model_path) {
    LOGI("loadModel requested with path: %s", model_path ? model_path : "NULL");
    ModelHandle* handle = init_model_handle(model_path);
    return reinterpret_cast<void*>(handle);
}

__attribute__((visibility("default")))
void unloadModel(void* handle_ptr) {
    LOGI("unloadModel requested");
    if (!handle_ptr) return;
    auto* handle = reinterpret_cast<ModelHandle*>(handle_ptr);
    free_model_handle(handle);
}

__attribute__((visibility("default")))
const char* getModelStatus(void* handle_ptr) {
    auto* handle = reinterpret_cast<ModelHandle*>(handle_ptr);
    static std::string status_cache;
    status_cache = get_model_status_json(handle);
    return status_cache.c_str();
}

// 2. Training operations
__attribute__((visibility("default")))
void* forwardPass(
    void* handle_ptr,
    const char* image_path,
    const char* text_prompt,
    int32_t is_training
) {
    LOGI("forwardPass requested (training=%d)", is_training);
    auto* handle = reinterpret_cast<ModelHandle*>(handle_ptr);
    NativeForwardResult* result = execute_forward_pass(
        handle,
        image_path,
        text_prompt,
        is_training != 0
    );
    return reinterpret_cast<void*>(result);
}

__attribute__((visibility("default")))
float getForwardLoss(void* result_ptr) {
    if (!result_ptr) return 0.0f;
    auto* result = reinterpret_cast<NativeForwardResult*>(result_ptr);
    return result->loss;
}

__attribute__((visibility("default")))
int32_t backwardPass(void* handle_ptr, void* forward_result_ptr) {
    LOGI("backwardPass requested");
    auto* handle = reinterpret_cast<ModelHandle*>(handle_ptr);
    auto* result = reinterpret_cast<NativeForwardResult*>(forward_result_ptr);
    bool ok = execute_backward_pass(handle, result);
    return ok ? 1 : 0;
}

__attribute__((visibility("default")))
void freeForwardResult(void* result_ptr) {
    if (!result_ptr) return;
    auto* result = reinterpret_cast<NativeForwardResult*>(result_ptr);
    free_native_forward_result(result);
}

}
