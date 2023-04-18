// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : csr_reg.v 
// Module Name  : csr_reg
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 2023-04-16
// Called By    : 
// Description  :
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-04-16   Deilt           1.0                     Original
//  
// *********************************************************************************
module csr_reg(
    input                               clk             ,
    input                               rstn            ,
    //from id
    input[`CsrRegAddrBus]               csr_addr_i      ,
    input                               csr_read_i      ,

    //to id
    output[`CsrRegBus]                  csr_data_o      ,
    //from wb
    input                               csr_wen         ,
    input[`CsrRegAddrBus]               csr_wr_addr_i   ,
    input[`CsrRegBus]                   csr_wr_data_i   ,

    /* --- interrupt signals from clint or plic--------*/
    input                               irq_software_i,
    input                               irq_timer_i,
    input                               irq_external_i,
    /* ---- ctrl update epc, mcause, mtval, global ie ----*/
    input                               cause_type_i,          // interrupt or exception
    input                               set_cause_i,
    input  [3:0]                        trap_casue_i,

    input                               set_mepc_i,
    input [`CsrRegBus]                  mepc_i,

    input                               set_mtval_i,
    input[`CsrRegBus]                   mtval_i,

    input                               mstatus_mie_clear_i,
    input                               mstatus_mie_set_i,

    /*-- to control , interrupt enablers, mtvec, epc etc-----*/
    output                              mstatus_mie_o,
    output                              mie_external_o, //does miss external interrupt
    output                              mie_timer_o,
    output                              mie_sw_o,

    output                              mip_external_o,// external interrupt pending
    output                              mip_timer_o,   // timer interrupt pending
    output                              mip_sw_o,      // software interrupt pending

    output [`CsrRegBus]                 mtvec_o,
    output [`CsrRegBus]                 mepc_o
);

    reg [`CsrRegBus] csr_mem[`CsrRegDepth-1:0] ;
    reg [`CsrRegBus]        csr_data_o;

    //read csr
    always @(*) begin
        if(rstn == `RstEnable)
            csr_data_o = `ZeroReg;
        else if(csr_wen == `WriteEnable && csr_wr_addr_i == csr_addr_i && csr_read_i == `ReadEnable && csr_wr_addr_i != 12'h0) //from wb
            csr_data_o = csr_wr_data_i;
        else if(csr_read_i == `ReadEnable && csr_addr_i != 12'h0)begin
            case(csr_addr_i)
                `CSR_MVENDORID_ADDR:begin
                    csr_data_o = CSR_MVENDORID_VALUE;
                end
                `CSR_MARCHID_ADDR:begin
                    csr_data_o = mscratch;
                end
                `CSR_MIMPID_ADDR:begin
                    csr_data_o = CSR_MIMPID_VALUE;
                end
                `CSR_MHARTID_ADDR:begin
                    csr_data_o = CSR_MHARTID_VALUE;
                end
                `CSR_MSTATUS_ADDR:begin
                    csr_data_o = mstatus;
                end
                `CSR_MISA_ADDR:begin
                    csr_data_o = misa;
                end
                `CSR_MIE_ADDR:begin
                    csr_data_o = mie;
                end
                `CSR_MTVEC_ADDR:begin
                    csr_data_o = mtvec;
                end
                `CSR_MSCRATCH_ADDR:begin
                    csr_data_o = mscratch;
                end
                `CSR_MEPC_ADDR:begin
                    csr_data_o = mepc;
                end
                `CSR_MCAUSE_ADDR:begin
                    csr_data_o = mcause;
                end
                `CSR_MTVAL_ADDR:begin
                    csr_data_o = mtval;
                end
                `CSR_MIP_ADDR:begin
                    csr_data_o = mip;
                end
                `CSR_CYCLE_ADDR,`CSR_MCYCLE_ADDR:begin
                    csr_data_o = mcycle[31:0];
                end
                `CSR_CYCLEH_ADDR,`CSR_MCYCLEH_ADDR:begin
                    csr_data_o = mcycle[63:32];
                end
                `CSR_MINSTRET_ADDR:begin
                    csr_data_o = minstret[31:0];
                end
                `CSR_MINSTRETH_ADDR:begin
                    csr_data_o = minstret[63:32];
                end
                default:begin
                    csr_data_o = `ZeroWord;
                end
            endcase
        end
    end
    /* write csr
    integer i;
    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            for(i=0;i<32;i=i+1)begin
                csr_mem[i] <= `ZeroWord;
            end
        end
        else if(csr_wen == `WriteEnable && csr_wr_addr_i != 12'h0)begin
            csr_mem[csr_wr_addr_i] <= csr_wr_data_i;
        end
    end */

    // mvendorid
    // The mvendorid CSR is a 32-bit read-only register providing the JEDEC manufacturer ID of the
    // provider of the core. This register must be readable in any implementation, but a value of 0 can be
    // returned to indicate the field is not implemented or that this is a non-commercial implementation.
    localparam CSR_MVENDORID_VALUE  = 32'b0;
    
    // Architecture ID
    // The marchid CSR is an MXLEN-bit read-only register encoding the base microarchitecture of the hart. 
    // This register must be readable in any implementation, but a value of 0 can be returned to
    // indicate the field is not implemented. The combination of mvendorid and marchid should uniquely
    // identify the type of hart microarchitecture that is implemented.
    localparam CSR_MARCHID_VALUE = {1'b0, 31'd1};

    // mimpid
    // The mimpid CSR provides a unique encoding of the version of the processor implementation. 
    // This register must be readable in any implementation, but a value of 0 can be returned to indicate that
    // the field is not implemented.
    localparam  CSR_MIMPID_VALUE = 32'b0;

    // mhartid
    // The mhartid CSR is an MXLEN-bit read-only register containing the integer ID of the hardware
    // thread running the code. This register must be readable in any implementation. Hart IDs might
    // not necessarily be numbered contiguously in a multiprocessor system, but at least one hart must
    // have a hart ID of zero.
    localparam CSR_MHARTID_VALUE = 32'b0;

    /*--------------------------------------------- mstatus ----------------------------------------*/
    // {SD(1), WPRI(8), TSR(1), TW(1), TVM(1), MXR(1), SUM(1), MPRV(1), XS(2),
    //  FS(2), MPP(2), WPRI(2), SPP(1), MPIE(1), WPRI(1), SPIE(1), UPIE(1),MIE(1), WPRI(1), SIE(1), UIE(1)}
    // Global interrupt-enable bits, MIE, SIE, and UIE, are provided for each privilege mode.
    // xPIE holds the value of the interrupt-enable bit active prior to the trap, and xPP holds the previous privilege mode.
    wire [`CsrRegBus]       mstatus;
    reg                     mstatus_mpie;
    reg                     mstatus_mie;
    wire                    mstatus_mie_o;
    
    assign mstatus_mie_o = mstatus_mie;

    assign mstatus = {19'b0,2'b11,3'b0,mstatus_mpie,3'b0,mstatus_mie,3'b0};

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mstatus_mpie <= 1'b1;
            mstatus_mie <= 1'b1;//default on
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MSTATUS_ADDR))begin
            mstatus_mpie <= csr_wr_data_i[7];
            mstatus_mie <= csr_wr_data_i[3];
        end
        else if(mstatus_mie_clear_i)begin
            mstatus_mpie <= mstatus_mie;
            mstatus_mie <= 1'b0;//turn off
        end
        else if(mstatus_mie_set_i)begin
            mstatus_mpie <= 1'b1;
            mstatus_mie <= mstatus_mpie;
        end
    end


    /*--------------------------------------------- MISA ------------------------------------------*/
    // The misa CSR is a WARL read-write register reporting the ISA supported by the hart. This
    // register must be readable in any implementation, but a value of zero can be returned to indicate
    // the misa register has not been implemented
    wire [1:0]      mxl;
    wire [25:0] mextensions; // ISA extensions
    wire [`CsrRegBus]   misa;

    assign mxl = 2'b01;//32 bits
    assign mextensions = 26'b00000000000001000100000000;// IM
    assign misa = {mxl,4'b0,mextensions};

    /*--------------------------------------------- mie ----------------------------------------*/
    // mie: {WPRI[31:12], MEIE(1), WPRI(1), SEIE(1), UEIE(1), MTIE(1), WPRI(1), STIE(1), UTIE(1), MSIE(1), WPRI(1), SSIE(1), USIE(1)}
    // MTIE, STIE, and UTIE for M-mode, S-mode, and U-mode timer interrupts respectively.
    // MSIE, SSIE, and USIE fields enable software interrupts in M-mode, S-mode software, and U-mode, respectively.
    // MEIE, SEIE, and UEIE fields enable external interrupts in M-mode, S-mode software, and U-mode, respectively.
    wire [`CsrRegBus]           mie;
    reg                         meie;
    reg                         mtie;
    reg                         msie;

    assign mie_external_o = meie;
    assign mie_timer_o = mtie;
    assign mie_sw_o = msie;

    assign mie = {20'b0, meie, 3'b0, mtie, 3'b0, msie, 3'b0};

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            meie <= 1'b0;
            mtie <= 1'b0;
            msie <= 1'b0;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MIE_ADDR))begin
            meie <= csr_wr_data_i[11];
            mtie <= csr_wr_data_i[7];
            msie <= csr_wr_data_i[3];
        end
    end
    /*--------------------------------------------- mtvec ----------------------------------------*/
    // The mtvec register is an MXLEN-bit read/write register that holds trap vector configuration,
    // consisting of a vector base address (BASE) and a vector mode (MODE).
    // mtvec = { base[maxlen-1:2], mode[1:0]}
    // The value in the BASE field must always be aligned on a 4-byte boundary, and the MODE setting may impose
    // additional alignment constraints on the value in the BASE field.
    // when mode =2'b00, direct mode, When MODE=Direct, all traps into machine mode cause the pc to be set to the address in the BASE field.
    // when mode =2'b01, Vectored mode, all synchronous exceptions into machine mode cause the pc to be set to the address in the BASE
    // field, whereas interrupts cause the pc to be set to the address in the BASE field plus four times the interrupt cause number.
    reg [`CsrRegBus]        mtvec;
    assign mtvec_o = mtvec;

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mtvec <= `MTVEC_RESET;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MTVEC_ADDR))begin
            mtvec <= csr_wr_data_i;
        end
    end
    /*--------------------------------------------- mscratch ----------------------------------------*/
    // mscratch : Typically, it is used to hold a pointer to a machine-mode hart-local context space and swapped
    // with a user register upon entry to an M-mode trap handler.
    reg [`CsrRegBus]        mscratch;

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mscratch <= `ZeroWord;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MSCRATCH_ADDR))begin
            mscratch <= csr_wr_data_i;
        end
    end
    /*--------------------------------------------- mepc ----------------------------------------*/
    // When a trap is taken into M-mode, mepc is written with the virtual address of the instruction
    // that was interrupted or that encountered the exception.
    // The low bit of mepc (mepc[0]) is always zero.
    // On implementations that support only IALIGN=32, the two low bits (mepc[1:0]) are always zero.
    reg [`CsrRegBus]        mepc;
    assign mepc_o = mepc;

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mepc <= `ZeroWord;
        end
        else if(set_mepc_i)begin
            mepc <= mepc_i;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MEPC_ADDR))begin
            mepc <= csr_wr_data_i;
        end
    end

    /*--------------------------------------------- mcause ----------------------------------------*/
    // When a trap is taken into M-mode, mcause is written with a code indicating the event that caused the trap.
    // Otherwise, mcause is never written by the implementation, though it may be explicitly written by software.
    // mcause = {interupt[31:30], Exception code }
    // The Interrupt bit in the mcause register is set if the trap was caused by an interrupt. The Exception
    // Code field contains a code identifying the last exception.
    reg [`CsrRegBus]        mcause;
    reg                     interrupt;
    reg [26:0]              cause_rem;
    reg [3:0]               cause;

    assign mcause = {interrupt,cause_rem,cause};

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            interrupt <= 1'b0;
            cause_rem <= 27'h0;
            cause <= 4'h0;
        end
        else if(set_cause_i)begin
            interrupt <= cause_type_i;
            cause_rem <= 27'b0;
            cause <= trap_casue_i;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MCAUSE_ADDR))begin
            interrupt <= csr_wr_data_i[31];
            cause_rem <= csr_wr_data_i[30:4];
            cause <= csr_wr_data_i[3:0];
        end

    end
    /*--------------------------------------------- mtval ----------------------------------------*/
    // When a trap is taken into M-mode, mtval is either set to zero or written with exception-specific information
    // to assist software in handling the trap.
    // When a hardware breakpoint is triggered, or an instruction-fetch, load, or store address-misaligned,
    // access, or page-fault exception occurs, mtval is written with the faulting virtual address.
    // On an illegal instruction trap, mtval may be written with the first XLEN or ILEN bits of the faulting instruction
    reg [`CsrRegBus]            mtval;

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mtval <= `ZeroWord;
        end
        else if(set_mtval_i)begin
            mtval <= mtval_i;
        end
        else if((csr_wen == `WriteEnable) && (csr_wr_addr_i == `CSR_MTVAL_ADDR))begin
            mtval <= csr_wr_data_i;
        end
    end
    /*--------------------------------------------- mip ----------------------------------------*/
    // mip: {WPRI[31:12], MEIP(1), WPRI(1), SEIP(1), UEIP(1), MTIP(1), WPRI(1), STIP(1), UTIP(1), MSIP(1), WPRI(1), SSIP(1), USIP(1)}
    // The MTIP, STIP, UTIP bits correspond to timer interrupt-pending bits for machine, supervisor, and user timer interrupts, respectively.
    wire [`CsrRegBus]           mip;
    reg                         mip_meip;
    reg                         mip_mtip;
    reg                         mip_msip;

    assign mip_external_o = mip_meip;
    assign mip_timer_o    = mip_mtip;
    assign mip_sw_o       = mip_msip;

    assign mip = {20'b0, mip_meip, 3'b0, mip_mtip, 3'b0, mip_msip, 3'b0};

    always @(posedge clk)begin
        if(rstn == `RstEnable)begin
            mip_meip <= 1'b0;
            mip_mtip <= 1'b0;
            mip_msip <= 1'b0;
        end
        else begin
            mip_meip <= irq_external_i;
            mip_mtip <= irq_timer_i;
            mip_msip <= irq_software_i;
        end
    end

    /*--------------------------------------------- mcycle ------------------------------------------*/
    // mcycle : counts the number of clock cycles executed by the processor core on which the hart is running.
    // 64-bit precision on all RV32 and RV64 systems.
    reg[63:0] mcycle;   

    /*--------------------------------------------- minstret ----------------------------------------*/
    // minstret:  counts the number of instructions the hart has retired.
    // 64-bit precision on all RV32 and RV64 systems.
    reg[63:0] minstret;

    always @ (posedge clk) begin
        if (rstn == `RstEnable) begin
            mcycle <= {`ZeroWord, `ZeroWord};
            minstret <= {`ZeroWord, `ZeroWord};
        end 
        else begin
            mcycle <= mcycle + 64'd1;
            if(instret_incr_i) begin
                minstret <= minstret + 64'd1;
            end
        end
    end


endmodule