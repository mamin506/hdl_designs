# Copyright 2024 Min Ma.
# SPDX-License-Identifier: Apache-2.0

cmake_minimum_required(VERSION 3.28)

project(digital)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_CURRENT_LIST_DIR}/cmake")

message("-- Build type ${CMAKE_BUILD_TYPE}")

include(HDL)

add_subdirectory(rtl)
add_subdirectory(tb)
