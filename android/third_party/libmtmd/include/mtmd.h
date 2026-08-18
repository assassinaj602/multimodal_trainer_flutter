#ifndef MTMD_H
#define MTMD_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

struct mtmd_context;

struct mtmd_image_features {
    float * data;
    size_t length;
    int32_t patch_dim;
    int32_t num_patches;
};

struct mtmd_context * mtmd_init_from_file(const char * model_path);
void mtmd_free(struct mtmd_context * ctx);

bool mtmd_set_encoder(struct mtmd_context * ctx, const char * encoder_name);
bool mtmd_encode_image(
    struct mtmd_context * ctx,
    const char * image_path,
    struct mtmd_image_features * out_features
);

void mtmd_free_image_features(struct mtmd_image_features * features);

bool mtmd_combine_embeddings(
    struct mtmd_context * ctx,
    const float * img_embd,
    size_t img_len,
    const int32_t * text_tokens,
    size_t text_len,
    float * out_embd,
    size_t out_max_len,
    size_t * out_actual_len
);

#ifdef __cplusplus
}
#endif

#endif // MTMD_H
