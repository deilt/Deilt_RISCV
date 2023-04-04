// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : core_tb
// Module Name  : 
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230404
// Called By    :
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-04-04   Deilt           1.0                     Original
//  
// *********************************************************************************
`timescale  1ns/1ps
module core_tb;
    reg clk ;
    reg rstn ;
    reg [31:0] cycle_count;
    integer r;
    reg[8*300:1] testcase;//测试用例


    wire x3 = core_tb.u_riscv_core.u_regfile.regs_mem[3];
    wire x26 = core_tb.u_riscv_core.u_regfile.regs_mem[26];
    wire x27 = core_tb.u_riscv_core.u_regfile.regs_mem[27];

    //cycle count
    always @(posedge clk or negedge rstn)
    begin 
    if(rstn == 1'b0) begin
        cycle_count <= 32'b0;
    end
    else begin
        cycle_count <= cycle_count + 1'b1;
    end
    end


    //initial
    initial begin
    $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
        if($value$plusargs("TESTCASE=%s",testcase))begin
            $display("TESTCASE=%s",testcase);
        end

        #0 ;
        clk = 0 ;
        rstn = 0 ;

        #40 ;
        rstn = 1 ;

        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~TESTCASE: %s ~~~~~~~~~~~~~", testcase);
        $display("~~~~~~~~~~~~~~~The final x3 Reg value: %d ~~~~~~~~~~~~~", x3);

    end

    //clk gen
    always #10 clk = ~clk ;
   
    //rom
    initial begin
        $readmemh({testcase,".txt"},core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r);//for sim dir
        //$display("rom[0] %h",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[0]);
    end

    initial begin
        wait(x26 == 32'h1);
        $display("~~~~~~~~~~~~~~~The final x26 Reg value: %h ~~~~~~~~~~~~~",x26);
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
    
    initial begin
        #40000000
            $display("Time Out !!!");
        $finish;
    end
    //inst
    riscv_core u_riscv_core(
        .clk(clk),
        .rstn(rstn)
    );
    //stop

endmodule
