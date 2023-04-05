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
// 2023-04-04   Deilt           1.3
// *********************************************************************************
`include "../defines/defines.v"
module ex(
    input                           clk         ,
    input                           rstn        ,
    //from id_ex
    input[`InstBus]                 inst_i      ,
    input[`InstAddrBus]             instaddr_i  ,
    input[`RegBus]                  rs1_data_i  ,
    input[`RegBus]                  rs2_data_i  ,

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
    output                          ex_hold_flag_o  ,

    output                          ex_jump_en_o    ,
    output[`InstAddrBus]            ex_jump_base_o  ,
    output[`InstAddrBus]            ex_jump_ofst_o  ,

    //from mdu
    input                           div_ready_i     ,//除法完成计算
    input[`RegBus]                  div_res_i       ,//resul
    input                           div_busy_i      ,//除法进行中
    input[`RegAddrBus]              div_reg_waddr_i ,
    //to mdu
    output                          div_start_o     ,//开始除法运算标志
    output[`RegBus]                 div_dividend_o  ,//被除数
    output[`RegBus]                 div_divisor_o   ,//除数
    output[2:0]                     div_op_o        ,//除法指令
    output[`RegAddrBus]             div_reg_waddr_o , //最终写回的地址

    //from mul
    input                           mul_ready_i     ,//完成计算
    input[`RegBus]                  mul_res_i       ,//resul
    input                           mul_busy_i      ,//进行中
    input[`RegAddrBus]              mul_reg_waddr_i ,
    //to mul
    output                          mul_start_o     ,//开始运算标志
    output[`RegBus]                 mul_multiplicand_o  ,//
    output[`RegBus]                 mul_multiplier_o   ,//
    output[2:0]                     mul_op_o        ,//
    output[`RegAddrBus]             mul_reg_waddr_o  //最终写回的地址
);
    reg [`InstBus]              inst_o;
    reg [`InstAddrBus]          instaddr_o_d;
    reg                         regs_wen;
    reg [`RegAddrBus]           rd_addr;
    reg                         ex_hold_flag;
    reg                         ex_jump_en;  
    reg [`InstAddrBus]          ex_jump_base;
    reg [`InstAddrBus]          ex_jump_ofst;

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

    //div
    reg                         div_start_o    ;
    reg[`RegBus]                div_dividend_o ;
    reg[`RegBus]                div_divisor_o  ;
    reg[2:0]                    div_op_o       ;
    reg[`RegAddrBus]            div_reg_waddr_o;

    reg                         div_wen;
    reg[`RegBus]                div_wdata;
    reg[`RegAddrBus]            div_waddr;

    reg                         div_jump_en;
    reg                         div_hold_flag;
    reg[`InstAddrBus]           div_jump_base;
    reg[`InstAddrBus]           div_jump_ofst;
    reg[`InstAddrBus]           div_instaddr;//正在进行除法的指令地址
    //mul
    reg                         mul_start_o    ;
    reg[`RegBus]                multiplicand_o;
    reg[`RegBus]                multiplier_o  ;
    reg[2:0]                    mul_op_o       ;
    reg[`RegAddrBus]            mul_reg_waddr_o;

    reg                         mul_wen;
    reg[`RegBus]                mul_wdata;
    reg[`RegAddrBus]            mul_waddr;

    reg                         mul_jump_en;
    reg                         mul_hold_flag;
    reg[`InstAddrBus]           mul_jump_base;
    reg[`InstAddrBus]           mul_jump_ofst;
    reg[`InstAddrBus]           mul_instaddr;//正在进行的乘法指令地址
    
    //instaddr_o
    assign instaddr_o = instaddr_o_d | div_instaddr | mul_instaddr;

    //rd_data_o
    assign rd_data_o = rd_data | div_wdata | mul_instaddr;

    //jump_en_o
    assign ex_jump_en_o = ex_jump_en || div_jump_en || mul_jump_en;

    //ex_hold_flag_o
    assign ex_hold_flag_o = ex_hold_flag || div_hold_flag || mul_hold_flag;

    //ex_jump_base
    assign ex_jump_base_o = ex_jump_base | div_jump_base | mul_jump_base;

    //ex_jump_ofst_o
    assign ex_jump_ofst_o = ex_jump_ofst | div_jump_ofst | mul_jump_ofst;

    //reg_wen_o
    assign regs_wen_o = regs_wen || div_wen || mul_wen;

    //rd_addr_o
    assign rd_addr_o = rd_addr | div_waddr | mul_waddr;

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

    
    //-----------------------------------------
    //MUL
    always @(*)begin
        multiplicand_o = op1_i;
        multiplier_o = op2_i;
        mul_op_o = funct3;
        mul_reg_waddr_o = rd_addr_i;
        if((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001))begin
            mul_wen = `WriteDisable;
            mul_waddr = `ZeroWord;
            mul_wdata = `ZeroWord;
            mul_instaddr = instaddr_i;//锁存
            case(funct3)
                `INST_MUL,`INST_MULH,`INST_MULHU,`INST_MULHSU:begin
                    mul_start_o = 1'b1;
                    mul_jump_en = `JumpEnable;
                    mul_hold_flag = `HoldEnable;
                    mul_jump_base = instaddr_i ;
                    mul_jump_ofst = 32'h4;
                end
                default:begin
                    mul_start_o = 1'b0;
                    mul_jump_en = `JumpDisable;
                    mul_hold_flag = `HoldDisable;
                    mul_jump_base = `ZeroWord ;
                    mul_jump_ofst = 32'h0;
                end
            endcase
        end 
        else begin 
            mul_jump_en = `JumpDisable;
            mul_jump_base = `ZeroWord;
            mul_jump_ofst = `ZeroWord;
            if(mul_busy_i == 1'b1)begin //计算中
                mul_start_o = 1'b1;
                mul_wen = `WriteDisable;
                mul_wdata = `ZeroWord;
                mul_waddr = `ZeroReg;
                mul_hold_flag = `HoldEnable;
            end
            else begin//计算结束，或者非除法
                mul_instaddr = `ZeroWord;
                mul_start_o = 1'b0;
                mul_hold_flag = `HoldDisable;
                if(mul_ready_i == 1'b1)begin //计算结束
                    mul_wen = `WriteEnable;
                    mul_waddr = mul_reg_waddr_i;
                    mul_wdata = mul_res_i;
                end
                else begin //非除法
                    mul_wen = `WriteDisable;
                    mul_waddr = `ZeroReg;
                    mul_wdata = `ZeroWord;
                end
            end
        end
    end
    //----------------------------------------


    //-----------------------------------------
    //DIV
    always @(*)begin
        div_dividend_o = op1_i;
        div_divisor_o  = op2_i;
        div_op_o       = funct3;
        div_reg_waddr_o = rd_addr_i;
        if((opcode == `INST_TYPE_R_M) && (funct7 == 7'b0000001))begin//第一个时钟开始除法
            div_wen = `WriteDisable;
            div_waddr = `ZeroWord;
            div_wdata = `ZeroWord;
            div_instaddr = instaddr_i;//锁存
            case(funct3)
                `INST_DIV,`INST_DIVU,`INST_REM,`INST_REMU:begin
                    div_start_o = 1'b1;
                    div_jump_en = `JumpEnable;
                    div_hold_flag = `HoldEnable;
                    div_jump_base = instaddr_i;
                    div_jump_ofst = 32'h4;
                end
                default:begin
                    div_start_o = 1'b0;
                    div_jump_en = `JumpDisable;
                    div_hold_flag = `HoldDisable;
                    div_jump_base = `ZeroWord;
                    div_jump_ofst = 32'h0;
                end
            endcase 
        end
        else begin //第二个时钟
            div_jump_en = `JumpDisable;
            div_jump_base = `ZeroWord;
            div_jump_ofst = `ZeroWord;
            if(div_busy_i == 1'b1)begin //计算中
                div_start_o = 1'b1;
                div_wen = `WriteDisable;
                div_wdata = `ZeroWord;
                div_waddr = `ZeroReg;
                div_hold_flag = `HoldEnable;
            end
            else begin//计算结束，或者非除法
                div_instaddr = `ZeroWord;
                div_start_o = 1'b0;
                div_hold_flag = `HoldDisable;
                if(div_ready_i == 1'b1)begin //计算结束
                    div_wen = `WriteEnable;
                    div_waddr = div_reg_waddr_i;
                    div_wdata = div_res_i;
                end
                else begin //非除法
                    div_wen = `WriteDisable;
                    div_waddr = `ZeroReg;
                    div_wdata = `ZeroWord;
                end
            end
        end
    end
    //----------------------------------------



    //ex
    always @(*)begin
        inst_o =inst_i;
        instaddr_o_d = instaddr_i;
        regs_wen = regs_wen_i;
        rd_addr  = rd_addr_i;
        rd_data = `ZeroReg;

        ex_hold_flag = `HoldDisable;
        ex_jump_en   = `JumpDisable;
        ex_jump_base = `CpuResetAddr;
        ex_jump_ofst = `ZeroWord;
        
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
                if(funct7 != 7'b0000001)begin
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
            end
            `INST_JAL:begin
                rd_data = op1_add_op2;//pc+4
                ex_jump_en   = `JumpEnable;
                ex_jump_base = instaddr_i;
                ex_jump_ofst = {{12{inst_i[31]}},inst_i[19:12],inst_i[20],inst_i[30:21],1'b0};//sign_imm
            end
            `INST_JALR:begin
                rd_data = op1_add_op2;//pc+4
                ex_jump_en   = `JumpEnable;
                ex_jump_base = rs1_data_i;
                ex_jump_ofst = sign_expd_imm;//sign_imm
            end
            `INST_TYPE_B:begin
                case(funct3)
                    `INST_BEQ:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = op1_eq_op2;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    `INST_BNE:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = !op1_eq_op2;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    `INST_BLT:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = !op1_be_op2_signed;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    `INST_BGE:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = op1_be_op2_signed;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    `INST_BLTU:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = !op1_be_op2_unsigned;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    `INST_BGEU:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = op1_be_op2_unsigned;
                        ex_jump_base = instaddr_i;
                        ex_jump_ofst = sign_expd_binst_imm;
                    end
                    default:begin
                        ex_hold_flag = `HoldDisable;
                        ex_jump_en   = `JumpDisable;
                        ex_jump_base = `CpuResetAddr;
                        ex_jump_ofst = `ZeroWord;
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

                ex_hold_flag = `HoldDisable;
                ex_jump_en   = `JumpDisable;
                ex_jump_base = `CpuResetAddr;
                ex_jump_ofst = `ZeroWord;
        
                cs_o           = `CsDisable;
                mem_we_o       = `WriteDisable;
                mem_wem_o      = {`MemUnit{1'b0}};
                mem_din        = `ZeroWord;
                mem_addr_o     = `ZeroReg;
            end
        endcase
    end

endmodule