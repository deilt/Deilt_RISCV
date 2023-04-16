// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : csr_reg.v 
// Module Name  : csr_reg
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 2023-04-16
// Called By    : 
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-04-16   Deilt           1.0                     Original
//  
// *********************************************************************************
module csr_reg(
    input                           clk             ,
    input                           rstn            ,
    //from id
    input[`RegAddrBus]              csr_addr_i      ,
    input                           csr_read_i      ,

    //to id
    output[`RegBus]                 csr_data_o      ,
    //from wb
    input                           csr_wen         ,
    input[`RegAddrBus]              csr_wr_addr_i   ,
    input[`RegBus]                  csr_wr_data_i   
);

    reg [`RegBus] csr_mem[`RegDepth-1:0] ;

    //read csr
    always @(*) begin
        if(rstn == `RstEnable)
            csr_data_o = `ZeroReg;
        else if(csr_wen == `WriteEnable && csr_wr_addr_i == csr_addr_i && csr_read_i == `ReadEnable && csr_wr_addr_i != `ZeroRegAddr) //from wb
            csr_data_o = csr_wr_data_i;
        else if(csr_read_i == `ReadEnable && csr_addr_i != `ZeroRegAddr)
            csr_data_o = csr_mem[csr_addr_i];
        else 
            csr_data_o = `ZeroReg;
    end
    //write csr
    integer i;
    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            for(i=0;i<32;i=i+1)begin
                csr_mem[i] <= `ZeroWord;
            end
        end
        else if(csr_wen == `WriteEnable && csr_wr_addr_i != `ZeroRegAddr)begin
            csr_mem[csr_wr_addr_i] <= csr_wr_data_i;
        end
    end
endmodule