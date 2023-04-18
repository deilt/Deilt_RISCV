// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ctrl.v
// Module Name  : ctrl
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
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

    /* ---signals to other stages of the pipeline  ----*/
    output[4:0]                     hold_en_o               ,
    output                          flush_o                 ,
    
    //from mem
    input [31:0]                    exception_i             ,

    /* --- interrupt signals from clint or plic--------*/
    input                               irq_software_i      ,
    input                               irq_timer_i         ,
    input                               irq_external_i      ,

    //to csr
    output                               cause_type_o,          // interrupt or exception
    output                               set_cause_o,
    output  [3:0]                        trap_casue_o,

    output                               set_mepc_o,
    output [`CsrRegBus]                  mepc_o,

    output                               set_mtval_o,
    output[`CsrRegBus]                   mtval_o,

    output                               mstatus_mie_clear_o,
    output                               mstatus_mie_set_o,

    //from csr
    input                              mstatus_mie_i,
    input                              mie_external_i, //does miss external interrupt
    input                              mie_timer_i,
    input                              mie_sw_i,

    input                              mip_external_i,// external interrupt pending
    input                              mip_timer_i,   // timer interrupt pending
    input                              mip_sw_i,      // software interrupt pending

    input [`CsrRegBus]                 mtvec_i,
    input [`CsrRegBus]                 mepc_i
);
    reg [4:0]           hold_en_o; 

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

    //exception_i ={25'b0 ,misaligned_load, misaligned_store, illegal_inst, misaligned_inst, ebreak, ecall, mret}
    wire   mret;
    wire   ecall;
    wire   ebreak;
    wire   misaligned_inst;
    wire   illegal_inst;
    wire   misaligned_store;
    wire   misaligned_load;

    assign {misaligned_load, misaligned_store, illegal_inst, misaligned_inst, ebreak, ecall, mret} = exception_i[6:0];

    /* check there is a interrupt on pending*/

    /* an interrupt or an exception, need to be processed */

endmodule