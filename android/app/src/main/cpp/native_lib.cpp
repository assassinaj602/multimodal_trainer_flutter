#include "trainer/multimodal_engine.h"
#include <android/log.h>
#include <cstring>
#include <sstream>

#define LOG_TAG "MultimodalTrainerNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C" {

// 1. Model management
__attribute__((visibility("default")))
void* loadModel(const char* model_path) {
    LOGI("loadModel requested with path: %s", model_path ? model_path : "NULL");
    MultimodalTrainerState* handle = init_multimodal_trainer(model_path);
    return reinterpret_cast<void*>(handle);
}

__attribute__((visibility("default")))
void unloadModel(void* handle_ptr) {
    LOGI("unloadModel requested");
    if (!handle_ptr) return;
    auto* handle = reinterpret_cast<MultimodalTrainerState*>(handle_ptr);
    free_multimodal_trainer(handle);
}

__attribute__((visibility("default")))
const char* getModelStatus(void* handle_ptr) {
    auto* handle = reinterpret_cast<MultimodalTrainerState*>(handle_ptr);
    static std::string status_cache;
    status_cache = get_multimodal_status_json(handle);
    return status_cache.c_str();
}

// 2. Training operations
__attribute__((visibility("default")))
const char* runTrainingStep(
    void* handle_ptr,
    const char* image_path,
    const char* text_prompt,
    float learning_rate
) {
    LOGI("runTrainingStep requested with lr=%.5f, prompt=%s", learning_rate, text_prompt ? text_prompt : "NULL");
    auto* handle = reinterpret_cast<MultimodalTrainerState*>(handle_ptr);
    MultimodalStepResult step = execute_multimodal_training_step(handle, image_path, text_prompt, learning_rate);

    static std::string step_json_cache;
    std::ostringstream oss;
    oss << "{\"loss\":" << step.loss
        << ",\"gradient_norm\":" << step.gradient_norm
        << ",\"success\":" << (step.success ? "true" : "false")
        << "}";
    step_json_cache = oss.str();
    return step_json_cache.c_str();
}

// 3. Checkpointing & Model Export
__attribute__((visibility("default")))
int32_t saveCheckpoint(
    void* handle_ptr,
    const char* filepath,
    int32_t epoch,
    int32_t step
) {
    LOGI("saveCheckpoint requested: %s (epoch=%d, step=%d)", filepath ? filepath : "NULL", epoch, step);
    return 1;
}

__attribute__((visibility("default")))
int32_t loadCheckpoint(
    void* handle_ptr,
    const char* filepath
) {
    LOGI("loadCheckpoint requested: %s", filepath ? filepath : "NULL");
    return 1;
}

__attribute__((visibility("default")))
int32_t exportModelGGUF(
    void* handle_ptr,
    const char* output_path
) {
    LOGI("exportModelGGUF requested: %s", output_path ? output_path : "NULL");
    return 1;
}

__attribute__((visibility("default")))
void freeForwardResult(void* result_ptr) {
    // No-op for unified JSON step API
}

}

