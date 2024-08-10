# Copyright 2024 Min Ma.
# SPDX-License-Identifier: Apache-2.0
#
# VLIB_EXECUTABLE - vlib(.exe)
# VLOG_EXECUTABLE - vlog(.exe)
# VSIM_EXECUTABLE - vsim(.exe)
#

if (COMMAND _find_modelsim)
    return()
endif()

function (_find_modelsim)
    find_package(PackageHandleStandardArgs REQUIRED)

    find_program(VLIB_EXECUTABLE vlib.exe
        PATH_SUFFIXES bin
        DOC "Path to the vlib executable"
    )

    find_program(VLOG_EXECUTABLE vlog.exe
        PATH_SUFFIXES bin
        DOC "Path to the vlog executable"
    )

    find_program(VSIM_EXECUTABLE vsim.exe
        PATH_SUFFIXES bin
        DOC "Path to the vsim executable"
    )

    mark_as_advanced(VLIB_EXECUTABLE)
    mark_as_advanced(VLOG_EXECUTABLE)
    mark_as_advanced(VSIM_EXECUTABLE)

    find_package_handle_standard_args(modelsim REQUIRED_VARS VSIM_EXECUTABLE VLIB_EXECUTABLE VLOG_EXECUTABLE)

    set(MODELSIM_FOUND ${MODELSIM_FOUND} PARENT_SCOPE)
    set(VLIB_EXECUTABLE ${VLIB_EXECUTABLE} PARENT_SCOPE)
    set(VLOG_EXECUTABLE ${VLOG_EXECUTABLE} PARENT_SCOPE)
    set(VSIM_EXECUTABLE ${VSIM_EXECUTABLE} PARENT_SCOPE)

endfunction()

_find_modelsim()
message("-- vsim executable " ${VSIM_EXECUTABLE})
message("-- vlog executable " ${VLOG_EXECUTABLE})
message("-- vlib executable " ${VLIB_EXECUTABLE})