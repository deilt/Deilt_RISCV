// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : gnrl_dffs.v
// Module Name  : gnrl_dffs
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 2023-02-22
// Called By    : 
// Description  : 
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-02-22   Deilt           1.0                     Original
//  
// *********************************************************************************

// ===========================================================================
//1
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is 1
// ===========================================================================
module gnrl_dfflrs#(
    parameter   DW = 32
)
(   
    input                   clk     ,
    input                   rstn    ,
    input                   lden    ,
    input  [DW-1:0]         dnxt    ,
    output [DW-1:0]         qout    
);
    reg [DW-1:0]            qout_r  ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            qout_r <= {DW{1'b1}} ;
        else if(lden == 1'b1)
            qout_r <= #1 dnxt    ;
    end

    assign qout = qout_r ;

    //check x
`ifndef  FPGA_SOURCE
`ifndef  DISABLE_SV_ASSERTION
    gnrl_xchecker #(.DW(1))
    u1_gnrl_xchecker(
        .i_dat(lden),
        .clk(clk)
    );
`endif 
`endif

endmodule

// ===========================================================================
//2
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is 0
// ===========================================================================



// ===========================================================================
//3
// Description:
//  Verilog module sirv_gnrl DFF with Load-enable, no reset 
// ===========================================================================


// ===========================================================================
//4
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 1
// ===========================================================================


// ===========================================================================
//5
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 0
// ===========================================================================


// ===========================================================================
//6 latch
// Description:
//  Verilog module for general latch 
// ===========================================================================