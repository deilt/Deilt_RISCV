// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : prdct.v
// Module Name  : prdct
// Author       : Deilt
// Email        : cjdeilt@qq.com
// Website      : https://github.com/deilt/Deilt_RISC
// Create Time  : 20230317
// Called By    :
// Description  : for branch prediction
// License      : Apache License 2.0
//
//
// *********************************************************************************
// Modification History:
// Date         Auther          Version                 Description
// -----------------------------------------------------------------------
// 2023-03-17   Deilt           1.0                     Original
//  
// *********************************************************************************
module prdct(
    input                           clk                 ,
    input                           rstn                ,
    //from if_id
    input[`InstBus]                 if_id_inst_i        ,
    input[`InstAddrBus]             if_id_instaddr_i    ,
    //to if/pc
    output                          prd_jump_en_o       ,
    output[`InstAddrBus]            prd_jump_addr_o     ,
    //from id  rs1 rs2
    input[`RegBus]                  rs1_data_i          ,
    input[`RegBus]                  rs2_data_i          ,
    
    //to id
    //output                          prd_jump_en_o       ,
    //output[`InstAddrBus]            prd_jump_addr_o     ,
    
    //to ctrl
    output                           prd_jump_en_o       
    
);
    //简单译码(指令是属于普通指令还是分支跳转指令、分支跳转指令的类型和细节)
    wire [6:0]  opcode = inst_i[6:0];



    //简单的分支预测 (简单的静态预测,默认向回即后跳转，BTFN)
    //使用pc的加法器,以节省面积
    //生成跳转判断
    //生成跳转地址




    
    
endmodule