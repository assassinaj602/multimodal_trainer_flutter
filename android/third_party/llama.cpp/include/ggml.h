#ifndef GGML_H
#define GGML_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

enum ggml_type {
    GGML_TYPE_F32  = 0,
    GGML_TYPE_F16  = 1,
    GGML_TYPE_Q4_0 = 2,
    GGML_TYPE_Q4_1 = 3,
    GGML_TYPE_Q8_0 = 8,
    GGML_TYPE_COUNT,
};

struct ggml_tensor {
    enum ggml_type type;
    int n_dims;
    int64_t ne[4]; // number of elements
    size_t nb[4];  // stride in bytes
    void * data;
    char name[64];
    struct ggml_tensor * grad;
};

struct ggml_context;

struct ggml_init_params {
    size_t mem_size;
    void * mem_buffer;
    bool no_alloc;
};

struct ggml_context * ggml_init(struct ggml_init_params params);
void ggml_free(struct ggml_context * ctx);
struct ggml_tensor * ggml_new_tensor_1d(struct ggml_context * ctx, enum ggml_type type, int64_t ne0);
struct ggml_tensor * ggml_new_tensor_2d(struct ggml_context * ctx, enum ggml_type type, int64_t ne0, int64_t ne1);

#ifdef __cplusplus
}
#endif

#endif // GGML_H
