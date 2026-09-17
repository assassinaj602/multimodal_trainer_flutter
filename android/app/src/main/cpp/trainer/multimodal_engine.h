#pragma once

#include "finetune_ops/core/tensor.h"
#include "finetune_ops/graph/qwen_model.h"
#include "finetune_ops/core/ops.h"
#include <string>
#include <vector>
#include <memory>

struct MultimodalTrainerState {
    std::shared_ptr<ops::QwenModel> model;
    ops::QwenConfig config;
    ops::TensorPtr W_proj; // [hidden_size, vision_dim] trainable projector
    int64_t vision_dim = 32;
    int64_t num_patches = 4;
    int64_t num_text_tokens = 4;
    std::string model_path;
    bool is_initialized = false;
};

MultimodalTrainerState* init_multimodal_trainer(const char* model_path);
void free_multimodal_trainer(MultimodalTrainerState* state);
std::string get_multimodal_status_json(MultimodalTrainerState* state);

struct MultimodalStepResult {
    float loss;
    float gradient_norm;
    bool success;
};

MultimodalStepResult execute_multimodal_training_step(
    MultimodalTrainerState* state,
    const char* image_path,
    const char* prompt,
    float learning_rate
);
