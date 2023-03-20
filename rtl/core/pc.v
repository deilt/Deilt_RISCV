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

    input               prd_fail         ,
    input[`InstAddrBus] ex_jump_addr_o  ,//...............
    //from ex
    input[`InstAddrBus] ex_instaddr_i   ,
    input               ex_jump_en_i    ,

    //from prd
    input               prd_jump_en_i   ,
    input[`InstAddrBus] prd_jump_addr_i ,//.............

    output[`InstAddrBus] pc          
);
    reg [`InstAddrBus]  pc ;

    always @(posedge clk or negedge rstn) begin
        if(rstn == `RstEnable)begin
            pc <= `CpuResetAddr ; //reset to 32'h0
        end
        else if(hold_en_i[0] == `HoldEnable && (prd_jump_en_i == `JumpDisable || prd_fail == 1'b1) && ex_jump_en_i == `JumpDisable)begin//来自执行阶段的指令暂停,无跳转
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
    end

endmodule

