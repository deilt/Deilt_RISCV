// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : id.v
// Module Name  : id
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 
// Called By    :
// Description  : instruction decode
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-10   Deilt           1.0                     Original
// 2023-03-14   Deilt           1.1                     v0.1
// 2023-03-18   Deilt           1.2
// 2023-03-25   Deilt           1.3
// *********************************************************************************
`include "../defines/defines.v"
module id(
    input                       clk             ,
    input                       rstn            ,
    //from if_id
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,
    //from regs
    output[`RegBus]             rs1_data_i      ,
    output[`RegBus]             rs2_data_i      ,
    //to regs
    output[`RegAddrBus]         rs1_addr_o      ,
    output[`RegAddrBus]         rs2_addr_o      ,
    output                      rs1_read_o      ,
    output                      rs2_read_o      ,
    //to id_ex
    output[`InstBus]            inst_o          ,
    output[`InstAddrBus]        instaddr_o      ,
    output[`RegBus]             op1_o           ,
    output[`RegBus]             op2_o           ,
    output[`RegBus]             id_rs1_data_o   ,//
    output[`RegBus]             id_rs2_data_o   ,//
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       ,

    //from ex
    input[`InstBus]             ex_inst_i       ,
    input                       ex_wen_i        ,
    input[`RegAddrBus]          ex_wr_addr_i    ,
    input[`RegBus]              ex_wr_data_i    ,
    //from mem
    input                       mem_wen_i       ,
    input[`RegAddrBus]          mem_wr_addr_i   ,
    input[`RegBus]              mem_wr_data_i   ,
    //to ctrl
    output                      hold_flag_o 
);

    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];
    wire [6:0]  funct7 = inst_i[31:25];
    wire [4:0]  rs1    = inst_i[19:15];
    wire [4:0]  rs2    = inst_i[24:20]; //rs2 or shamt,they'r equal
    //wire [4:0]  shamt  = inst_i[24:20]; //rs2 or shamt,they'r equal
    wire [4:0]  rd     = inst_i[11:7];
    wire [11:0] imm    = inst_i[31:20];
    wire [31:0] sign_expd_imm = {{20{inst_i[31]}},inst_i[31:20]};
    wire [31:0] sign_expd_imm_s = {{20{inst_i[31]}},inst_i[31:25],inst_i[11:7]};
    wire [6:0]  last_opcode = ex_inst_i[6:0];

    reg [`InstBus]              inst_o;
    reg [`InstAddrBus]          instaddr_o;
    reg [`RegAddrBus]           rs1_addr_o;
    reg [`RegAddrBus]           rs2_addr_o;
    reg [`RegBus]               op1_o;
    reg [`RegBus]               op2_o;
    reg                         regs_wen_o;
    reg [`RegAddrBus]           rd_addr_o;

    reg                         rs1_read_o;
    reg                         rs2_read_o;

    reg [`RegBus]               op1;
    reg [`RegBus]               op2;

    wire                        funct3_sign_expd_imm;
    wire                        funct3_shamt;

    wire                        hold_flag_o;
    // 产生扩展立即数判断
    //assign funct3_sign_expd_imm = (opcode == `INST_TYPE_I && (funct3 == `INST_ADDI || funct3 == `INST_SLTI || funct3 == `INST_SLTIU || 
                                    //funct3 == `INST_XORI || funct3 == `INST_ORI || funct3 == `INST_ANDI));
    
    //产生位移扩展判断
    //assign funct3_shamt = (opcode == `INST_TYPE_I && (funct3 == `INST_SLLI || funct3 == `INST_SRLI));

    //id 暂停流水线 load冒险
    assign hold_flag_o = (rs1_read_o == `ReadEnable && ex_wen_i == `WriteEnable && rs1_addr_o == ex_wr_addr_i && ex_wr_addr_i != `ZeroReg && last_opcode == `INST_TYPE_L) 
                        || (rs2_read_o == `ReadEnable && ex_wen_i == `WriteEnable && rs2_addr_o == ex_wr_addr_i && ex_wr_addr_i != `ZeroReg || last_opcode == `INST_TYPE_L);

    //op1 
    assign op1 = ((rs1_read_o == `ReadEnable && ex_wen_i == `WriteEnable && rs1_addr_o == ex_wr_addr_i && ex_wr_addr_i != `ZeroReg) ? ex_wr_data_i :
                 ((rs1_read_o == `ReadEnable && mem_wen_i == `WriteEnable && rs1_addr_o == mem_wr_addr_i && mem_wr_addr_i != `ZeroReg) ? mem_wr_data_i :
                 ((rs1_read_o == `ReadEnable) ? rs1_data_i : `ZeroWord)));


    //op2
    assign op2 = ((rs2_read_o == `ReadEnable && ex_wen_i == `WriteEnable && rs2_addr_o == ex_wr_addr_i && ex_wr_addr_i != `ZeroReg) ? ex_wr_data_i :
                 ((rs2_read_o == `ReadEnable && mem_wen_i == `WriteEnable && rs2_addr_o == mem_wr_addr_i && mem_wr_addr_i != `ZeroReg) ? mem_wr_data_i :
                 (rs2_read_o == `ReadEnable ? rs2_data_i : `ZeroWord)));

    assign id_rs1_data_o = op1;
    assign id_rs2_data_o = op2;

    //decode
    always @(*)begin
        inst_o = inst_i;
        instaddr_o = instaddr_i;
        rs1_addr_o = `ZeroRegAddr;
        rs2_addr_o = `ZeroRegAddr;
        rs1_read_o = `ReadDisable;
        rs2_read_o = `ReadDisable;

        op1_o = `ZeroWord;
        op2_o = `ZeroWord;
        regs_wen_o = `WriteDisable;
        rd_addr_o = `ZeroReg;

        case(opcode)
            `INST_TYPE_I:begin
                case(funct3)
                    `INST_ADDI,`INST_SLTI,`INST_SLTIU,`INST_XORI,`INST_ORI,`INST_ANDI:begin
                        rs1_addr_o = rs1;
                        //rs2_addr_o = `ZeroRegAddr;
                        rs1_read_o = `ReadEnable;
                        rs2_read_o = `ReadDisable;
                        op1_o = op1; //rs1_data_i
                        op2_o = sign_expd_imm;//sign_expd_imm
                        regs_wen_o = `WriteEnable;
                        rd_addr_o = rd;
                    end
                    `INST_SLLI,`INST_SRLI,`INST_SRAI:begin
                        rs1_addr_o = rs1;
                        //rs2_addr_o = `ZeroRegAddr;
                        rs1_read_o = `ReadEnable;
                        rs2_read_o = `ReadDisable;
                        op1_o = op1 ;//rs1_data_i
                        op2_o = {{27'h0},rs2} ;//{{27'h0},rs2};(shamt) shamt = rs2
                        regs_wen_o = `WriteEnable;
                        rd_addr_o = rd;
                    end
                    //default
                endcase
            end
            `INST_TYPE_R_M:begin
                case(funct3)
                    `INST_ADD_SUB,`INST_SLT,`INST_SLTU,`INST_XOR,`INST_OR,`INST_AND,`INST_SLL,`INST_SRL_SRA:begin
                        rs1_addr_o = rs1;
                        rs2_addr_o = rs2;
                        rs1_read_o = `ReadEnable;
                        rs2_read_o = `ReadEnable;
                        op1_o = op1;//rs1_data_i
                        op2_o = op2;//rs2_data_i
                        regs_wen_o = `WriteEnable;
                        rd_addr_o = rd;
                    end
                    //default
                endcase
            end
            `INST_JAL:begin
                //rs1_addr_o = `ZeroRegAddr;
                //rs2_addr_o = `ZeroRegAddr;
                //rs1_read_o = `ReadDisable;
                //rs2_read_o = `ReadDisable;
                op1_o = instaddr_i;//PC
                op2_o = 32'h4;//+4
                regs_wen_o = `WriteEnable;
                rd_addr_o = rd;
            end
            `INST_JALR:begin
                rs1_addr_o = rs1;
                //rs2_addr_o = `ZeroRegAddr;
                rs1_read_o = `ReadEnable;
                //rs2_read_o = `ReadDisable;
                op1_o = instaddr_i;//PC
                op2_o = 32'h4;//+4
                regs_wen_o = `WriteEnable;
                rd_addr_o = rd;
            end
            `INST_TYPE_B:begin
                //case(funct3)
                //    `INST_BEQ,`INST_BNE,`INST_BLT,`INST_BGE,`INST_BLTU,`INST_BGEU:begin
                        rs1_addr_o = rs1;
                        rs2_addr_o = rs2;
                        rs1_read_o = `ReadEnable;
                        rs2_read_o = `ReadEnable;

                        op1_o = op1;//rs1_data_o
                        op2_o = op2;//rs2_data_o
                        //regs_wen_o = `WriteDisable;
                        //rd_addr_o = `ZeroReg;
                    //end
                //endcase
            end
            `INST_TYPE_LUI:begin
                //rs1_addr_o = `ZeroRegAddr;
                //rs2_addr_o = `ZeroRegAddr;
                //rs1_read_o = `ReadDisable;
                //rs2_read_o = `ReadDisable;

                op1_o = {inst_i[31:12],{12{1'b0}}};
                op2_o = `ZeroWord;
                regs_wen_o = `WriteEnable;
                rd_addr_o = rd;
            end
            `INST_TYPE_AUIPC:begin
                //rs1_addr_o = `ZeroRegAddr;
                //rs2_addr_o = `ZeroRegAddr;
                //rs1_read_o = `ReadDisable;
                //rs2_read_o = `ReadDisable;

                op1_o = instaddr_i;
                op2_o = {inst_i[31:12],{12{1'b0}}};
                regs_wen_o = `WriteEnable;
                rd_addr_o = rd;
            end
            `INST_TYPE_L:begin
                rs1_addr_o = rs1;
                //rs2_addr_o = `ZeroRegAddr;
                rs1_read_o = `ReadEnable;
                //rs2_read_o = `ReadDisable;

                op1_o = op1;//rs1_data_i
                op2_o = sign_expd_imm;
                regs_wen_o = `WriteEnable;
                rd_addr_o = rd;
            end
            `INST_TYPE_S:begin
                rs1_addr_o = rs1;
                rs2_addr_o = rs2;
                rs1_read_o = `ReadEnable;
                rs2_read_o = `ReadEnable;

                op1_o = op1;//rs1_data_i
                op2_o = sign_expd_imm_s;
                //regs_wen_o = `WriteDisable;
                //rd_addr_o = `ZeroReg;
            end
            default:begin
                rs1_addr_o = `ZeroRegAddr;
                rs2_addr_o = `ZeroRegAddr;
                rs1_read_o = `ReadDisable;
                rs2_read_o = `ReadDisable;

                op1_o = `ZeroWord;
                op2_o = `ZeroWord;
                regs_wen_o = `WriteDisable;
                rd_addr_o = `ZeroReg;    
            end
        endcase
    end








endmodule