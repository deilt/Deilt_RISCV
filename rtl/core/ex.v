// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ex.v
// Module Name  : ex
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 
// Called By    :
// Description  : execution
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-10   Deilt           1.0                     Original
// 2023-03-17   Deilt           1.1
// 2023-03-25   Deilt           1.2 
// *********************************************************************************
`include "../defines/defines.v"
module ex(
    input                           clk         ,
    input                           rstn        ,
    //from id_ex
    input[`InstBus]                 inst_i      ,
    input[`InstAddrBus]             instaddr_i  ,
    input[`RegBus]                  rs1_data_i  ,//add
    input[`RegBus]                  rs2_data_i  ,//add

    input[`RegBus]                  op1_i       ,
    input[`RegBus]                  op2_i       ,
    input                           regs_wen_i  ,
    input[`RegAddrBus]              rd_addr_i   ,
    //to ex_mem
    output[`InstBus]                inst_o      ,
    output[`InstAddrBus]            instaddr_o  ,

    output                          cs_o        ,
    output                          mem_we_o    ,
    output[`MemUnit-1:0]            mem_wem_o   ,  
    output[`MemBus]                 mem_din     ,
    output[`MemAddrBus]             mem_addr_o  ,

    output                          regs_wen_o  ,
    output[`RegAddrBus]             rd_addr_o   ,
    output[`RegBus]                 rd_data_o   ,
    //to ctrl
    output                          ex_hold_flag_o ,//modify

    output                          ex_jump_en_o    ,//add
    output[`InstAddrBus]            ex_jump_base_o  ,//add
    output[`InstAddrBus]            ex_jump_ofst_o  //add
    

);
    reg [`InstBus]              inst_o;
    reg [`InstAddrBus]          instaddr_o;
    reg                         regs_wen_o;
    reg [`RegAddrBus]           rd_addr_o;
    reg                         ex_hold_flag_o;
    reg                         ex_jump_en_o;  
    reg [`InstAddrBus]          ex_jump_base_o;
    reg [`InstAddrBus]          ex_jump_ofst_o;

    reg                         cs_o;
    reg                         mem_we_o;
    reg [`MemUnit-1:0]          mem_wem_o;
    reg [`MemBus]               mem_din;
    reg [`MemAddrBus]           mem_addr_o;

    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];
    wire [6:0]  funct7 = inst_i[31:25];
    wire [4:0]  shamt  = inst_i[24:20];
    wire [31:0] sign_expd_imm = {{20{inst_i[31]}},inst_i[31:20]};
    wire [31:0] sign_expd_binst_imm = {{20{inst_i[31]}},inst_i[7],inst_i[30:25],inst_i[11:8],1'b0};

    reg [`RegBus]               rd_data;
    wire [`RegBus]              op1_add_op2;
    wire [`RegBus]              op1_sub_op2;
    wire [`RegBus]              op1_or_op2;
    wire [`RegBus]              op1_xor_op2;
    wire [`RegBus]              op1_and_op2;


    wire                        op1_be_op2_unsigned;
    wire                        op1_be_op2_signed;
    wire [`RegBus]              sra_arith;
    //wire [`RegBus]              sri_shift;
    wire [`RegBus]              sr_shift;
    //wire [`RegBus]              sri_shift_mask;
    wire [`RegBus]              sr_shift_mask;

    wire [`RegBus]              sl_shift;

    
    //rd_data_o
    assign rd_data_o = rd_data;

    //----------------------------------------
    //add 
    //In order to save resources the adder here is shared
    assign op1_add_op2 = op1_i + op2_i;
    //-----------------------------------------

    //----------------------------------------
    //sub
    //In order to save resources the sub here is shared
    assign op1_sub_op2 = op1_i - op2_i;
    //-----------------------------------------

    //----------------------------------------
    //or
    //In order to save resources the or here is shared
    assign op1_or_op2 = op1_i | op2_i;
    //-----------------------------------------

    //----------------------------------------
    //xor
    //In order to save resources the xor here is shared
    assign op1_xor_op2 = op1_i ^ op2_i;
    //-----------------------------------------

    //----------------------------------------
    //and
    //In order to save resources the and here is shared
    assign op1_and_op2 = op1_i & op2_i;
    //-----------------------------------------

    //-----------------------------------------
    //compare logic
    //unsigned 
    assign op1_be_op2_unsigned = op1_i >= op2_i;
    assign op1_eq_op2          =  (op1_i == op2_i);
    //signed
    assign op1_be_op2_signed   = $signed(op1_i) >= $signed(op2_i);

    //----------------------------------------

    //-----------------------------------------
    //shift right arith imm
    `ifndef SRA_NOT
        //srai_logi = (op1_i >> shamt) | (({32{op1_i[31]}}) & ~((32'hffffffff) >> shamt));
        assign sra_arith = (sr_shift) | (({32{op1_i[31]}}) & ~(sr_shift_mask));
    `endif  

    //assign sri_shift        = op1_i >> inst_i[24:20]; //op1_i >> shamt
    assign sr_shift         = op1_i >> op2_i[4:0];
    //assign sri_shift_mask   = 32'hffffffff >> inst_i[24:20];
    assign sr_shift_mask    = 32'hffffffff >> op2_i[4:0];

    //----------------------------------------

    //-----------------------------------------
    //shift left logi imm
    assign sl_shift         = op1_i << op2_i[4:0];
    //----------------------------------------
    //ex
    always @(*)begin
        inst_o =inst_i;
        instaddr_o = instaddr_i;
        regs_wen_o = regs_wen_i;
        rd_addr_o  = rd_addr_i;
        rd_data = `ZeroReg;

        ex_hold_flag_o = `HoldDisable;
        ex_jump_en_o   = `JumpDisable;
        ex_jump_base_o = `CpuResetAddr;
        ex_jump_ofst_o = `ZeroWord;
        
        cs_o           = `CsDisable;
        mem_we_o       = `WriteDisable;
        mem_wem_o      = {`MemUnit{1'b0}};
        mem_din        = `ZeroWord;
        mem_addr_o     = `ZeroReg;
        case(opcode)
            `INST_TYPE_I:begin
                case(funct3)
                    `INST_ADDI:begin
                        rd_data = op1_add_op2;
                    end
                    `INST_ORI:begin
                        rd_data = op1_or_op2;//op1_i | op2_i;
                    end
                    `INST_XORI:begin
                        rd_data = op1_xor_op2;
                    end
                    `INST_ANDI:begin
                        rd_data = op1_and_op2;
                    end
                    `INST_SLTI:begin
                        rd_data = {32{(~op1_be_op2_signed)}} & 32'h1;
                    end
                    `INST_SLTIU:begin
                        rd_data = {32{(~op1_be_op2_unsigned)}} & 32'h1;
                    end
                    `INST_SLLI:begin
                        rd_data = sl_shift;//op1_i << shamt; 
                    end
                    `INST_SRLI,`INST_SRAI:begin
                        if(funct7 == 7'h0)begin //SRLI
                            rd_data = sr_shift;//op1_i >> shamt
                        end
                        else begin
                            //rd_data = (op1_i >> shamt) | (({32{op1_i[31]}}) & ~((32'hffffffff) >> shamt));
                            rd_data = sra_arith;
                        end
                    end
                    default:begin
                        rd_data = `ZeroWord;
                    end
                endcase
            end
            `INST_TYPE_R_M:begin
                case(funct3)
                    `INST_ADD_SUB:begin
                        if(funct7 == 7'b0000000)begin//add
                            rd_data = op1_add_op2;
                        end
                        else begin//sub
                            rd_data = op1_sub_op2;
                        end
                    end
                    `INST_SLL:begin
                        rd_data = sl_shift;//op1_i << op2_i[4:0]
                    end
                    `INST_SLT:begin
                        rd_data = {32{(~op1_be_op2_signed)}} & 32'h1;
                    end
                    `INST_SLTU:begin
                        rd_data = {32{(~op1_be_op2_unsigned)}} & 32'h1;
                    end
                    `INST_XOR:begin
                        rd_data = op1_xor_op2;
                    end
                    `INST_SRL_SRA:begin
                        if(funct7 == 7'b0000000)begin //ral
                            rd_data = sr_shift;
                        end
                        else begin //sra
                            rd_data = sra_arith;
                        end
                    end
                    `INST_OR:begin
                        rd_data = op1_or_op2;
                    end
                    `INST_AND:begin
                        rd_data = op1_and_op2;
                    end
                    default:begin
                        rd_data = `ZeroReg;
                    end
                endcase 
            end
            `INST_JAL:begin
                rd_data = op1_add_op2;//pc+4
                ex_jump_en_o   = `JumpEnable;
                ex_jump_base_o = instaddr_i;
                ex_jump_ofst_o = {{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};//sign_imm
            end
            `INST_JALR:begin
                rd_data = op1_add_op2;//pc+4
                ex_jump_en_o   = `JumpEnable;
                ex_jump_base_o = rs1_data_i;
                ex_jump_ofst_o = sign_expd_imm;//sign_imm
            end
            `INST_TYPE_B:begin
                case(funct3)
                    `INST_BEQ:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = op1_eq_op2;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    `INST_BNE:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = !op1_eq_op2;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    `INST_BLT:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = !op1_be_op2_signed;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    `INST_BGE:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = op1_be_op2_signed;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    `INST_BLTU:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = !op1_be_op2_unsigned;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    `INST_BGEU:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = op1_be_op2_unsigned;
                        ex_jump_base_o = instaddr_i;
                        ex_jump_ofst_o = sign_expd_binst_imm;
                    end
                    default:begin
                        ex_hold_flag_o = `HoldDisable;
                        ex_jump_en_o   = `JumpDisable;
                        ex_jump_base_o = `CpuResetAddr;
                        ex_jump_ofst_o = `ZeroWord;
                    end
                endcase
            end
            `INST_TYPE_LUI:begin
                rd_data = op1_add_op2;
            end
            `INST_TYPE_AUIPC:begin
                rd_data = op1_add_op2;
            end
            `INST_TYPE_L:begin
                    //rd_data = `ZeroReg;
                    cs_o       = `CsEnable;
                    mem_we_o   = `WriteDisable;
                    mem_din    = `ZeroWord;
                    mem_addr_o = op1_add_op2;
                    mem_wem_o  = 4'b0000;
            end
            `INST_TYPE_S:begin
                //rd_data = `ZeroReg;
                cs_o       = `CsEnable;
                mem_we_o   = `WriteEnable;
                mem_addr_o = op1_add_op2;
                case(funct3)
                    `INST_SB:begin
                        case(op1_add_op2[1:0])
                            2'b11:begin
                                mem_din = {rs2_data_i[7:0],24'h0};
                                mem_wem_o = 4'b1000;
                            end
                            2'b10:begin
                                mem_din = {8'h0,rs2_data_i[7:0],16'h0};
                                mem_wem_o = 4'b0100;
                            end
                            2'b01:begin
                                mem_din = {16'h0,rs2_data_i[7:0],8'h0};
                                mem_wem_o = 4'b0010;
                            end
                            default:begin
                                mem_din = {24'h0,rs2_data_i[7:0]};
                                mem_wem_o = 4'b0001;
                            end
                        endcase
                    end
                    `INST_SH:begin
                        case(op1_add_op2[1:0])
                            2'b00:begin
                                mem_din    = {16'h0,rs2_data_i[15:0]};
                                mem_wem_o  =  4'b0011;
                            end
                            default:begin
                                mem_din    = {rs2_data_i[15:0],16'h0};
                                mem_wem_o  =  4'b1100;
                            end
                        endcase
                    end
                    `INST_SW:begin
                        mem_din    = rs2_data_i;
                        mem_wem_o  = 4'b1111;
                    end
                    default:begin
                        mem_din    = `ZeroWord;
                        mem_wem_o  = 4'b0000;
                    end
                endcase
            end
            default:begin
                rd_data = `ZeroReg;

                ex_hold_flag_o = `HoldDisable;
                ex_jump_en_o   = `JumpDisable;
                ex_jump_base_o = `CpuResetAddr;
                ex_jump_ofst_o = `ZeroWord;
        
                cs_o           = `CsDisable;
                mem_we_o       = `WriteDisable;
                mem_wem_o      = {`MemUnit{1'b0}};
                mem_din        = `ZeroWord;
                mem_addr_o     = `ZeroReg;
            end
        endcase
    end

endmodule