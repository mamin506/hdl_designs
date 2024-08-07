# Copyright 2024 Min Ma.
# SPDX-License-Identifier: Apache-2.0

#
# IVERILOG_EXECUTABLE - iverilog
#

if (COMMAND _find_iverilog)
    return()
endif()

function(_find_iverilog)
find_package(PackageHandleStandardArgs REQUIRED)

find_program(IVERILOG_EXECUTABLE iverilog
    HINTS $ENV{IVERILOG_ROOT}
    PATH_SUFFIXES bin
    DOC "Path to the iverilog executable"
)

find_program(VVP_EXECUTABLE vvp
    HINTS $ENV{IVERILOG_ROOT}
    PATH_SUFFIXES bin
    DOC "Path to the vvp executable"
)

mark_as_advanced(IVERILOG_EXECUTABLE)

find_package_handle_standard_args(iverilog REQUIRED_VARS IVERILOG_EXECUTABLE VVP_EXECUTABLE)

set(IVERILOG_FOUND ${IVERILOG_FOUND} PARENT_SCOPE)
set(IVERILOG_EXECUTABLE "${IVERILOG_EXECUTABLE}" PARENT_SCOPE)
set(VVP_EXECUTABLE "${VVP_EXECUTABLE}" PARENT_SCOPE)

endfunction()

_find_iverilog()
message("-- iverilog executable " ${IVERILOG_EXECUTABLE})
message("-- vvp executable " ${VVP_EXECUTABLE})