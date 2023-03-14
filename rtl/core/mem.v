// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : mem.v
// Module Name  : mem
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
`include "../defines/defines.v"
module mem(
    input                       clk             ,
    input                       rstn            ,
    //from ex_mem
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,

    input                       regs_wen_i      ,
    input[`RegAddrBus]          rd_addr_i       ,
    input[`RegBus]              rd_data_i       ,
    //from ram
    input[`MemBus]              mem_data_i      ,
    //to mem_wb
    output[`InstBus]            inst_o          ,
    output[`InstAddrBus]        instaddr_o      ,
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       ,
    output[`RegBus]             rd_data_o       
);
    wire [6:0]  opcode = inst_i[6:0];
    assign rd_data_o = (opcode == `INST_TYPE_I)?  rd_data_i : mem_data_i;

    assign regs_wen_o   = regs_wen_i;
    assign rd_addr_o    = rd_addr_i;
    assign inst_o       = inst_i;
    assign instaddr_o   = instaddr_i;
endmodule