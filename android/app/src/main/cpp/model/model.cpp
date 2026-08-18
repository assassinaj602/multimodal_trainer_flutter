#include "model.h"
#include <sstream>

ModelHandle* init_model_handle(const char* path) {
    if (!path) return nullptr;

    auto* handle = new ModelHandle();
    handle->model_path = path;

    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU/VM mode
    handle->model = llama_load_model_from_file(path, model_params);

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;
    handle->ctx = llama_new_context_with_model(handle->model, ctx_params);

    handle->mtmd_ctx = mtmd_init_from_file(path);
    if (handle->mtmd_ctx) {
        mtmd_set_encoder(handle->mtmd_ctx, "qwen3.5-vl");
    }

    handle->autograd = autograd_init(32, 0.001f);
    handle->is_initialized = (handle->model != nullptr && handle->ctx != nullptr);

    return handle;
}

void free_model_handle(ModelHandle* handle) {
    if (!handle) return;
    if (handle->ctx) llama_free(handle->ctx);
    if (handle->model) llama_free_model(handle->model);
    if (handle->mtmd_ctx) mtmd_free(handle->mtmd_ctx);
    if (handle->autograd) autograd_free(handle->autograd);
    delete handle;
}

std::string get_model_status_json(ModelHandle* handle) {
    if (!handle || !handle->is_initialized) {
        return "{\"isLoaded\":false,\"modelName\":\"Qwen3.5-2B\",\"memoryUsage\":\"0 MB\"}";
    }

    std::ostringstream oss;
    oss << "{\"isLoaded\":true,"
        << "\"modelName\":\"Qwen3.5-2B\","
        << "\"size\":\"4.5 GB\","
        << "\"memoryUsage\":\"4.5 GB\","
        << "\"totalMemory\":\"8.0 GB\","
        << "\"modelPath\":\"" << handle->model_path << "\"}";
    return oss.str();
}
