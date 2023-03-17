// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : pc.v
// Module Name  : pc
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230309
// Called By    :
// Description  : program counter
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-09   Deilt           1.0                     Original
// 2023-03-17   Deilt           1.1                     
// *********************************************************************************
`include "../defines/defines.v"

module pc(
    input               clk             ,
    input               rstn            ,
    //from ctrl
    input[4:0]          hold_en_i       ,
    input[`InstAddrBus] ex_instaddr_i   ,

    output[`InstAddrBus] pc          
);
    reg [`InstAddrBus]  pc ;

    always @(posedge clk or negedge rstn) begin
        if(rstn == `RstEnable)begin
            pc <= `CpuResetAddr ; //reset to 32'h0
        end
        else if(hold_en_i[0])begin
            pc <= ex_instaddr_i + 4'h4;
        end
        else begin
            pc <= pc + 4'h4 ; //4byte equeal to 32bits
        end
    end

endmodule