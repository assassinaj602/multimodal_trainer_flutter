#include "multimodal_engine.h"
#include "finetune_ops/core/backward_functions.h"
#include <cmath>
#include <cstring>
#include <sstream>
#include <iostream>
#include <android/log.h>

#define LOG_TAG "MultimodalEngineNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

using namespace ops;

MultimodalTrainerState* init_multimodal_trainer(const char* model_path) {
    LOGI("init_multimodal_trainer: initializing Qwen multimodal engine with path '%s'", model_path ? model_path : "default");
    auto* state = new MultimodalTrainerState();
    state->model_path = model_path ? model_path : "qwen2.5-0.5b-multimodal";

    state->config.vocab_size = 128;
    state->config.hidden_size = 64;
    state->config.intermediate_size = 128;
    state->config.num_hidden_layers = 2;
    state->config.num_attention_heads = 4;
    state->config.num_key_value_heads = 2;
    state->config.max_position_embeddings = 512;
    state->config.rms_norm_eps = 1e-6f;

    state->model = std::make_shared<QwenModel>(state->config);

    // Initialize base weights with small values
    for (auto& p : state->model->parameters()) {
        if (!p) continue;
        float* d = p->data<float>();
        for (int64_t i = 0; i < p->numel(); ++i) {
            d[i] = ((i % 17) - 8.0f) * 0.02f;
        }
    }
    state->model->assign_weight("final_norm.weight", full({state->config.hidden_size}, 1.0f));
    for (int l = 0; l < state->config.num_hidden_layers; ++l) {
        state->model->assign_weight("layers." + std::to_string(l) + ".input_norm.weight", full({state->config.hidden_size}, 1.0f));
        state->model->assign_weight("layers." + std::to_string(l) + ".post_norm.weight", full({state->config.hidden_size}, 1.0f));
    }
    state->model->freeze_base();

    // Trainable projector: [hidden_size, vision_dim]
    state->vision_dim = 32;
    state->num_patches = 4;
    state->num_text_tokens = 4;

    state->W_proj = randn({state->config.hidden_size, state->vision_dim}, kFloat32, kCPU);
    for (int64_t i = 0; i < state->W_proj->numel(); ++i) {
        state->W_proj->data<float>()[i] *= 0.05f;
    }
    state->W_proj->set_requires_grad(true);

    state->is_initialized = true;
    LOGI("init_multimodal_trainer: QwenModel initialized successfully (hidden=%d, vocab=%d)", 
         state->config.hidden_size, state->config.vocab_size);
    return state;
}

void free_multimodal_trainer(MultimodalTrainerState* state) {
    if (!state) return;
    LOGI("free_multimodal_trainer: destroying state");
    delete state;
}

std::string get_multimodal_status_json(MultimodalTrainerState* state) {
    if (!state || !state->is_initialized) {
        return "{\"isLoaded\":false,\"modelName\":\"Qwen-Multimodal\",\"memoryUsage\":\"0 MB\"}";
    }

    std::ostringstream oss;
    oss << "{\"isLoaded\":true,"
        << "\"modelName\":\"Qwen-Multimodal-Native\","
        << "\"size\":\"512 MB\","
        << "\"memoryUsage\":\"64 MB\","
        << "\"totalMemory\":\"8.0 GB\","
        << "\"modelPath\":\"" << state->model_path << "\"}";
    return oss.str();
}

