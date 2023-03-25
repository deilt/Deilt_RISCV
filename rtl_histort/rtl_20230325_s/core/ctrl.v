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
// 2023-03-25   Deilt           1.1
// *********************************************************************************
//`include "../defines/defines.v"
module ctrl(
    input                           clk                     ,
    input                           rstn                    ,
    //from ex
    input                           ex_hold_flag_i          ,

    input                           ex_jump_en_i            ,
    input[`InstAddrBus]             ex_jump_base_i          ,
    input[`InstAddrBus]             ex_jump_ofst_i          ,
    //from prd/id
    input                           prd_jump_en_i           ,//equle to id_hold_flag_i,for pipline flush
    //to pc/if
    output                          prd_fail                ,                          
    //from id_ex
    input                           id_ex_jump_en_i         ,    
    //from id
    input                           id_hold_flag_i          ,

    output[4:0]                     hold_en_o       
);
    reg [4:0]           hold_en_o; 

    //assign ex_jump_addr_o = ex_jump_base_o + ex_jump_ofst_o;

    //判断预测是否正确
    //assign prd_sus = ((ex_jump_en_i == `JumpEnable && id_ex_jump_en_i == `JumpEnable) && (ex_jump_addr_o == if_id_prd_jump_addr_i));

    //正确则不需要冲刷流水线
    //不正确则冲刷流水线

    assign prd_fail = (ex_jump_en_i != id_ex_jump_en_i) ;
    
    always @(*) begin
        if(rstn == `RstEnable)begin
            hold_en_o = 5'b00000 ;
        end
        else if(ex_hold_flag_i)begin//ex普通的暂停
            hold_en_o = 5'b01111;
        end
        else if(prd_fail)begin//预测失败
            hold_en_o = 5'b00111;
        end
        else if(prd_jump_en_i)begin//因为是预测跳转，那么要将指令推送到ex模块，进行校验，所以id_ex模块不冲刷
            hold_en_o = 5'b00011;
        end
        else if(id_hold_flag_i)begin//id普通的暂停 load
            hold_en_o = 5'b00111;
        end
        else begin
            hold_en_o = 5'b00000;
        end
    end    

endmodule