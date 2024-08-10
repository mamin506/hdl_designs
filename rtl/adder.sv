// Copyright 2024 Min Ma.
// SPDX-License-Identifier: Apache-2.0

//`include "interfaces/adder_if.svh"

module adder (adder_if _if);

    always_comb begin
        if (_if.rstn) begin
            _if.sum = 0;
            _if.carry = 0;
        end else begin
            {_if.carry, _if.sum} = _if.a + _if.b;
        end
    end

endmodule
