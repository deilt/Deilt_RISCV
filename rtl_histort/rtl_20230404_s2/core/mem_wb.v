// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : mem_wb.v
// Module Name  : mem_wb
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
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
// 2023-03-17   Deilt           1.1
// *********************************************************************************
`include "../defines/defines.v"
module mem_wb(
    input                       clk             ,
    input                       rstn            ,
    //from mem
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,

    input                       regs_wen_i      ,
    input[`RegAddrBus]          rd_addr_i       ,
    input[`RegBus]              rd_data_i       ,
    //inst
    output[`InstBus]            inst_o          ,
    output[`InstAddrBus]        instaddr_o      ,
    //to regs
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       ,
    output[`RegBus]             rd_data_o       ,
    //from ctrl
    input[4:0]                  hold_en_i
);

    wire                    lden ;
    assign lden = !hold_en_i[4];

    //inst dff
    reg [`InstBus]          inst_r;
    gnrl_dfflrd #(32) inst_gnrl_dfflrd(clk,rstn,lden,`INST_NOP,inst_i,inst_r);
    assign inst_o = inst_r ;

    //instaddr dff
    reg [`InstAddrBus]      instaddr_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,instaddr_i,instaddr_r);
    assign instaddr_o = instaddr_r;
    
    //regs_wen
    reg                     regs_wen_r;
    gnrl_dfflr #(1) regs_wen_gnrl_dfflr(clk,rstn,lden,regs_wen_i,regs_wen_r);
    assign regs_wen_o = regs_wen_r;

    //rd_addr
    reg [`RegAddrBus]       rd_addr_r;
    gnrl_dfflr #(`RegAddrWidth) rd_addr_gnrl_dfflr(clk,rstn,lden,rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;

    //rd_data
    reg [`RegBus]           rd_data_r;
    gnrl_dfflr #(`RegWidth) rd_data_gnrl_dfflr(clk,rstn,lden,rd_data_i,rd_data_r);
    assign rd_data_o = rd_data_r;    
endmodule