// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : id_ex.v
// Module Name  : id_ex
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
module id_ex(
    input                           clk         ,
    input                           rstn        ,
    //from id
    input[`InstBus]                 inst_i      ,
    input[`InstAddrBus]             instaddr_i  ,
    input[`RegBus]                  op1_i       ,
    input[`RegBus]                  op2_i       ,
    input                           regs_wen_i  ,
    input[`RegAddrBus]              rd_addr_i   ,
    //to ex
    output[`InstBus]                inst_o      ,
    output[`InstAddrBus]            instaddr_o  ,
    output[`RegBus]                 op1_o       ,
    output[`RegBus]                 op2_o       ,
    output                          regs_wen_o  ,
    output[`RegAddrBus]             rd_addr_o   ,

    input                           lden        //always 1,for now          
);
    //inst dff
    reg [`InstBus]          inst_r;
    gnrl_dfflrd #(32) inst_gnrl_dfflrd(clk,rstn,lden,`INST_NOP,inst_i,inst_r);
    assign inst_o = inst_r ;

    //instaddr dff
    reg [`InstAddrBus]      instaddr_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,instaddr_i,instaddr_r);
    assign instaddr_o = instaddr_r;

    //op1 dff
    reg [`RegBus]           op1_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,op1_i,op1_r);
    assign op1_o = op1_r;
    
    //op2 dff
    reg [`RegBus]           op2_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,op2_i,op2_r);
    assign op2_o = op2_r;

    //regs_wen dff
    reg                     regs_wen_r;
    gnrl_dfflr #(1) instaddr_gnrl_dfflr(clk,rstn,lden,regs_wen_i,regs_wen_r);
    assign regs_wen_o = regs_wen_r;

    //rd_addr_o
    reg [`RegAddrBus]       rd_addr_r;
    gnrl_dfflr #(`RegAddrBus) instaddr_gnrl_dfflr(clk,rstn,lden,rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;

endmodule