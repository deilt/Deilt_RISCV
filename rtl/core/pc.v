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
    input               prd_fail        ,

    //from ex
    input[`InstAddrBus] ex_instaddr_i   ,
    input               ex_jump_en_i    ,

    input[`InstAddrBus] ex_jump_base_i  ,
    input[`InstAddrBus] ex_jump_ofset_i ,

    //from prd
    input               prd_jump_en_i   ,
    input[`InstAddrBus] prd_jump_base_i ,
    input[`InstAddrBus] prd_jump_ofset_i,

    output[`InstAddrBus] pc_o          
);
    reg [`InstAddrBus]  pc_o ;

    wire [`InstAddrBus] pc ;
    wire [`InstAddrBus] base;
    wire [`InstAddrBus] ofset;

    wire                jump_but_prd_fail;
    wire                nojump_but_prd_fail_and_just_pause;
    wire                prd_jump;

    /*assign base = ((prd_fail == 1'b1 && ex_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable) ? ex_jump_base_i :
                  ((hold_en_i[0] == `HoldEnable && (prd_jump_en_i == `JumpDisable || prd_fail == 1'b1) && ex_jump_en_i == `JumpDisable) ?  ex_instaddr_i :
                  ((prd_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable) ? prd_jump_base_i : 
                  pc)));
    assign ofset = ((prd_fail == 1'b1 && ex_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable) ? ex_jump_ofset_i :
                  ((hold_en_i[0] == `HoldEnable && (prd_jump_en_i == `JumpDisable || prd_fail == 1'b1) && ex_jump_en_i == `JumpDisable) ?  4'h4 :
                  ((prd_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable) ? prd_jump_ofset_i : 
                  4'h4)));*/

    assign jump_but_prd_fail = (prd_fail == 1'b1 && ex_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable);
    assign nojump_but_prd_fail_and_just_pause = (hold_en_i[0] == `HoldEnable && (prd_jump_en_i == `JumpDisable || prd_fail == 1'b1) && ex_jump_en_i == `JumpDisable) ;
    assign prd_jump = (prd_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable);

    assign base = (jump_but_prd_fail ? ex_jump_base_i :
                  (nojump_but_prd_fail_and_just_pause ? ex_instaddr_i :
                  (prd_jump ? prd_jump_base_i : pc)));
    
    assign ofset = (jump_but_prd_fail ? ex_jump_ofset_i :
                  (nojump_but_prd_fail_and_just_pause ?  4'h4:
                  (prd_jump ? prd_jump_base_i : 4'h4)));

    assign pc = base + ofset ;


    always @(posedge clk or negedge rstn) begin
        if(rstn == `RstEnable)begin
            pc_o <= `CpuResetAddr ; //reset to 32'h0
        end
        else begin
            pc_o = pc ;
        end
    end

    /*always @(posedge clk or negedge rstn) begin
        if(rstn == `RstEnable)begin
            pc <= `CpuResetAddr ; //reset to 32'h0
        end
        else if(hold_en_i[0] == `HoldEnable && (prd_jump_en_i == `JumpDisable || prd_fail == 1'b1) && ex_jump_en_i == `JumpDisable)begin//来自执行阶段的指令暂停,无跳转及预测失败
            pc <= ex_instaddr_i + 4'h4;
        end
        else if(prd_fail = 1'b1 && ex_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable)begin//ex阶段的跳转，预测失败
            pc <= ex_jump_addr_o;
        end
        //else if(prd_fail = 1'b1 && ex_jump_en_i == `JumpDisable && hold_en_i[0] == `HoldEnable)begin//ex阶段的跳转，预测失败
        //    pc <= ex_instaddr_i + 4'h4;
        //end
        else if(prd_jump_en_i == `JumpEnable && hold_en_i[0] == `HoldEnable)begin//预测跳转
            pc <= prd_jump_addr_i;
        end 
        else begin
            pc <= pc + 4'h4 ; //4byte equeal to 32bits
        end
    end*/

endmodule

    