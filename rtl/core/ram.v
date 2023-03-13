// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ram.v
// Module Name  : ram
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
module ram(
    input                       clk         ,
    input[`MemAddrBus]          addr        ,
    input[`InstBus]             data_in     ,
    input                       cs          ,    //chip select
    input                       we          ,    //write enable ,1 write ,0 read
    input[`MemUnit]             wem         ,    //写使能端口选择信号，用于选择要写入的RAM单元。
    output[`InstBus]            mem_data_o  
);
    

    gnrl_ram
    #(
        .DP(`MemDepth),
        .AW(`MemAddrWidth),
        .DW(`MemWidth),
        .MW(`MemUnit),
        .FORCE_X2ZERO (0)
    )
    u_gnrl_ram
    (
        .clk    (clk        ),
        .din    (data_in    ),
        .addr   (addr       ),
        .cs     (cs         ),
        .we     (we         ),
        .wem    (wem        ),
        .dout   (mem_data_o )
    );


endmodule