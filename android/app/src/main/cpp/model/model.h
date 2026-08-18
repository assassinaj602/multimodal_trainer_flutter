#ifndef MODEL_H
#define MODEL_H

#include "llama.h"
#include "mtmd.h"
#include "autograd.h"
#include <string>

struct ModelHandle {
    llama_model* model = nullptr;
    llama_context* ctx = nullptr;
    mtmd_context* mtmd_ctx = nullptr;
    autograd_engine* autograd = nullptr;
    std::string model_path;
    bool is_initialized = false;
};

ModelHandle* init_model_handle(const char* path);
void free_model_handle(ModelHandle* handle);
std::string get_model_status_json(ModelHandle* handle);

#endif // MODEL_H
