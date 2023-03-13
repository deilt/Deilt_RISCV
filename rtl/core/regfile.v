// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : regfile.v
// Module Name  : regfile
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 
// Called By    :
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-10   Deilt           1.0                     Original
//  
// *********************************************************************************
`include "defines.v"
module regfile(
    input                           clk         ,
    input                           rstn        ,
    //from id
    input[`RegAddrBus]              rs1_addr_i  ,
    input[`RegAddrBus]              rs2_addr_i  ,
    //to id
    output[`RegBus]                 rs1_data_o  ,
    output[`RegBus]                 rs2_data_o  ,
    //from wb
    input                           wen         ,
    input[`RegAddrBus]              wr_addr_i   ,
    input[`RegBus]                  wr_data_i
);
    reg [`RegBus] regs_mem[`RegDepth-1:0] ;
    reg [`RegBus]   rs1_data_o;
    reg [`RegBus]   rs2_data_o;
    
    //read rs1
    always @(*)begin
        if(rstn == `RstEnable)
            rs1_data_o = `ZeroReg ;
        else 
            rs1_data_o = regs_mem[rs1_addr_i];
    end

    //read rs2
    always @(*)begin
        if(rstn == `RstEnable)
            rs2_data_o = `ZeroReg ;
        else 
            rs2_data_o = regs_mem[rs2_addr_i];
    end

    //write result
    integer i;
    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            for(i=0;i<32;i=i+1)begin
                regs_mem[i] <= `ZeroWord;
            end
        end
        else if(wen == `WriteEnable && wr_addr_i != `ZeroReg)begin
            regs_mem[wr_addr_i] <= wr_data_i;
        end
    end
endmodule