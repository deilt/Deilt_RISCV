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
//0
// Description:
//  Verilog module gnrl DFF with Load-enable and Reset
//  Default reset value is default
// ===========================================================================
module gnrl_dfflrd#(
    parameter   DW = 32
)
(   
    input                   clk     ,
    input                   rstn    ,
    input                   lden    ,
    input  [DW-1:0]         default_vlu ,
    input  [DW-1:0]         dnxt    ,
    output [DW-1:0]         qout    
);
    reg [DW-1:0]            qout_r  ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            qout_r <= default_vlu ;
        else if(lden == 1'b1)
            qout_r <= #1 dnxt     ;
    end

    assign qout = qout_r ;

    //check x
`ifndef  FPGA_SOURCE
`ifdef   ENABLE_SV_ASSERTION
    gnrl_xchecker #(.DW(1))
    u_gnrl_xchecker(
        .i_dat(lden),
        .clk(clk)
    );
`endif 
`endif

endmodule

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
`ifdef   ENABLE_SV_ASSERTION
    gnrl_xchecker #(.DW(1))
    u_gnrl_xchecker(
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
module gnrl_dfflr#(
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
            qout_r <= {DW{1'b0}} ;
        else if(lden == 1'b1)
            qout_r <= #1 dnxt    ;
    end

    assign qout = qout_r ;

    //check x
`ifndef  FPGA_SOURCE
`ifdef   ENABLE_SV_ASSERTION
    gnrl_xchecker #(.DW(1))
    u_gnrl_xchecker(
        .i_dat(lden),
        .clk(clk)
    );
`endif 
`endif

endmodule
// ===========================================================================
//3
// Description:
//  Verilog module sirv_gnrl DFF with Load-enable, no reset 
// ===========================================================================
module gnrl_dffl#(
    parameter   DW = 32
)
(   
    input                   clk     ,
    input                   lden    ,
    input  [DW-1:0]         dnxt    ,
    output [DW-1:0]         qout    
);
    reg [DW-1:0]            qout_r  ;

    always @(posedge clk) begin
        if(lden == 1'b1)
            qout_r <= #1 dnxt    ;
    end

    assign qout = qout_r ;

    //check x
`ifndef  FPGA_SOURCE
`ifdef   ENABLE_SV_ASSERTION
    gnrl_xchecker #(.DW(1))
    u_gnrl_xchecker(
        .i_dat(lden),
        .clk(clk)
    );
`endif 
`endif

endmodule

// ===========================================================================
//4
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 1
// ===========================================================================
module gnrl_dffrs#(
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
        else 
            qout_r <= #1 dnxt    ;
    end

    assign qout = qout_r ;

endmodule

// ===========================================================================
//5
// Description:
//  Verilog module sirv_gnrl DFF with Reset, no load-enable
//  Default reset value is 0
// ===========================================================================
module gnrl_dffr#(
    parameter   DW = 32
)
(   
    input                   clk     ,
    input                   rstn    ,
    input  [DW-1:0]         dnxt    ,
    output [DW-1:0]         qout    
);
    reg [DW-1:0]            qout_r  ;

    always @(posedge clk or negedge rstn) begin
        if(!rstn)
            qout_r <= {DW{1'b0}} ;
        else 
            qout_r <= #1 dnxt    ;
    end

    assign qout = qout_r ;

endmodule
// ===========================================================================
//6 latch
// Description:
//  Verilog module for general latch 
// ===========================================================================
module gnrl_latch#(
    parameter   DW = 32
)
(   
    input                   lden    ,
    input  [DW-1:0]         dnxt    ,
    output [DW-1:0]         qout    
);
    reg [DW-1:0]            qout_r  ;

    always @(*) begin
        if(lden == 1'b1)
            qout_r <=  dnxt    ;
    end

    assign qout = qout_r ;


`ifndef FPGA_SOURCE//{
`ifdef  ENABLE_SV_ASSERTION//{
//synopsys translate_off
always_comb
begin
CHECK_THE_X_VALUE:
    assert (lden !== 1'bx) 
    else $fatal ("\n Error: Oops, detected a X value!!! This should never happen. \n");
end

//synopsys translate_on
`endif//}
`endif//}

endmodule