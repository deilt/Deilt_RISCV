// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : gnrl_ram.v
// Module Name  : gnrl_ram
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISCV
// Create Time  : 
// Called By    :
// Description  : sram module
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-01   Deilt           1.0                     Original
//  
// *********************************************************************************
//这个有点问题读操作不能够一周期内读出
module gnrl_ram 
#(
    parameter DP = 512,             //RAM的深度（即RAM中可以存储多少个单元）。
    parameter AW = 32,              //地址宽度，表示可以寻址多少个RAM单元。
    parameter DW = 32,              //每组RAM单元的数据宽度。
    parameter MW = 4,               //写使能端口数，表示可以同时写入几个RAM单元
    parameter FORCE_X2ZERO = 0      //如果为1，则当RAM单元读出未定义（'x'）时，将其强制设置为0。如果为0，则将其保留为未定义。
)
(
    input               clk , 
    input  [DW-1  :0]   din , 
    input  [AW-1  :0]   addr,
    input               cs  ,
    input               we  ,
    input  [MW-1:0]     wem ,          //写使能端口选择信号，用于选择要写入的RAM单元。
    output [DW-1:0]     dout
);

    reg [DW-1:0] mem_r [0:DP-1];
    reg [AW-1:0] addr_r;
    wire [MW-1:0] wen;            //写使能信号，用于选择要写入的RAM单元
    wire ren;                     //读使能信号，用于控制读操作

    assign ren = cs & (~we);
    assign wen = ({MW{cs & we}} & wem);

    genvar i;

    always @(posedge clk)
    begin
        if (ren) begin
            addr_r <= addr;
        end
    end

    //考虑了DW不是8的整数倍的时候，数据没有对齐则会使用第一种情况
    generate
        for (i = 0; i < MW; i = i+1) begin :mem
            if((8*i+8) > DW ) begin: last
            always @(posedge clk) begin
                if (wen[i]) begin
                mem_r[addr][DW-1:8*i] <= din[DW-1:8*i];
                end
            end
            end
            else begin: non_last
            always @(posedge clk) begin
                if (wen[i]) begin
                mem_r[addr][8*i+7:8*i] <= din[8*i+7:8*i];
                end
            end
            end
        end
    endgenerate

    wire [DW-1:0] dout_pre;
    assign dout_pre = mem_r[addr_r];

    generate
    if(FORCE_X2ZERO == 1) begin: force_x_to_zero
        for (i = 0; i < DW; i = i+1) begin:force_x_gen 
            `ifndef SYNTHESIS//{
                assign dout[i] = (dout_pre[i] === 1'bx) ? 1'b0 : dout_pre[i];
            `else//}{
                assign dout[i] = dout_pre[i];
            `endif//}
        end
    end
    else begin:no_force_x_to_zero
        assign dout = dout_pre;
    end
    endgenerate

endmodule