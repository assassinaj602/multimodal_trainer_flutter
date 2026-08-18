#include "mtmd.h"
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

struct mtmd_context {
    std::string model_path;
    std::string encoder_name = "qwen3.5-vl";
    int feature_dim = 1024;
};

struct mtmd_context * mtmd_init_from_file(const char * model_path) {
    if (!model_path) return nullptr;
    auto* ctx = new mtmd_context();
    ctx->model_path = model_path;
    return ctx;
}

void mtmd_free(struct mtmd_context * ctx) {
    delete ctx;
}

bool mtmd_set_encoder(struct mtmd_context * ctx, const char * encoder_name) {
    if (!ctx || !encoder_name) return false;
    ctx->encoder_name = encoder_name;
    return true;
}

bool mtmd_encode_image(
    struct mtmd_context * ctx,
    const char * /*image_path*/,
    struct mtmd_image_features * out_features
) {
    if (!ctx || !out_features) return false;
    out_features->patch_dim = 1024;
    out_features->num_patches = 16;
    out_features->length = static_cast<size_t>(out_features->patch_dim * out_features->num_patches);
    out_features->data = new float[out_features->length];
    
    for (size_t i = 0; i < out_features->length; ++i) {
        out_features->data[i] = 0.01f * static_cast<float>(i % 50);
    }
    return true;
}

void mtmd_free_image_features(struct mtmd_image_features * features) {
    if (features && features->data) {
        delete[] features->data;
        features->data = nullptr;
        features->length = 0;
    }
}

bool mtmd_combine_embeddings(
    struct mtmd_context * /*ctx*/,
    const float * img_embd,
    size_t img_len,
    const int32_t * text_tokens,
    size_t text_len,
    float * out_embd,
    size_t out_max_len,
    size_t * out_actual_len
) {
    if (!out_embd || !out_actual_len) return false;
    
    size_t total_needed = img_len + text_len;
    if (total_needed > out_max_len) return false;
    
    if (img_embd && img_len > 0) {
        std::memcpy(out_embd, img_embd, img_len * sizeof(float));
    }
    
    for (size_t i = 0; i < text_len; ++i) {
        out_embd[img_len + i] = static_cast<float>(text_tokens[i]) * 0.005f;
    }
    
    *out_actual_len = total_needed;
    return true;
}
