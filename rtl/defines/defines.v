// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : defines.v
// Module Name  : defines
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 2023/01/04
// Called By    : 
// Description  : 
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-01-01   Deilt           1.0                     Original
// 2023-03-14   Deilt           1.1                     v0.1
// 2023-03-15   Deilt           1.2                     v0.2
// 2023-03-17   Deilt           1.3
// 2023-03-24   Deilt           1.4
// *********************************************************************************

`define CpuResetAddr    32'h0
`define RstEnable       1'b0 
`define True            1'b1
`define False           1'b0
`define HoldDisable     1'b0
`define HoldEnable      1'b1
`define JumpEnable      1'b1
`define JumpDisable     1'b0

//INST
`define INST_NOP 32'h00000013
`define ZeroWord 32'h0 


//ROM 
`define InstBus         31:0         //ROM的数据总线宽度
`define InstWidth       32
`define InstAddrBus     31:0         //ROM的地址总线宽度
`define InstAddrWidth   32
`define InstMemNum      131071       //ROM的实际大小为128KB
`define InstMemNumLog2  17           //ROM实际使用的地址宽度

//RAM MEM
`define MemBus          31:0
`define MemAddrBus      31:0
`define MemWidth        32
`define MemAddrWidth    32
`define MemDepth        131071
`define MemBank         2
`define MemUnit         4
`define CsEnable        1'b1
`define CsDisable       1'b0


//reg
`define RegAddrBus      4:0          //reg的地址总线宽度
`define RegAddrWidth    5
`define RegBus          31:0         //reg的数据总线宽度
`define RegWidth        32           //reg的宽度
`define RegDepth        32           //reg number 
`define RegNum          32           //reg number 
`define RegNumLog2      5            //寻址reg使用的地址位数
`define ZeroRegAddr     5'b00000     //zero reg
`define ZeroReg         32'h00000000

`define WriteEnable     1'b1
`define WriteDisable    1'b0
`define ReadEnable      1'b1
`define ReadDisable     1'b0

// I type inst
`define INST_TYPE_I     7'b0010011

`define INST_ADDI       3'b000  //addi rd,rs1,imm            
`define INST_SLTI       3'b010  //SLTI  slti  rd, rs1, imm   $signed(rs1) < $signed(imm) ? 1 : 0
`define INST_SLTIU      3'b011  //sltiu sltiu rd, rs1, imm   rs1 < imm ? 1:0
`define INST_XORI       3'b100
`define INST_ORI        3'b110
`define INST_ANDI       3'b111

`define INST_SLLI       3'b001  //逻辑左移 SLLI  slli rd, rs1, imm rd = rs1 << imm (低位补0)
`define INST_SRLI       3'b101  //逻辑右移 SRLI  srli rd, rs1, imm rd = rs1 >> imm (高位补0)
`define INST_SRAI       3'b101  //算术右移 符号位填充
// R type inst
`define INST_TYPE_R_M   7'b0110011

`define INST_ADD_SUB    3'b000
`define INST_SLL        3'b001
`define INST_SLT        3'b010
`define INST_SLTU       3'b011
`define INST_XOR        3'b100
`define INST_SRL_SRA    3'b101
//`define INST_SRA        3'b101
`define INST_OR         3'b110
`define INST_AND        3'b111

// M Standard extension
`define INST_MUL        3'b000
`define INST_MULH       3'b001
`define INST_MULHSU     3'b010
`define INST_MULHU      3'b011
`define INST_DIV        3'b100
`define INST_DIVU       3'b101
`define INST_REM        3'b110
`define INST_REMU       3'b111

// J/jump type inst
`define INST_JAL        7'b1101111
`define INST_JALR       7'b1100111

// B type inst
`define INST_TYPE_B     7'b1100011
`define INST_BEQ        3'b000
`define INST_BNE        3'b001
`define INST_BLT        3'b100
`define INST_BGE        3'b101
`define INST_BLTU       3'b110
`define INST_BGEU       3'b111

// L type inst
`define INST_TYPE_L     7'b0000011
`define INST_LB         3'b000
`define INST_LH         3'b001
`define INST_LW         3'b010
`define ISNT_LBU        3'b100
`define ISNT_LHU        3'b101

// S type inst
`define INST_TYPE_S     7'b0100011
`define INST_SB         3'b000
`define INST_SH         3'b001
`define INST_SW         3'b010

// U inst
`define INST_TYPE_LUI   7'b0110111
`define INST_TYPE_AUIPC 7'b0010111

// CSR inst
`define INST_CSRRW              3'b001
`define INST_CSRRS              3'b010
`define INST_CSRRC              3'b011
`define INST_CSRRWI             3'b101
`define INST_CSRRSI             3'b110
`define INST_CSRRCI             3'b111

/*-------------------------- CSR reg addr -------------------------*/
`define  CSR_MVENDORID_ADDR       12'hF11
`define  CSR_MARCHID_ADDR         12'hF12
`define  CSR_MIMPID_ADDR          12'hF13
`define  CSR_MHARTID_ADDR         12'hF14

/* ------ Machine trap setup ---------*/
`define  CSR_MSTATUS_ADDR         12'h300
`define  CSR_MISA_ADDR            12'h301
`define  CSR_MIE_ADDR             12'h304
`define  CSR_MTVEC_ADDR           12'h305
`define  CSR_MCOUNTEREN_ADDR      12'h306
`define  CSR_MCOUNTINHIBIT_ADDR   12'h320

/* ------ Machine trap handling ------*/
`define  CSR_MSCRATCH_ADDR        12'h340
`define  CSR_MEPC_ADDR            12'h341
`define  CSR_MCAUSE_ADDR          12'h342
`define  CSR_MTVAL_ADDR           12'h343
`define  CSR_MIP_ADDR             12'h344

`define  CSR_CYCLE_ADDR           12'hc00
`define  CSR_CYCLEH_ADDR          12'hc80
`define  CSR_MCYCLE_ADDR          12'hB00
`define  CSR_MCYCLEH_ADDR         12'hB80
`define  CSR_MINSTRET_ADDR        12'hB02
`define  CSR_MINSTRETH_ADDR       12'hB82
/* -------- Debug trigger -----------*/
`define  CSR_TSELECT_ADDR         12'h7A0
`define  CSR_TDATA1_ADDR          12'h7A1
`define  CSR_TDATA2_ADDR          12'h7A2
`define  CSR_TDATA3_ADDR          12'h7A3
`define  CSR_MCONTEXT_ADDR        12'h7A8
`define  CSR_SCONTEXT_ADDR        12'h7AA

/* -------- Debug/trace -------------*/
`define  CSR_DCSR_ADDR            12'h7b0
`define  CSR_DPC_ADDR             12'h7b1

/* ------------ Debug ----------------*/
`define  CSR_DSCRATCH0_ADDR       12'h7b2
`define  CSR_DSCRATCH1_ADDR       12'h7b3


/* --------------config parameters -----------*/
`define  REBOOT_ADDR              32'h80         //  32'h80 for c-test program, 32'h00000000: for isa test
`define  MTVEC_RESET              32'h00000001

//exception
`define InstValid       1'b0
`define InstInvalid     1'b1
`define TrapAssert      1'b1
`define TrapNotAssert   1'b0


//interrupt
`define InterruptAssert      1'b1
`define InterruptNotAssert   1'b1


//JTAG

//ITMC 

//DTMC
