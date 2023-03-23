// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : prdct.v
// Module Name  : prdct
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230317
// Called By    :
// Description  : for branch prediction
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
module prdct(
    input                           clk                 ,
    input                           rstn                ,
    //from if_id
    input[`InstBus]                 inst_i              ,//if_id_inst_i
    input[`InstAddrBus]             instaddr_i          ,//if_id_instaddr_i
    //to if/pc
    output                          prd_jump_en_o       ,
    output[`InstAddrBus]            prd_jump_base_o     ,
    output[`InstAddrBus]            prd_jump_ofset_o    ,
    //from regs and id  rs1 rs2
    input[`RegBus]                  rs1_data_i          ,
    input[`RegBus]                  rs2_data_i          ,
    
    input[`RegAddrBus]              rs1_addr_i          ,
    input[`RegAddrBus]              rs2_addr_i          ,
    input                           rs1_read_i          ,
    input                           rs2_read_i          ,
    
    //to id_ex
    //output                          prd_jump_en_o       ,
    
    //to ctrl
    //output                           prd_jump_en_o      ,      
    
    //from ex
    input                           ex_wen_i            ,
    input[`RegAddrBus]              ex_wr_addr_i        ,
    input[`RegBus]                  ex_wr_data_i        ,
    //from mem
    input                           mem_wen_i           ,
    input[`RegAddrBus]              mem_wr_addr_i       ,
    input[`RegBus]                  mem_wr_data_i   
);
    reg                             prd_jump_en_o;
    reg [`InstAddrBus]              prd_jump_base_o;
    reg [`InstAddrBus]              prd_jump_ofset_o;
    
    //简单译码(指令是属于普通指令还是分支跳转指令、分支跳转指令的类型和细节)
    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];

    wire [4:0]  rd     = inst_i[11:7];
    wire [11:0] imm_i    = inst_i[31:20];//jalr
    wire [31:0] sign_expd_imm_i = {{20{inst_i[31]}},inst_i[31:20]};

    wire [11:0] imm_j = {{inst_i[31]},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
    wire [31:0] sign_expd_imm_j = {{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};
    
    wire [11:0] imm_b = {{inst_i[31]},inst_i[30:25],inst_i[11:8],1'b0};
    wire [31:0] sign_expd_imm_b = {{20{inst_i[31]}},inst_i[30:25],inst_i[11:8],1'b0};

    wire [`RegBus]  rs1;
    //wire [`RegBus]  rs2;

    //Determine whether the b-type instruction is a jump back
    wire inst_b_jump_back = (imm_b[11] == 1'b1) ? 1'b1 : 1'b0;

    //id 阶段的数据冒险
    assign rs1 = ((rs1_read_i == `ReadEnable && ex_wen_i == `WriteEnable && rs1_addr_i == ex_wr_addr_i && ex_wr_addr_i != `ZeroReg) ? ex_wr_data_i :
                 ((rs1_read_i == `ReadEnable && mem_wen_i == `WriteEnable && rs1_addr_i == mem_wr_addr_i && mem_wr_addr_i != `ZeroReg) ? mem_wr_data_i :
                 ((rs1_read_i == `ReadEnable) ? rs1_data_i : `ZeroReg)));

    //op2
    /*assign rs2 = ((rs2_read_i == `ReadEnable && ex_wen_i == `WriteEnable && rs2_addr_i == ex_wr_addr_i) ? ex_wr_data_i :
                 ((rs2_read_i == `ReadEnable && mem_wen_i == `WriteEnable && rs2_addr_i == mem_wr_addr_i) ? mem_wr_data_i :
                 (rs2_read_i == `ReadEnable ? rs2_data_i : `ZeroWord)));*/

    //简单的分支预测 (简单的静态预测,默认向回即后跳转，BTFN)
    //生成跳转判断
    //生成跳转地址
    always @(*)begin
        prd_jump_en_o = `JumpDisable;
        prd_jump_base_o = `CpuResetAddr;
        prd_jump_ofset_o = `ZeroWord;

        case(opcode)
            `INST_TYPE_B:begin
                prd_jump_en_o = inst_b_jump_back;
                prd_jump_base_o = instaddr_i;
                prd_jump_ofset_o = sign_expd_imm_b;
            end
            `INST_JAL:begin
                prd_jump_en_o = `JumpEnable;
                prd_jump_base_o = instaddr_i;
                prd_jump_ofset_o = sign_expd_imm_j;
            end
            `INST_JALR:begin
                prd_jump_en_o = `JumpEnable;
                prd_jump_base_o = rs1;
                prd_jump_ofset_o = sign_expd_imm_i;
            end
            default:begin
                prd_jump_en_o = `JumpDisable;
                prd_jump_base_o = `CpuResetAddr;
                prd_jump_ofset_o = `ZeroWord;
            end
        endcase
    end

endmodule