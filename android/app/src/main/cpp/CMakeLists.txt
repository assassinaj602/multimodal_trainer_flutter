cmake_minimum_required(VERSION 3.18.1)
project("multimodal_trainer" LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(UPSTREAM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../../../upstream_MobileFineTuner/operator")

add_definitions(-DUSE_NEW_AUTOGRAD_ENGINE)
add_definitions(-DDISABLE_BLAS_COMPLETELY)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${UPSTREAM_DIR}
    ${UPSTREAM_DIR}/include
    ${UPSTREAM_DIR}/finetune_ops
)

set(OPERATOR_SOURCES
    ${UPSTREAM_DIR}/finetune_ops/core/tensor.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/ops.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/autograd_engine.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/backward_functions.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/logger.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/memory_manager.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/step_arena.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/utils.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/lm_loss.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/memory_efficient_attention.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/performance_monitor.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/tokenizer.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/tokenizer_bpe.cpp
    ${UPSTREAM_DIR}/finetune_ops/core/tokenizer_gemma.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/safetensors_loader.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/gpt2_model.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/gemma_model.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/gemma_lora_injector.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/lora_injector.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/model_registry.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/auto_model.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/qwen_model.cpp
    ${UPSTREAM_DIR}/finetune_ops/data/mmlu_dataset.cpp
    ${UPSTREAM_DIR}/finetune_ops/data/wikitext2_dataset.cpp
    ${UPSTREAM_DIR}/finetune_ops/nn/lora_linear.cpp
    ${UPSTREAM_DIR}/finetune_ops/optim/optimizer.cpp
    ${UPSTREAM_DIR}/finetune_ops/optim/adam.cpp
    ${UPSTREAM_DIR}/finetune_ops/optim/trainer.cpp
    ${UPSTREAM_DIR}/finetune_ops/optim/auto_trainer.cpp
    ${UPSTREAM_DIR}/finetune_ops/optim/gemma_trainer.cpp
    ${UPSTREAM_DIR}/finetune_ops/graph/lora_saver.cpp
)

set(SOURCES
    native_lib.cpp
    trainer/multimodal_engine.cpp
    ${OPERATOR_SOURCES}
)

add_library(
    multimodal_trainer
    SHARED
    ${SOURCES}
)

find_library(
    log-lib
    log
)

target_link_libraries(
    multimodal_trainer
    ${log-lib}
)
