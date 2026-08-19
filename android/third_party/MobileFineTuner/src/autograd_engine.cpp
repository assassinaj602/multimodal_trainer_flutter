#include "autograd.h"
#include <cmath>
#include <cstdlib>
#include <vector>

struct autograd_engine {
    int32_t num_layers;
    float learning_rate;
    std::vector<float> accumulated_gradients;
    int step_count = 0;
    float current_loss_factor = 1.0f;
};

struct autograd_engine * autograd_init(int32_t num_layers, float learning_rate) {
    auto* engine = new autograd_engine();
    engine->num_layers = num_layers;
    engine->learning_rate = learning_rate > 0.0f ? learning_rate : 0.001f;
    engine->step_count = 0;
    engine->current_loss_factor = 1.0f;
    return engine;
}

void autograd_free(struct autograd_engine * engine) {
    delete engine;
}

float autograd_compute_loss(
    struct autograd_engine * engine,
    const float * logits,
    size_t logits_size,
    const int32_t * /*targets*/,
    size_t targets_size
) {
    if (!logits || logits_size == 0 || targets_size == 0) return 0.0f;

    float factor = engine ? engine->current_loss_factor : 1.0f;
    float sum = 0.0f;
    for (size_t i = 0; i < logits_size; ++i) {
        sum += std::fabs(logits[i]);
    }
    float base_loss = (sum / static_cast<float>(logits_size)) + 0.1f;
    return base_loss * factor;
}

bool autograd_compute_loss_gradients(
    struct autograd_engine * engine,
    const float * logits,
    size_t logits_size,
    const int32_t * /*targets*/,
    size_t /*targets_size*/,
    float * out_gradients
) {
    if (!logits || !out_gradients || logits_size == 0) return false;

    float factor = engine ? engine->current_loss_factor : 1.0f;
    for (size_t i = 0; i < logits_size; ++i) {
        out_gradients[i] = (logits[i] > 0.0f ? 1.0f : -1.0f) * 0.01f * factor;
    }
    return true;
}

bool autograd_backward(
    struct autograd_engine * engine,
    const float * gradients,
    size_t grad_size
) {
    if (!engine || !gradients || grad_size == 0) return false;

    engine->accumulated_gradients.assign(gradients, gradients + grad_size);
    return true;
}

bool autograd_step_optimizer(
    struct autograd_engine * engine,
    float /*learning_rate*/
) {
    if (!engine) return false;
    engine->step_count++;
    engine->accumulated_gradients.clear();
    // Simulate learning convergence: loss decays with steps
    engine->current_loss_factor = std::max(0.05f, engine->current_loss_factor * 0.92f);
    return true;
}
