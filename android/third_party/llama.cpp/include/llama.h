#ifndef LLAMA_H
#define LLAMA_H

#include "ggml.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

struct llama_model;
struct llama_context;

typedef int32_t llama_token;

struct llama_model_params {
    int32_t n_gpu_layers;
    bool vocab_only;
    bool use_mmap;
    bool use_mlock;
};

struct llama_context_params {
    uint32_t seed;
    uint32_t n_ctx;
    uint32_t n_batch;
    uint32_t n_threads;
    bool logits_all;
    bool embeddings;
};

struct llama_batch {
    int32_t n_tokens;
    llama_token * token;
    float * embd;
    int32_t * pos;
    int32_t * n_seq_id;
    int32_t ** seq_id;
    int8_t * logits;
};

struct llama_model_params llama_model_default_params(void);
struct llama_context_params llama_context_default_params(void);

struct llama_model * llama_load_model_from_file(const char * path_model, struct llama_model_params params);
void llama_free_model(struct llama_model * model);

struct llama_context * llama_new_context_with_model(struct llama_model * model, struct llama_context_params params);
void llama_free(struct llama_context * ctx);

int32_t llama_n_vocab(const struct llama_model * model);
int32_t llama_n_ctx(const struct llama_context * ctx);
int32_t llama_n_embd(const struct llama_model * model);

float * llama_get_logits(struct llama_context * ctx);
int32_t llama_tokenize(
    const struct llama_model * model,
    const char * text,
    int32_t text_len,
    llama_token * tokens,
    int32_t n_max_tokens,
    bool add_special,
    bool parse_special
);

int32_t llama_decode(struct llama_context * ctx, struct llama_batch batch);

#ifdef __cplusplus
}
#endif

#endif // LLAMA_H
