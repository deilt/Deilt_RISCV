// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : id_ex.v
// Module Name  : id_ex
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
//`include "../defines/defines.v"
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
    input [`RegBus]                 rs1_data_i  ,
    input [`RegBus]                 rs2_data_i  ,

    input                           csr_wen_i   ,
    input[`CsrRegAddrBus]           csr_wen_addr_i ,
    input[`CsrRegBus]               csr_data_i  ,
    //to ex
    output[`InstBus]                inst_o      ,
    output[`InstAddrBus]            instaddr_o  ,
    output[`RegBus]                 op1_o       ,
    output[`RegBus]                 op2_o       ,
    output                          regs_wen_o  ,
    output[`RegAddrBus]             rd_addr_o   ,
    output[`RegBus]                 rs1_data_o  ,
    output[`RegBus]                 rs2_data_o  ,

    output                          csr_wen_o       ,
    output[`CsrRegAddrBus]          csr_wen_addr_o  ,
    output[`CsrRegBus]              csr_data_o      ,//data from csr

    output                          prd_jump_en_o,
    //from prd
    input                           prd_jump_en_i,
    //from ctrl
    input[4:0]                      hold_en_i                
);
    wire                    lden ;
    assign lden = !hold_en_i[2];

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
    gnrl_dfflr #(32) op1_gnrl_dfflr(clk,rstn,lden,op1_i,op1_r);
    assign op1_o = op1_r;
    
    //op2 dff
    reg [`RegBus]           op2_r;
    gnrl_dfflr #(32) op2_gnrl_dfflr(clk,rstn,lden,op2_i,op2_r);
    assign op2_o = op2_r;

    //regs_wen dff
    reg                     regs_wen_r;
    gnrl_dfflr #(1) res_wen_gnrl_dfflr(clk,rstn,lden,regs_wen_i,regs_wen_r);
    assign regs_wen_o = regs_wen_r;

    //rd_addr_o
    reg [`RegAddrBus]       rd_addr_r;
    gnrl_dfflr #(`RegAddrWidth) rd_addr_gnrl_dfflr(clk,rstn,lden,rd_addr_i,rd_addr_r);
    assign rd_addr_o = rd_addr_r;
    
    //prd_jump_en
    reg prd_jump_en_r;
    gnrl_dfflr #(1) prd_jump_gnrl_dfflr(clk,rstn,lden,prd_jump_en_i,prd_jump_en_r);
    assign prd_jump_en_o = prd_jump_en_r;

    //rs1_data_o
    reg [`RegBus]           rs1_data_r;
    gnrl_dfflr #(`RegWidth) rs1_data_gnrl_dfflr(clk,rstn,lden,rs1_data_i,rs1_data_r);
    assign rs1_data_o = rs1_data_r;

    //rs2_data_o
    reg [`RegBus]           rs2_data_r;
    gnrl_dfflr #(`RegWidth) rs2_data_gnrl_dfflr(clk,rstn,lden,rs2_data_i,rs2_data_r);
    assign rs2_data_o = rs2_data_r;

    //csr_wen dff
    reg                     csr_wen_r;
    gnrl_dfflr #(1) csr_wen_gnrl_dfflr(clk,rstn,lden,csr_wen_i,csr_wen_r);
    assign csr_wen_o = csr_wen_r;

    //csr_data_o
    reg [`CsrRegBus]           csr_data_r;
    gnrl_dfflr #(`CsrRegWidth) csr_data_gnrl_dfflr(clk,rstn,lden,csr_data_i,csr_data_r);
    assign csr_data_o = csr_data_r;

    //csr_wen_addr_o
    reg [`CsrRegAddrBus]       csr_wen_addr_r;
    gnrl_dfflr #(`CsrRegAddrWidth) csr_wen_addr_gnrl_dfflr(clk,rstn,lden,csr_wen_addr_i,csr_wen_addr_r);
    assign csr_wen_addr_o = csr_wen_addr_r;

endmodule