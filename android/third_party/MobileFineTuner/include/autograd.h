#ifndef AUTOGRAD_H
#define AUTOGRAD_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

struct autograd_engine;

struct autograd_engine * autograd_init(int32_t num_layers, float learning_rate);
void autograd_free(struct autograd_engine * engine);

float autograd_compute_loss(
    struct autograd_engine * engine,
    const float * logits,
    size_t logits_size,
    const int32_t * targets,
    size_t targets_size
);

bool autograd_compute_loss_gradients(
    struct autograd_engine * engine,
    const float * logits,
    size_t logits_size,
    const int32_t * targets,
    size_t targets_size,
    float * out_gradients
);

bool autograd_backward(
    struct autograd_engine * engine,
    const float * gradients,
    size_t grad_size
);

bool autograd_step_optimizer(
    struct autograd_engine * engine,
    float learning_rate
);

#ifdef __cplusplus
}
#endif

#endif // AUTOGRAD_H
