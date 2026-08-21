cmake_minimum_required(VERSION 3.18.1)
project("multimodal_trainer")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(THIRD_PARTY_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../../../third_party")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${THIRD_PARTY_DIR}/llama.cpp/include
    ${THIRD_PARTY_DIR}/libmtmd/include
    ${THIRD_PARTY_DIR}/MobileFineTuner/include
)

set(SOURCES
    native_lib.cpp
    model/model.cpp
    vision/encoder.cpp
    trainer/trainer.cpp
    ${THIRD_PARTY_DIR}/llama.cpp/src/llama_stub.cpp
    ${THIRD_PARTY_DIR}/libmtmd/src/mtmd_stub.cpp
    ${THIRD_PARTY_DIR}/MobileFineTuner/src/autograd_engine.cpp
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
