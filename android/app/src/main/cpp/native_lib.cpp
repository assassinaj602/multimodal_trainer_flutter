#include <jni.h>
#include <string>
#include <android/log.h>

#define LOG_TAG "MultimodalTrainerNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

extern "C" {

JNIEXPORT const char* JNICALL loadModel(const char* model_path) {
    LOGI("Loading model from path: %s", model_path);
    return "SUCCESS_MODEL_LOADED";
}

JNIEXPORT void JNICALL unloadModel(const char* handle) {
    LOGI("Unloading model handle");
}

}
