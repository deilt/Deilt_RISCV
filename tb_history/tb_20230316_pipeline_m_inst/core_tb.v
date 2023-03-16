// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : core_tb
// Module Name  : 
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230316
// Called By    :
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-16   Deilt           1.0                     Original
//  
// *********************************************************************************
`timescale  1ns/1ps
module core_tb;
    reg clk ;
    reg rstn ;
    interger r;
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
        $readmemb("../isa/rom_r_inst_test.txt",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r);//for sim dir
    end
    //display
    initial begin
        //$readmemb("./rom_addi_inst_test.data",riscv_core.u_rom.u_gnrl_rom.mem_r);
        $display("rom_memb[0] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[0]);
        $display("rom_memb[1] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[1]);
        $display("rom_memb[2] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[2]);
        $display("rom_memb[3] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[3]);
        $display("rom_memb[4] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[4]);
        $display("rom_memb[5] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[5]);
        $display("rom_memb[6] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[6]);

        #1000;
        /*$display("x1 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[1]);
        $display("x2 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[2]);
        $display("x3 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[3]);
        $display("x4 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[4]);
        $display("x5 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[5]);*/
        for(r = 0;r<31;r = r + 1)begin
                $display("x%2d register value is %d",r,core_tb.u_riscv_core.u_regfile.regs_mem[r]);
            end
        #100 $finish;
    end

    //inst
    riscv_core u_riscv_core(
        .clk(clk),
        .rstn(rstn)
    );
    //stop

endmodule
