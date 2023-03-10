// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : if_id.v
// Module Name  : if_id
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
// 2023-03-09   Deilt           1.0                     Original
//  
// *********************************************************************************
`include "defines.v"
module if_id(
    input                   clk         ,
    input                   rstn        ,
    //from rom
    input[`InstBus]         inst_i      ,
    //from pc
    input[`InstAddrBus]     instaddr_i  ,

    //to id
    output[`InstBus]        inst_o      ,
    output[`InstAddrBus]    instaddr_o  ,

    input                   lden
);
    //inst dff
    reg [`InstBus]          inst_r;
    gnrl_dfflrd #(32) inst_gnrl_dfflrd(clk,rstn,lden,`INST_NOP,inst_i,inst_r);
    assign inst_o = inst_r ;

    //instaddr dff
    reg [`InstAddrBus]      instaddr_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,instaddr_i,instaddr_r);
    assign instaddr_o = instaddr_r;


endmodule