#include "llama.h"
#include <cstdlib>
#include <cstring>
#include <vector>

struct llama_model {
    char model_path[256];
    int32_t n_vocab = 32000;
    int32_t n_embd = 2048;
};

struct llama_context {
    llama_model* model;
    llama_context_params params;
    std::vector<float> logits;
};

struct llama_model_params llama_model_default_params(void) {
    struct llama_model_params params;
    params.n_gpu_layers = 0;
    params.vocab_only = false;
    params.use_mmap = true;
    params.use_mlock = false;
    return params;
}

struct llama_context_params llama_context_default_params(void) {
    struct llama_context_params params;
    params.seed = 1234;
    params.n_ctx = 2048;
    params.n_batch = 512;
    params.n_threads = 4;
    params.logits_all = false;
    params.embeddings = false;
    return params;
}

struct llama_model * llama_load_model_from_file(const char * path_model, struct llama_model_params /*params*/) {
    if (!path_model) return nullptr;
    auto* model = new llama_model();
    strncpy(model->model_path, path_model, sizeof(model->model_path) - 1);
    model->model_path[sizeof(model->model_path) - 1] = '\0';
    return model;
}

void llama_free_model(struct llama_model * model) {
    delete model;
}

struct llama_context * llama_new_context_with_model(struct llama_model * model, struct llama_context_params params) {
    if (!model) return nullptr;
    auto* ctx = new llama_context();
    ctx->model = model;
    ctx->params = params;
    ctx->logits.resize(model->n_vocab, 0.0f);
    return ctx;
}

void llama_free(struct llama_context * ctx) {
    delete ctx;
}

int32_t llama_n_vocab(const struct llama_model * model) {
    return model ? model->n_vocab : 0;
}

int32_t llama_n_ctx(const struct llama_context * ctx) {
    return ctx ? ctx->params.n_ctx : 0;
}

int32_t llama_n_embd(const struct llama_model * model) {
    return model ? model->n_embd : 0;
}

float * llama_get_logits(struct llama_context * ctx) {
    if (!ctx || ctx->logits.empty()) return nullptr;
    return ctx->logits.data();
}

int32_t llama_tokenize(
    const struct llama_model * /*model*/,
    const char * text,
    int32_t text_len,
    llama_token * tokens,
    int32_t n_max_tokens,
    bool /*add_special*/,
    bool /*parse_special*/
) {
    if (!text || !tokens || n_max_tokens <= 0) return 0;
    int count = 0;
    for (int i = 0; i < text_len && count < n_max_tokens; ++i) {
        tokens[count++] = static_cast<llama_token>(static_cast<unsigned char>(text[i]) + 10);
    }
    return count;
}

int32_t llama_decode(struct llama_context * ctx, struct llama_batch /*batch*/) {
    if (!ctx) return -1;
    // Simulate generation of logits
    for (size_t i = 0; i < ctx->logits.size(); ++i) {
        ctx->logits[i] = static_cast<float>((i % 100)) / 100.0f;
    }
    return 0;
}
