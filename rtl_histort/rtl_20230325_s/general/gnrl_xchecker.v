// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : gnrl_xchecker.v
// Module Name  : gnrl_xchecker
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 2023-02-22
// Called By    :
// Description  : This is a Verilog module named gnrl_xchecker 
//                which is designed to check for X values in the input data i_dat. 
//                X is a special value in Verilog that represents an unknown or uninitialized state of a signal. X values can cause unexpected behavior and simulation errors in Verilog designs.
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

`ifndef FPGA_SOURCE//{  //若没有定义则编译
`ifdef  ENABLE_SV_ASSERTION//{
//synopsys translate_off
module gnrl_xchecker #(
    parameter DW = 32
) 
(
    input   [DW-1:0] i_dat,
    input            clk
);


CHECK_THE_X_VALUE:
    assert property (@(posedge clk) 
                        ((^(i_dat)) !== 1'bx)
                    )
    else $fatal ("\n Error: Oops, detected a X value!!! This should never happen. \n");

endmodule
//synopsys translate_on
`endif//}
`endif//}