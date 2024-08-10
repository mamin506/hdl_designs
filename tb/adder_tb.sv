// Copyright 2024 Min Ma.
// SPDX-License-Identifier: Apache-2.0

//`include "../rtl/interfaces/adder_if.svh"

interface clk_if();
    logic tb_clk;

    initial tb_clk <= 0;

    always #10 tb_clk = ~tb_clk;
endinterface

class Packet;
    rand bit rstn;
    rand bit[7:0] a;
    rand bit[7:0] b;
    bit [7:0] sum;
    bit carry;

    // Print contents of the data packet
    function void print(string tag="");
        $display ("T=%0t %s a=0x%0h b=0x%0h sum=0x%0h carry=0x%0h", $time, tag, a, b, sum, carry);
    endfunction

    // This is a utility function to allow copying contents in
    // one Packet variable to another.
    function void copy(Packet tmp);
        this.a = tmp.a;
        this.b = tmp.b;
        this.rstn = tmp.rstn;
        this.sum = tmp.sum;
        this.carry = tmp.carry;
    endfunction

    function void my_random();
        this.a = $urandom_range(0, 8'hFF);
        this.b = $urandom_range(0, 8'hFF);
    endfunction
endclass

class driver;
    virtual adder_if m_adder_vif;
    virtual clk_if  m_clk_vif;
    event drv_done;
    mailbox drv_mbx;

    task run();
        $display ("T=%0t [Driver] starting ...", $time);

        // Try to get a new transaction every time and then assign
        // packet contents to the interface. But do this only if the
        // design is ready to accept new transactions
        forever begin
            Packet item;

            $display ("T=%0t [Driver] waiting for item ...", $time);
            drv_mbx.get(item);
            @ (posedge m_clk_vif.tb_clk);
            item.print("Driver");
            m_adder_vif.rstn <= item.rstn;
            m_adder_vif.a <= item.a;
            m_adder_vif.b <= item.b;
            ->drv_done;
        end
    endtask
endclass

class monitor;
    virtual adder_if m_adder_vif;
    virtual clk_if m_clk_vif;

    mailbox scb_mbx; // Mailbox connected to scoreboard

    task run();
        $display ("T=%0t [Monitor] starting ...", $time);

        // Check forever at every clock edge to see if there is a
        // valid transaction and if yes, capture info into a class
        // object and send it to the scoreboard when the transaction
        // is over.
        forever begin
            Packet m_pkt = new();
            @(posedge m_clk_vif.tb_clk);
            #1;
            m_pkt.a = m_adder_vif.a;
            m_pkt.b = m_adder_vif.b;
            m_pkt.rstn = m_adder_vif.rstn;
            m_pkt.sum = m_adder_vif.sum;
            m_pkt.carry = m_adder_vif.carry;
            m_pkt.print("Monitor");
            scb_mbx.put(m_pkt);
        end
    endtask
endclass

class scoreboard;
    mailbox scb_mbx;

    task run();
        forever begin
            Packet item, ref_item;
            scb_mbx.get(item);
            item.print("Scoreboard");

            // Copy contents from received packet into a new packet so
            // just to get a and b.
            ref_item = new();
            ref_item.copy(item);

            // Let us calculate the expected values in carry and sum
            if (ref_item.rstn)
                {ref_item.carry, ref_item.sum} = 0;
            else
            {ref_item.carry, ref_item.sum} = ref_item.a + ref_item.b;

            // Now, carry and sum outputs in the reference variable can be compared
            // with those in the received packet
            if (ref_item.carry != item.carry) begin
                $display("[%0t] Scoreboard Error! Carry mismatch ref_item=0x%0h item=0x%0h", $time, ref_item.carry, item.carry);
            end else begin
                $display("[%0t] Scoreboard Pass! Carry match ref_item=0x%0h item=0x%0h", $time, ref_item.carry, item.carry);
            end

            if (ref_item.sum != item.sum) begin
                $display("[%0t] Scoreboard Error! Sum mismatch ref_item=0x%0h item=0x%0h", $time, ref_item.sum, item.sum);
            end else begin
                $display("[%0t] Scoreboard Pass! Sum match ref_item=0x%0h item=0x%0h", $time, ref_item.sum, item.sum);
            end
        end
    endtask
endclass

class generator;
    int loop = 10;
    event drv_done;
    mailbox drv_mbx;

    task run();
        for (int i = 0; i < loop; i++) begin
            Packet item = new;
            //item.randomize();
            item.my_random();
            $display ("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i+1, loop);
            drv_mbx.put(item);
            $display ("T=%0t [Generator] Wait for driver to be done", $time);
            @(drv_done);
        end
    endtask
endclass

class env;
    generator   g0;
    driver      d0;
    monitor     m0;
    scoreboard  s0;
    mailbox     scb_mbx;
    virtual adder_if m_adder_vif;
    virtual clk_if   m_clk_vif;

    event drv_done;
    mailbox drv_mbx;

    function new();
        d0 = new;
        m0 = new;
        s0 = new;
        scb_mbx = new();
        g0 = new;
        drv_mbx = new;
    endfunction

    virtual task run();
        d0.m_adder_vif = m_adder_vif;
        m0.m_adder_vif = m_adder_vif;
        d0.m_clk_vif = m_clk_vif;
        m0.m_clk_vif = m_clk_vif;

        d0.drv_mbx = drv_mbx;
        g0.drv_mbx = drv_mbx;

        m0.scb_mbx = scb_mbx;
        s0.scb_mbx = scb_mbx;

        d0.drv_done = drv_done;
        g0.drv_done = drv_done;

        fork
            s0.run();
            d0.run();
            m0.run();
            g0.run();
        join_any
    endtask
endclass

class test;
    env e0;
    mailbox drv_mbx;

    function new();
        drv_mbx = new();
        e0 = new();
    endfunction

    virtual task run();
        e0.d0.drv_mbx = drv_mbx;
        e0.run();
    endtask
endclass

module adder_tb;
    bit tb_clk;

    clk_if m_clk_if();
    adder_if m_adder_if();
    adder u_adder (
        ._if(m_adder_if)
    );

    initial begin
        test t0;

        t0 = new;
        t0.e0.m_adder_vif = m_adder_if;
        t0.e0.m_clk_vif = m_clk_if;
        t0.run();

        #50 $finish;
    end
endmodule
