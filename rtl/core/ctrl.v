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
    output[`InstAddrBus]            new_pc_o                ,
    
    //from mem
    input [31:0]                    exception_i             ,
    input[`InstBus]                 mem_inst_i              ,
    input[`InstAddrBus]             mem_inst_addr_i         ,

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
        else if(flush_o)begin
            hold_en_o = 5'b11111;//冲刷所有流水线
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
    wire meip;
    wire mtip;
    wire msip;
    wire ip;

    assign ip = meip || mtip || msip;
    assign meip = mip_external_i && mie_external_i;
    assign mtip = mip_timer_i && mie_timer_i;
    assign msip = mip_sw_i && mie_sw_i;

    /* an interrupt or an exception, need to be processed */
    wire trap_happened;
    assign trap_happened = (mstatus_mie_i && ip) || (misaligned_load || misaligned_store || illegal_inst || misaligned_inst || ebreak || ecall);
    
    // state registers
    reg [3:0] curr_state;
    reg [3:0] next_state;

    // machine states
    parameter STATE_RESET         = 4'b0001;
    parameter STATE_OPERATING     = 4'b0010;
    parameter STATE_TRAP_TAKEN    = 4'b0100;
    parameter STATE_TRAP_RETURN   = 4'b1000;

    always @ (*)   begin
        case(curr_state)
            STATE_RESET: begin
                next_state = STATE_OPERATING;
            end

            STATE_OPERATING: begin
                if(trap_happened)
                    next_state = STATE_TRAP_TAKEN;
                else if(mret)
                    next_state = STATE_TRAP_RETURN;
                else
                    next_state = STATE_OPERATING;
            end

            STATE_TRAP_TAKEN: begin
                next_state = STATE_OPERATING;
            end

            STATE_TRAP_RETURN: begin
                next_state = STATE_OPERATING;
            end

            default: begin
                next_state = STATE_OPERATING;
            end
        endcase
    end

    always @(posedge clk_i) begin
        if(rstn == `RstEnable)
            curr_state <= STATE_RESET;
        else
            curr_state <= next_state;
    end

    wire [1:0]          mtvec_mode; // machine trap mode
    wire [29:0]         mtvec_base; // machine trap base address

    assign mtvec_mode = mtvec_i[1:0];
    assign mtvec_base = mtvec_i[31:2];

    wire [`CsrRegBus]       mtvec_to_pc;
    wire [`CsrRegBus]       mtvec_base_offset;
    wire [`CsrRegBus]       mtvec_to_pc_mux;

    assign mtvec_base_offset = {26'b0, trap_casue_o, 2'b0};
    assign mtvec_to_pc = mtvec_i[1:0] ? ({mtvec_base, 2'b00} + mtvec_base_offset) : {mtvec_base,2'b00};//mtvec_i = 1 ,means interrupt;mtvec_i = 0 ,means exception
    assign mtvec_to_pc_mux = cause_type_o ? mtvec_to_pc : {mtvec_base,2'b00};//if is interrupt, then jump to mtvec_to_pc to determine;if is exception, then jump to mtvec_base

    // output generation
    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mepc_o <= `ZeroWord;
        end
        else
            mepc_o <= mem_inst_addr_i;
    end

    always @(*)begin
        case(curr_state)
            STATE_RESET:begin
                flush_o = 1'b0;
                new_pc_o = `CpuResetAddr;
                set_mepc_o = 1'b0;
                //set_cause_o = 1'b0;
                mstatus_mie_clear_o = 1'b0;
                mstatus_mie_set_o = 1'b0;
            end
            STATE_OPERATING:begin
                flush_o = 1'b0;
                new_pc_o = `ZeroWord;
                set_mepc_o = 1'b0;
                //set_cause_o = 1'b0;
                mstatus_mie_clear_o = 1'b0;
                mstatus_mie_set_o = 1'b0;
            end
            STATE_TRAP_TAKEN:begin
                flush_o = 1'b1;             
                new_pc_o = mtvec_to_pc_mux; // jump to the trap handler
                set_mepc_o = 1'b1;          // update the epc csr
                //set_cause_o = 1'b1;         // update the mcause csr
                mstatus_mie_clear_o = 1'b1; // disable the mie bit in the mstatus
                mstatus_mie_set_o = 1'b0;
            end
            STATE_TRAP_RETURN:begin
                flush_o = 1'b1;
                new_pc_o = mepc_i;
                set_mepc_o = 1'b0;
                //set_cause_o = 1'b0;
                mstatus_mie_clear_o = 1'b0;
                mstatus_mie_set_o = 1'b1;
            end
            default:begin
                flush_o = 1'b0;
                new_pc_o = `ZeroWord;
                set_mepc_o = 1'b0;
                //set_cause_o = 1'b0;
                mstatus_mie_clear_o = 1'b0;
                mstatus_mie_set_o = 1'b0;
            end
        endcase
    end

    /* update the mcause and mtval csr */
    always @(*)begin
            set_cause_o = 1'b0;
            cause_type_o = 1'b0;
            trap_casue_o = 4'b0;

            set_mtval_o = 1'b0;
            mtval_o <= `ZeroWord;
        if(curr_state ==  STATE_TRAP_TAKEN)begin
            if(mstatus_mie_i && meip)begin  // M-mode external interrupt
                set_cause_o = 1'b1;
                cause_type_o = 1'b1;
                trap_casue_o = 4'b1011;
            end
            if(mstatus_mie_i && msip)begin  // M-mode software interrupt
                set_cause_o = 1'b1;
                cause_type_o = 1'b1;
                trap_casue_o = 4'b0011;
            end
            if(mstatus_mie_i && mtip)begin  // M-mode timer interrupt
                set_cause_o = 1'b1;
                cause_type_o = 1'b1;
                trap_casue_o = 4'b0111;
            end
        end
        else if(curr_state == STATE_OPERATING)begin //earler than others
            if(illegal_inst)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b0010;

                set_mtval_o = 1'b1;
                mtval_o <= mem_inst_i;
            end
            if(misaligned_inst)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b0000;

                set_mtval_o = 1'b1;
                mtval_o <= mem_inst_addr_i;
            end
            if(ecall)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b1011;

                set_mtval_o = 1'b0;
                mtval_o <= `ZeroWord;
            end
            if(ebreak)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b0011;

                set_mtval_o = 1'b1;
                mtval_o <= mem_inst_i;
            end
            if(misaligned_store)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b0110;

                set_mtval_o = 1'b1;
                mtval_o <= mem_inst_addr_i;
            end
            if(misaligned_load)begin
                set_cause_o = 1'b1;
                cause_type_o = 1'b0;
                trap_casue_o = 4'b0100;

                set_mtval_o = 1'b1;
                mtval_o <= mem_inst_addr_i;
            end
        end
    end
endmodule