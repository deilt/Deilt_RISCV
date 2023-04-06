// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : ex_mul.v
// Module Name  : ex_mul
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 
// Called By    :
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-04-04   Deilt           1.0                     Original
//  
// *********************************************************************************
module ex_mul(
    input                               clk                 ,
    input                               rstn                ,

    input                               mul_start_i         ,
    input[`RegBus]                      mul_multiplicand_i  ,
    input[`RegBus]                      mul_multiplier_i    ,
    input[2:0]                          mul_op_i            ,
    input[`RegAddrBus]                  mul_reg_waddr_i     ,

    output                              mul_ready_o         ,
    output[`RegBus]                     mul_res_o           ,
    output                              mul_busy_o          ,
    output[`RegAddrBus]                 mul_reg_waddr_o
);
    reg[`RegBus]                        mul_multiplicand    ;
    reg[`RegBus]                        mul_multiplier      ;
    wire[`RegBus]                       multiplicand_invert ;
    wire[`RegBus]                       multiplier_invert   ;
    wire[63:0]                          result_inv          ;

    reg                                 mul_ready_o         ;
    reg[`RegBus]                        mul_res_o           ;
    reg                                 mul_busy_o          ;
    reg[`RegAddrBus]                    mul_reg_waddr_o     ;

    //fsm
    reg [1:0]       state;
    reg [1:0]       next_state;
    localparam  STATE_IDLE  = 2'b00;
    localparam  STATE_START = 2'b01;
    localparam  STATE_CACU  = 2'b10;
    localparam  STATE_END   = 2'b11;

    reg[63:0]       multiplicand;
    reg[`RegBus]    multiplier;
    reg             invert_result;

    reg[5:0]        count;
    reg[63:0]       result;
    reg[2:0]        mul_op;

    assign  multiplicand_invert = ~mul_multiplicand_i + 1;
    assign  multiplier_invert = ~mul_multiplier_i + 1;
    assign  result_inv = ~result +  1;
    //data deal
    always @(*)begin
        if(mul_start_i)begin
            case(mul_op_i)
                `INST_MUL,`INST_MULHU:begin
                    mul_multiplicand = mul_multiplicand_i;
                    mul_multiplier =   mul_multiplier_i;
                end
                `INST_MULHSU:begin
                    mul_multiplicand = (mul_multiplicand_i[31] == 1'b1) ? multiplicand_invert : mul_multiplicand_i;
                    mul_multiplier =   mul_multiplier_i;
                end
                `INST_MULH:begin
                    mul_multiplicand = (mul_multiplicand_i[31] == 1'b1) ? multiplicand_invert : mul_multiplicand_i;
                    mul_multiplier =   (mul_multiplier_i[31] == 1'b1) ? multiplier_invert : mul_multiplier_i;
                end
                default:begin
                    mul_multiplicand = `ZeroWord;
                    mul_multiplier =   `ZeroWord;
                end
            endcase
        end
        else begin
            mul_multiplicand = `ZeroWord;
            mul_multiplier =   `ZeroWord;
        end
    end

    //fsm


    //count
    always @(posedge clk or negedge rstn)begin
        if(rstn == `RstEnable)
            count <= 6'h0;
        else if(state == STATE_IDLE && state != next_state)begin
            result <= 0;
        end
        else if(next_state == STATE_CACU)begin
            count <= count + 1 ;
            if(multiplier[0])begin
                result = result + multiplicand;
            end
            else begin
                result = result;
            end
            multiplicand = multiplicand << 1 ;
            multiplier = multiplier >> 1;
        end
        else 
            count <= 6'h0;
    end


    always @(posedge clk or negedge rstn)begin
        if(rstn == `RstEnable)begin
            state <= STATE_IDLE;
        end
        else 
            state <= next_state;
    end


    always @(*)begin
        mul_ready_o = 1'b0;
        mul_busy_o = 1'b0;
        mul_res_o = `ZeroWord;
        case(state)
            STATE_IDLE:begin
                if(mul_start_i)begin
                    next_state = STATE_START;
                    multiplicand = {32'h0,mul_multiplicand};
                    multiplier = mul_multiplier;
                    mul_reg_waddr_o = mul_reg_waddr_i;
                    mul_op = mul_op_i;
                    if(((mul_multiplicand_i[31] ^ mul_multiplier_i[31]) && mul_op_i != `INST_MULHSU) || (mul_op_i == `INST_MULHSU && mul_multiplicand_i[31] == 1'b1))begin
                        invert_result = 1'b1;
                    end
                    else begin
                        invert_result = 1'b0;
                    end
                end
                else begin
                    next_state = STATE_IDLE;
                    multiplicand = `ZeroWord;
                    multiplier = `ZeroWord;
                    mul_reg_waddr_o = `ZeroWord;
                    invert_result = 1'b0;
                end
            end
            STATE_START:begin
                mul_busy_o = 1'b1;
                if(mul_start_i)begin
                    if(multiplicand == 64'h0 || multiplier == 32'h0)begin //zero
                        next_state = STATE_END;
                    end
                    else begin //not zero
                        next_state = STATE_CACU;
                    end
                end
                else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_CACU:begin
                mul_busy_o = 1'b1;
                if(mul_start_i)begin
                    if(count<32)begin
                        next_state = STATE_CACU;
                    end
                    else begin
                        next_state = STATE_END;
                    end
                end
                else begin
                    next_state = STATE_IDLE;
                end
            end
            STATE_END:begin
                next_state = STATE_IDLE;
                mul_ready_o = 1'h1;
                mul_busy_o = 1'h0;
                case(mul_op)
                    `INST_MUL:begin
                        mul_res_o = result[31:0];
                    end
                    `INST_MULHU:begin
                        mul_res_o = result[63:32];
                    end
                    `INST_MULH:begin
                        mul_res_o = invert_result ? result_inv[63:32] : result[63:32];
                    end
                    `INST_MULHSU:begin
                        mul_res_o = invert_result ? result_inv[63:32] : result[63:32];
                    end
                endcase
            end     
            default:begin
                next_state = STATE_IDLE;
                mul_ready_o = 1'h0;
                mul_reg_waddr_o = `ZeroWord;
                mul_res_o = `ZeroWord;
            end
        endcase
    end


endmodule