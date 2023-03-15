// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ex.v
// Module Name  : ex
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
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
//  
// *********************************************************************************
`include "../defines/defines.v"
module ex(
    input                           clk         ,
    input                           rstn        ,
    //from id_ex
    input[`InstBus]                 inst_i      ,
    input[`InstAddrBus]             instaddr_i  ,
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
    output[`RegBus]                 rd_data_o   

);
    reg [`InstBus]              inst_o;
    reg [`InstAddrBus]          instaddr_o;
    reg                         regs_wen_o;
    reg [`RegAddrBus]           rd_addr_o;
    
    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];
    wire [6:0]  funct7 = inst_i[31:25];
    wire [4:0]  shamt  = inst_i[24:20];

    reg [`RegBus]               rd_data;
    wire [`RegBus]              op1_add_op2;
    wire [`RegBus]              op1_sub_op2;
    wire [`RegBus]              op1_or_op2;
    wire [`RegBus]              op1_xor_op2;
    wire [`RegBus]              op1_and_op2;

    reg
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
    `ifdef SRAI_NEED
        //srai_logi = (op1_i >> shamt) | (({32{op1_i[31]}}) & ~((32'hffffffff) >> shamt));
        sra_arith = (sr_shift) | (({32{op1_i[31]}}) & ~(sr_shift_mask));

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
                        if(funct7 == 7'0000000)begin //ral
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
                endcase 
            end
            default:begin
                rd_data = `ZeroWord;
            end
        endcase
    end

endmodule