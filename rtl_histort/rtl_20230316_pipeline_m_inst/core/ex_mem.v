// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ex_mem.v
// Module Name  : ex_mem
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
module ex_mem(
    input                           clk         ,
    input                           rstn        ,
    //from ex
    input[`InstBus]                 inst_i      ,
    input[`InstAddrBus]             instaddr_i  ,

    input                           cs_i        ,
    input                           mem_we_i    ,
    input[`MemUnit-1:0]             mem_wem_i   ,  
    input[`MemBus]                  mem_din     ,
    input[`MemAddrBus]              mem_addr_i  ,

    input                           regs_wen_i  ,
    input[`RegAddrBus]              rd_addr_i   ,
    input[`RegBus]                  rd_data_i   ,

    //to mem
    output[`InstBus]                inst_o      ,
    output[`InstAddrBus]            instaddr_o  ,

    output                          cs_o        ,
    output                          mem_we_o    ,
    output[`MemUnit-1:0]            mem_wem_o   ,  
    output[`MemBus]                 mem_dout    ,
    output[`MemAddrBus]             mem_addr_o  ,

    output                          regs_wen_o  ,
    output[`RegAddrBus]             rd_addr_o   ,
    output[`RegBus]                 rd_data_o   ,

    output                          lden
);
    //inst dff
    reg [`InstBus]          inst_r;
    gnrl_dfflrd #(32) inst_gnrl_dfflrd(clk,rstn,lden,`INST_NOP,inst_i,inst_r);
    assign inst_o = inst_r ;

    //instaddr dff
    reg [`InstAddrBus]      instaddr_r;
    gnrl_dfflr #(32) instaddr_gnrl_dfflr(clk,rstn,lden,instaddr_i,instaddr_r);
    assign instaddr_o = instaddr_r;

    //cs
    reg                     cs_r;
    gnrl_dfflr #(1) cs_gnrl_dfflr(clk,rstn,lden,cs_i,cs_r);
    assign cs_o = cs_r;

    //mem_we
    reg                     mem_we_r;
    gnrl_dfflr #(1) mem_we_gnrl_dfflr(clk,rstn,lden,mem_we_i,mem_we_r);
    assign  mem_we_o = mem_we_r;

    //mem_wem
    reg [`MemUnit-1:0]      mem_wem_r;
    gnrl_dfflr #(`MemUnit) mem_wem_gnrl_dfflr(clk,rstn,lden,mem_wem_i,mem_wem_r);
    assign mem_wem_o = mem_wem_r;

    //mem_din
    reg [`MemBus]           mem_din_r;
    gnrl_dfflr #(`MemWidth) mem_din_gnrl_dfflr(clk,rstn,lden,mem_din,mem_din_r);
    assign mem_dout = mem_din_r;

    //mem_addr
    reg [`MemAddrBus]       mem_addr_r;
    gnrl_dfflr #(`MemAddrWidth) mem_addr_gnrl_dfflr(clk,rstn,lden,mem_addr_i,mem_addr_r);
    assign mem_addr_o = mem_addr_r;

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