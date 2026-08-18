#ifndef VISION_ENCODER_H
#define VISION_ENCODER_H

#include "mtmd.h"
#include <vector>
#include <string>

class VisionEncoder {
public:
    static bool processImage(
        mtmd_context* ctx,
        const std::string& imagePath,
        std::vector<float>& outFeatures
    );
};

#endif // VISION_ENCODER_H
