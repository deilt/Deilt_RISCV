// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : rom.v
// Module Name  : rom
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230309
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
`include "../defines/defines.v"
module rom(
    input                       clk     ,
    input[`InstAddrBus]         instaddr,
    input[`InstBus]             data_in ,
    input                       cs      ,     //chip select
    input                       we      ,     //write enable ,1 write ,0 read
    input[3:0]                  wem     ,    //写使能端口选择信号，用于选择要写入的RAM单元。
    output[`InstBus]            data_o  

);
    

    gnrl_ram
    #(
        .DP(`InstMemNum),
        .AW(`InstAddrWidth),
        .DW(`InstWidth),
        .MW(4),
        .FORCE_X2ZERO (0)
    )
    u_gnrl_rom
    (
        .clk    (clk        ),
        .din    (data_in    ),
        .addr   (instaddr   ),
        .cs     (cs         ),
        .we     (we         ),
        .wem    (wem        ),
        .dout   (data_o     )
    );


endmodule