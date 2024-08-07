# Copyright 2024 Min Ma.
# SPDX-License-Identifier: Apache-2.0

if (HDL_INCLUDED)
    return()
endif()

set(HDL_INCLUDED TRUE)

find_package(iverilog)

if (${IVERILOG_FOUND})
    set(HDL_COMPILER ${IVERILOG_EXECUTABLE})
    set(HDL_SIMULATOR ${VVP_EXECUTABLE})
endif()

macro(set_realpath name)
    set(paths "")

    foreach (path ${ARG_${name}})
        get_filename_component(path "${path}" REALPATH)
        list(APPEND paths "${path}")
    endforeach()

    list(REMOVE_DUPLICATES paths)
    set(ARG_${name} ${paths})
endmacro()

function(hdl_add_module module_name)
    set(options
        ALL
    )
    set(one_value_arguments
    )

    set(multi_value_arguments
        DEPENDS
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
        "${multi_value_arguments}" ${ARGN})

    if (TARGET ${module_name})
        message(FATAL_ERROR "Target name ${module_name} already exists!")
    endif()

    if (NOT DEFINED ARG_DEPENDS)
        message(FATAL_ERROR "Module ${module_name} needs DEPENDS")
    endif()

    set_realpath(DEPENDS)
    if (${ARG_ALL})
        set(TARGET_ALL ALL)
    else()
        set(TARGET_ALL "")
    endif()

    add_custom_target(${module_name}
        ${TARGET_ALL}
        COMMAND ${IVERILOG_EXECUTABLE} -o ${module_name} ${ARG_DEPENDS}
    )

    set_property(TARGET ${module_name} PROPERTY depends ${ARG_DEPENDS})

endfunction()

function(hdl_add_testbench testbench_name)
    set(options
    ALL
    )
    set(one_value_arguments
    DUT
    )

    set(multi_value_arguments
    DEPENDS
    )

    cmake_parse_arguments(ARG "${options}" "${one_value_arguments}"
    "${multi_value_arguments}" ${ARGN})

    if (NOT DEFINED ARG_DUT)
        message(FATAL_ERROR "DUT is not set for testbench ${testbench_name}")
    endif()

    if (NOT DEFINED ARG_DEPENDS)
        message(FATAL_ERROR "Module ${module_name} needs DEPENDS")
    endif()

    set_realpath(DEPENDS)

    if (${ARG_ALL})
        set(TARGET_ALL ALL)
    else()
        set(TARGET_ALL "")
    endif()

    get_property(dut_sources TARGET ${ARG_DUT} PROPERTY depends)

    list(APPEND dut_sources ${ARG_DEPENDS})

    add_custom_target(${testbench_name}
        ${TARGET_ALL}
        COMMAND ${IVERILOG_EXECUTABLE} -o ${testbench_name} ${dut_sources}
    )

endfunction()
