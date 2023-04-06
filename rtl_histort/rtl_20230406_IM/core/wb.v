// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : wb.v
// Module Name  : wb
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 
// Called By    :
// Description  : write back
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
`include "../defines/defines.v"
module wb(
    input                       clk             ,
    input                       rstn            ,
    //from mem_wb
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,

    input                       regs_wen_i      ,
    input[`RegAddrBus]          rd_addr_i       ,
    input[`RegBus]              rd_data_i       ,
    //to regs
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       ,
    output[`RegBus]             rd_data_o       
);
    assign regs_wen_o = regs_wen_i;
    assign rd_addr_o  = rd_addr_i;
    assign rd_data_o  = rd_data_i; 

endmodule