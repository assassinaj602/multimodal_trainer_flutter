#include "encoder.h"

bool VisionEncoder::processImage(
    mtmd_context* ctx,
    const std::string& imagePath,
    std::vector<float>& outFeatures
) {
    if (!ctx) return false;

    mtmd_image_features img_features;
    if (!mtmd_encode_image(ctx, imagePath.c_str(), &img_features)) {
        return false;
    }

    if (img_features.data && img_features.length > 0) {
        outFeatures.assign(img_features.data, img_features.data + img_features.length);
    }
    mtmd_free_image_features(&img_features);
    return true;
}
