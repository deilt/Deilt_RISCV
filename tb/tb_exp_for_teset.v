// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : testbench exp
// Module Name  : riscv_tb
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 2023/03/23
// Called By    :
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-23   Deilt           1.0                     Original
//  
// *********************************************************************************
`timescale  1ns/1ps
module core_tb;
    reg clk ;
    reg rstn ;
    integer r;

    wire x3 = core_tb.u_riscv_core.u_regfile.regs_mem[3];
    wire x26 = core_tb.u_riscv_core.u_regfile.regs_mem[26];
    wire x27 = core_tb.u_riscv_core.u_regfile.regs_mem[27];
    //initial
    initial begin
        #0 ;
        clk = 0 ;
        rstn = 0 ;

        #40 ;
        rstn = 1 ;
    end

    //clk gen
    always #10 clk = ~clk ;

    //rom
    initial begin
        $readmemh({testcase,".txt"},core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r);//for sim dir
        $display("rom[0] %h",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[0]);

    end
    //display
    initial begin
        wait(x26 == 32'h1);
        $display("regs[26] %h",x26);
        #40;

        if(x27 == 32'h1)begin
            $display("~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("regs[26] %h",x26);
            $display("regs[27] %h",x27);
            #20 $finish;
        end
        else begin
            $display("~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("faild test: %d",x3);
        for(r = 0;r<31;r = r + 1)begin
                $display("x%2d register value is %d",r,core_tb.u_riscv_core.u_regfile.regs_mem[r]);
            end
        #20 $finish;
        end
    end

    //inst
    riscv_core u_riscv_core(
        .clk(clk),
        .rstn(rstn)
    );
endmodule