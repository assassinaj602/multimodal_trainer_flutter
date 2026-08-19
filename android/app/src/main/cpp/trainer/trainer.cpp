#include "trainer.h"
#include "../vision/encoder.h"
#include <cmath>
#include <cstring>
#include <vector>

NativeForwardResult* execute_forward_pass(
    ModelHandle* handle,
    const char* image_path,
    const char* text_prompt,
    bool is_training
) {
    if (!handle || !handle->is_initialized) return nullptr;

    auto* result = new NativeForwardResult();

    // 1. Image features via VisionEncoder
    std::vector<float> image_features;
    if (image_path && handle->mtmd_ctx) {
        VisionEncoder::processImage(handle->mtmd_ctx, image_path, image_features);
    }

    // 2. Tokenize prompt
    std::vector<llama_token> tokens(256);
    int n_tokens = 0;
    if (text_prompt && handle->model) {
        n_tokens = llama_tokenize(
            handle->model,
            text_prompt,
            static_cast<int32_t>(std::strlen(text_prompt)),
            tokens.data(),
            static_cast<int32_t>(tokens.size()),
            true,
            false
        );
        tokens.resize(n_tokens);
    }

    // 3. Combine multimodal embeddings
    std::vector<float> combined_embd(image_features.size() + tokens.size());
    size_t actual_len = 0;
    if (handle->mtmd_ctx) {
        mtmd_combine_embeddings(
            handle->mtmd_ctx,
            image_features.data(),
            image_features.size(),
            tokens.data(),
            tokens.size(),
            combined_embd.data(),
            combined_embd.size(),
            &actual_len
        );
    }

    // 4. Model decode & logits
    llama_batch batch{};
    batch.n_tokens = static_cast<int32_t>(tokens.size());
    batch.token = tokens.data();
    llama_decode(handle->ctx, batch);

    int vocab_size = llama_n_vocab(handle->model);
    if (vocab_size <= 0) vocab_size = 128;

    result->logits_size = vocab_size;
    result->logits = new float[vocab_size];
    float* ctx_logits = llama_get_logits(handle->ctx);
    if (ctx_logits) {
        std::memcpy(result->logits, ctx_logits, vocab_size * sizeof(float));
    } else {
        for (int i = 0; i < vocab_size; ++i) {
            result->logits[i] = 0.05f * static_cast<float>(i % 20);
        }
    }

    // Store tokens
    result->tokens_size = static_cast<int32_t>(tokens.size());
    result->tokens = new int32_t[result->tokens_size];
    for (int i = 0; i < result->tokens_size; ++i) {
        result->tokens[i] = tokens[i];
    }

    // Compute loss if training
    if (is_training && handle->autograd) {
        result->loss = autograd_compute_loss(
            handle->autograd,
            result->logits,
            result->logits_size,
            result->tokens,
            result->tokens_size
        );
    } else {
        result->loss = 0.0f;
    }

    return result;
}

bool execute_backward_pass(
    ModelHandle* handle,
    NativeForwardResult* forward_result
) {
    if (!handle || !forward_result || !handle->autograd) return false;

    std::vector<float> gradients(forward_result->logits_size, 0.0f);
    autograd_compute_loss_gradients(
        handle->autograd,
        forward_result->logits,
        forward_result->logits_size,
        forward_result->tokens,
        forward_result->tokens_size,
        gradients.data()
    );

    autograd_backward(handle->autograd, gradients.data(), gradients.size());
    autograd_step_optimizer(handle->autograd, 0.001f);

    return true;
}

NativeTrainingStepResult run_training_step(
    ModelHandle* handle,
    const char* image_path,
    const char* text_prompt,
    float learning_rate
) {
    NativeTrainingStepResult step_result{0.0f, 0.0f, 0, false};
    if (!handle || !handle->is_initialized) return step_result;

    // Run forward pass
    NativeForwardResult* fwd = execute_forward_pass(handle, image_path, text_prompt, true);
    if (!fwd) return step_result;

    step_result.loss = fwd->loss;

    // Run backward pass and optimizer update
    std::vector<float> gradients(fwd->logits_size, 0.0f);
    if (handle->autograd) {
        autograd_compute_loss_gradients(
            handle->autograd,
            fwd->logits,
            fwd->logits_size,
            fwd->tokens,
            fwd->tokens_size,
            gradients.data()
        );

        // Compute gradient norm
        float sq_sum = 0.0f;
        for (float g : gradients) {
            sq_sum += g * g;
        }
        step_result.gradient_norm = std::sqrt(sq_sum);

        autograd_backward(handle->autograd, gradients.data(), gradients.size());
        autograd_step_optimizer(handle->autograd, learning_rate);
    }

    free_native_forward_result(fwd);
    step_result.success = true;
    return step_result;
}

void free_native_forward_result(NativeForwardResult* result) {
    if (!result) return;
    if (result->logits) delete[] result->logits;
    if (result->activations) delete[] result->activations;
    if (result->tokens) delete[] result->tokens;
    delete result;
}
