// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ctrl.v
// Module Name  : ctrl
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230317
// Called By    :
// Description  : pipeline flush
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-17   Deilt           1.0                     Original
//  
// *********************************************************************************
//`include "../defines/defines.v"
module ctrl(
    input                           clk             ,
    input                           rstn            ,
    //from ex
    input                           ex_hold_flag_i  ,

    //from prd/id
    input                           prd_jump_en_i   ,//equle to id_hold_flag_i

    output[4:0]                     hold_en_o       
);
    reg [4:0]   hold_en_o;
    always @(*) begin
        if(rstn == `RstEnable)begin
            hold_en_o = 5'b00000 ;
        end
        else if(ex_hold_flag_i)begin
            hold_en_o = 5'b01111;
        end
        else if(prd_jump_en_i)begin//因为是预测跳转，那么要将指令推送到ex模块，进行校验，所以id_ex模块不冲刷
            hold_en_o = 5'b00011;
        end
        else begin
            hold_en_o = 5'b00000;
        end
    end    

endmodule