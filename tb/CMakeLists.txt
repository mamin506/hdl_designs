# Copyright 2024 Min Ma.
# SPDX-License-Identifier: Apache-2.0

#hdl_add_testbench(counter_tb
#    DUT counter
#    DEPENDS counter_tb.sv
#)

hdl_add_testbench(adder_tb
    ALL
    DUT adder
    DEPENDS adder_tb.sv
)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/counter_tb DESTINATION counter_tb)