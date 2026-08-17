cmake_minimum_required(VERSION 3.18.1)
project("multimodal_trainer")

add_library(
    multimodal_trainer
    SHARED
    native_lib.cpp
)

find_library(
    log-lib
    log
)

target_link_libraries(
    multimodal_trainer
    ${log-lib}
)
