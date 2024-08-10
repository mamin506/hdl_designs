// Copyright 2024 Min Ma.
// SPDX-License-Identifier: Apache-2.0

interface adder_if();
    logic           rstn;
    logic [7:0]     a;
    logic [7:0]     b;
    logic [7:0]     sum;
    logic           carry;
endinterface