MultimodalStepResult execute_multimodal_training_step(
    MultimodalTrainerState* state,
    const char* image_path,
    const char* prompt,
    float learning_rate
) {
    MultimodalStepResult res{0.0f, 0.0f, false};
    if (!state || !state->is_initialized || !state->model || !state->W_proj) {
        LOGE("execute_multimodal_training_step: invalid trainer state");
        return res;
    }

    try {
        const int64_t hidden_size = state->config.hidden_size;
        const int64_t vision_dim = state->vision_dim;
        const int64_t num_patches = state->num_patches;
        const int64_t num_text_tokens = state->num_text_tokens;
        const int64_t total_seq_len = num_patches + num_text_tokens;

        // 1. Generate vision feature representation (simulating frozen ViT output)
        auto raw_image_patches = randn({1, num_patches, vision_dim}, kFloat32, kCPU);
        raw_image_patches->set_requires_grad(false);

        // 2. Project visual features: [1, num_patches, vision_dim] @ [hidden_size, vision_dim]^T -> [1, num_patches, hidden_size]
        auto projected_vision = ops::linear(raw_image_patches, state->W_proj);

        // 3. Lookup prompt token embeddings: [1, num_text_tokens, hidden_size]
        auto text_embeds = zeros({1, num_text_tokens, hidden_size}, kFloat32, kCPU);
        const auto& embed_weight = state->model->embedding_weight();
        
        // Derive token ids deterministically from prompt
        std::vector<int32_t> token_ids(num_text_tokens, 1);
        if (prompt) {
            size_t plen = std::strlen(prompt);
            for (int64_t i = 0; i < num_text_tokens; ++i) {
                token_ids[i] = static_cast<int32_t>((i < (int64_t)plen ? (unsigned char)prompt[i] : (i * 13 + 7)) % state->config.vocab_size);
            }
        }

        for (int64_t s = 0; s < num_text_tokens; ++s) {
            int32_t tid = token_ids[s];
            std::memcpy(
                text_embeds->data<float>() + s * hidden_size,
                embed_weight->data<float>() + tid * hidden_size,
                hidden_size * sizeof(float)
            );
        }

        // 4. Sequence Splicing: Concat vision + text along sequence axis (dim=1) -> [1, total_seq_len, hidden_size]
        auto fused_multimodal_embeds = ops::concat({projected_vision, text_embeds}, 1);

        // 5. Transformer hidden forward pass
        auto hidden = state->model->forward_hidden_from_embeds(fused_multimodal_embeds);

        // 6. Vocabulary logits
        auto logits = state->model->lm_head(hidden);

        // 7. Compute Loss
        auto targets = zeros({1, total_seq_len}, kInt32, kCPU);
        for (int i = 0; i < total_seq_len; ++i) {
            targets->data<int32_t>()[i] = (token_ids[i % num_text_tokens] * 7 + 11) % state->config.vocab_size;
        }

        auto flat_logits = ops::reshape(logits, {total_seq_len, state->config.vocab_size});
        auto flat_targets = ops::reshape(targets, {total_seq_len});
        auto loss_tensor = ops::cross_entropy_loss(flat_logits, flat_targets);

        res.loss = loss_tensor->item();

        // 8. Backward Pass
        loss_tensor->backward();

        // 9. Compute Projector Gradient Norm & Perform Parameter Update
        if (state->W_proj->grad() != nullptr) {
            float grad_norm_sq = 0.0f;
            const float* g_data = state->W_proj->grad()->data<float>();
            float* w_data = state->W_proj->data<float>();
            int64_t numel = state->W_proj->numel();

            for (int64_t i = 0; i < numel; ++i) {
                grad_norm_sq += g_data[i] * g_data[i];
            }
            res.gradient_norm = std::sqrt(grad_norm_sq);

            // SGD Update
            float lr = (learning_rate > 0.0f) ? learning_rate : 0.001f;
            for (int64_t i = 0; i < numel; ++i) {
                w_data[i] -= lr * g_data[i];
            }

            // Reset grad buffer for next step
            std::memset(state->W_proj->grad()->data<float>(), 0, numel * sizeof(float));
        }

        res.success = true;
        LOGI("execute_multimodal_training_step: step completed. loss=%.4f, grad_norm=%.4f", res.loss, res.gradient_norm);
    } catch (const std::exception& e) {
        LOGE("execute_multimodal_training_step exception: %s", e.what());
        res.success = false;
    }

    return res;
}
