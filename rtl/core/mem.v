// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : mem.v
// Module Name  : mem
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
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
// 2023-03-10   Deilt           1.0                     Original
//  
// *********************************************************************************
`include "../defines/defines.v"
module mem(
    input                       clk             ,
    input                       rstn            ,
    //from ex_mem
    input[`InstBus]             inst_i          ,
    input[`InstAddrBus]         instaddr_i      ,

    input                       regs_wen_i      ,
    input[`RegAddrBus]          rd_addr_i       ,
    input[`RegBus]              rd_data_i       ,
    input[`MemAddrBus]          mem_addr_i      ,
    //from ram
    input[`MemBus]              mem_data_i      ,
    //to mem_wb
    output[`InstBus]            inst_o          ,
    output[`InstAddrBus]        instaddr_o      ,
    output                      regs_wen_o      ,
    output[`RegAddrBus]         rd_addr_o       ,
    output[`RegBus]             rd_data_o       
);
    wire [6:0]  opcode = inst_i[6:0];
    wire [2:0]  funct3 = inst_i[14:12];
    wire [1:0]  mem_addr_index;
    reg [`MemBus]  mem_data;

    assign mem_addr_index = mem_addr_i[1:0];

    assign rd_data_o = (opcode == `INST_TYPE_I || opcode == `INST_TYPE_R_M || opcode == `INST_JAL || opcode == `INST_JALR || opcode == `INST_TYPE_LUI || opcode == `INST_TYPE_AUIPC)?  rd_data_i : 
                        (opcode == `INST_TYPE_L ? mem_data : `ZeroWord);


    always @(*)begin
        if(opcode == `INST_TYPE_L)begin
            case(funct3)
                `INST_LB:begin
                    case(mem_addr_index)
                    2'b00: begin
                        mem_data = {{24{mem_data_i[7]}}, mem_data_i[7:0]};
                    end
                    2'b01: begin
                        mem_data = {{24{mem_data_i[15]}}, mem_data_i[15:8]};
                    end
                    2'b10: begin
                        mem_data = {{24{mem_data_i[23]}}, mem_data_i[23:16]};
                    end
                    default: begin
                        mem_data = {{24{mem_data_i[31]}}, mem_data_i[31:24]};
                    end    
                    endcase
                end
                `INST_LH:begin
                    if(mem_addr_index == 2'b00)begin
                        mem_data = {{16{mem_data_i[15]}}, mem_data_i[15:0]};
                    end
                    else begin
                        mem_data = {{16{mem_data_i[31]}}, mem_data_i[31:16]};
                    end
                end
                `INST_LW:begin
                    mem_data = mem_data_i;
                end
                `ISNT_LBU:begin
                    case(mem_addr_index)
                    2'b00: begin
                        mem_data = {{24{1'b0}}, mem_data_i[7:0]};
                    end
                    2'b01: begin
                        mem_data = {{24{1'b0}}, mem_data_i[15:8]};
                    end
                    2'b10: begin
                        mem_data = {{24{1'b0}}, mem_data_i[23:16]};
                    end
                    default: begin
                        mem_data = {{24{1'b0}}, mem_data_i[31:24]};
                    end    
                    endcase
                end
                `ISNT_LHU:begin
                    if(mem_addr_index == 2'b00)begin
                        mem_data = {{16{1'b0}}, mem_data_i[15:0]};
                    end
                    else begin
                        mem_data = {{16{1'b0}}, mem_data_i[31:16]};
                    end
                end
                default:begin
                    mem_data = `ZeroWord;
                end
            endcase 
        end
    end

    assign regs_wen_o   = regs_wen_i;
    assign rd_addr_o    = rd_addr_i;
    assign inst_o       = inst_i;
    assign instaddr_o   = instaddr_i;

endmodule