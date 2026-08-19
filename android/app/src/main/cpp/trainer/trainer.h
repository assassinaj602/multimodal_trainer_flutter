#ifndef TRAINER_H
#define TRAINER_H

#include "../model/model.h"
#include <vector>
#include <string>

struct NativeForwardResult {
    float* logits = nullptr;
    int32_t logits_size = 0;
    float loss = 0.0f;
    float* activations = nullptr;
    int32_t activations_size = 0;
    int32_t* tokens = nullptr;
    int32_t tokens_size = 0;
};

struct NativeTrainingStepResult {
    float loss;
    float gradient_norm;
    int32_t step_index;
    bool success;
};

NativeForwardResult* execute_forward_pass(
    ModelHandle* handle,
    const char* image_path,
    const char* text_prompt,
    bool is_training
);

bool execute_backward_pass(
    ModelHandle* handle,
    NativeForwardResult* forward_result
);

NativeTrainingStepResult run_training_step(
    ModelHandle* handle,
    const char* image_path,
    const char* text_prompt,
    float learning_rate
);

bool save_model_checkpoint(
    ModelHandle* handle,
    const char* filepath,
    int32_t epoch,
    int32_t step
);

bool load_model_checkpoint(
    ModelHandle* handle,
    const char* filepath
);

bool export_model_gguf(
    ModelHandle* handle,
    const char* output_path
);

void free_native_forward_result(NativeForwardResult* result);

#endif // TRAINER_H
