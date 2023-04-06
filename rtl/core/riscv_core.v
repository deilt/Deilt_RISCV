// *********************************************************************************
// Project Name : Deilt_RISCV
// File Name    : riscv_core.c
// Module Name  : riscv_core
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
// 2023-03-13   Deilt           1.0                     Original
//  
// *********************************************************************************
`include "../defines/defines.v"
module riscv_core(
    input                           clk ,
    input                           rstn
);
    //pc
    wire [`InstAddrBus]         pc_o;
    //rom
    wire [`InstBus]             rom_data_o;
    //if_id
    wire [`InstBus]             if_id_inst_o;
    wire [`InstAddrBus]         if_id_instaddr_o;
    //id
    wire                        rs1_read_o;
    wire                        rs2_read_o;
    wire [`RegAddrBus]          rs1_addr_o;
    wire [`RegAddrBus]          rs2_addr_o;
    wire [`InstBus]             id_inst_o;
    wire [`InstAddrBus]         id_instaddr_o;
    wire [`RegBus]              id_op1_o;
    wire [`RegBus]              id_op2_o;
    wire                        id_regs_wen_o;
    wire [`RegAddrBus]          id_rd_addr_o;
    wire                        id_hold_flag_o;
    wire [`RegBus]              id_rs1_data_o;
    wire [`RegBus]              id_rs2_data_o;
    //reg
    wire [`RegBus]              rs1_data_o;
    wire [`RegBus]              rs2_data_o;
    //id_ex
    wire [`InstBus]             id_ex_inst_o;
    wire [`InstAddrBus]         id_ex_instaddr_o;
    wire [`RegBus]              id_ex_op1_o;
    wire [`RegBus]              id_ex_op2_o;
    wire                        id_ex_regs_wen_o;
    wire [`RegAddrBus]          id_ex_rd_addr_o;
    wire [`RegBus]              id_ex_rs1_data_o ;
    wire [`RegBus]              id_ex_rs2_data_o ;
    wire                        id_ex_jump_en_o;
    //ex
    wire [`InstBus]             ex_inst_o;
    wire [`InstAddrBus]         ex_instaddr_o;

    wire                        cs_o;        
    wire                        mem_we_o;    
    wire [`MemUnit-1:0]         mem_wem_o;     
    wire [`MemBus]              mem_din;     
    wire [`MemAddrBus]          mem_addr_o;  

    wire                        ex_regs_wen_o;
    wire [`RegAddrBus]          ex_rd_addr_o;
    wire [`RegBus]              ex_rd_data_o;
    wire                        ex_hold_flag_o;

    wire                        ex_jump_en_o;
    wire[`InstAddrBus]          ex_jump_base_o;
    wire[`InstAddrBus]          ex_jump_ofst_o;
    wire                        div_start_o;
    wire[`RegBus]               div_dividend_o;
    wire[`RegBus]               div_divisor_o;
    wire[2:0]                   div_op_o;
    wire[`RegAddrBus]           div_reg_waddr_o;

    wire                        mul_start_o ;
    wire[`RegBus]               mul_multiplicand_o;
    wire[`RegBus]               mul_multiplier_o;
    wire[2:0]                   mul_op_o;
    wire[`RegAddrBus]           ex_mul_reg_waddr_o;
    //ex_mem
    wire [`InstBus]             ex_mem_inst_o;
    wire [`InstAddrBus]         ex_mem_instaddr_o;

    //wire                        ex_mem_cs_o;        
    //wire                        ex_mem_we_o;    
    //wire [`MemUnit-1:0]         ex_mem_wem_o;     
    //wire [`MemBus]              ex_mem_dout;     
    wire [`MemAddrBus]          ex_mem_addr_o; 

    wire                        ex_mem_regs_wen_o;
    wire [`RegAddrBus]          ex_mem_rd_addr_o;
    wire [`RegBus]              ex_mem_rd_data_o;

    //mem
    wire [`InstBus]             mem_inst_o;
    wire [`InstAddrBus]         mem_instaddr_o;
    wire                        mem_regs_wen_o;
    wire [`RegAddrBus]          mem_rd_addr_o;
    wire [`RegBus]              mem_rd_data_o;
    
    //ram
    wire [`MemBus]              mem_data_o;

    //mem_wb
    wire [`InstBus]             mem_wb_inst_o;
    wire [`InstAddrBus]         mem_wb_instaddr_o;
    wire                        mem_wb_regs_wen_o;
    wire [`RegAddrBus]          mem_wb_rd_addr_o;
    wire [`RegBus]              mem_wb_rd_data_o;

    //wb
    wire                        wb_regs_wen_o;
    wire [`RegAddrBus]          wb_rd_addr_o;
    wire [`RegBus]              wb_rd_data_o;
    //ctrl
    wire [4:0]                  hold_en_o;
    wire                        prd_fail;
    //prd
    wire                        prd_jump_en_o;
    wire [`InstAddrBus]         prd_jump_base_o;
    wire [`InstAddrBus]         prd_jump_ofset_o;
    
    //ex_mdu
    wire[`RegBus]               mdu_result_o;
    wire                        mdu_ready_o;
    wire                        mdu_busy_o;
    wire[`RegAddrBus]           mdu_reg_waddr_o;

    //ex_mul
    wire                        mul_ready_o;
    wire[`RegBus]               mul_res_o;
    wire                        mul_busy_o;
    wire[`RegAddrBus]           mul_reg_waddr_o;

    //prd
    prdct u_prdct(
        .clk              (clk                  ),      
        .rstn             (rstn                 ),
        .inst_i           (if_id_inst_o         ),    
        .instaddr_i       (if_id_instaddr_o     ),
        .prd_jump_en_o    (prd_jump_en_o        ),
        .prd_jump_base_o  (prd_jump_base_o      ),
        .prd_jump_ofset_o (prd_jump_ofset_o     ),
        .rs1_data_i       (rs1_data_o           ),
        .rs2_data_i       (rs2_data_o           ),
        .rs1_addr_i       (rs1_addr_o           ),
        .rs2_addr_i       (rs2_addr_o           ),
        .rs1_read_i       (rs1_read_o           ),
        .rs2_read_i       (rs2_read_o           ),
        .ex_wen_i         (ex_regs_wen_o        ),
        .ex_wr_addr_i     (ex_rd_addr_o         ),
        .ex_wr_data_i     (ex_rd_data_o         ),
        .mem_wen_i        (mem_regs_wen_o       ),
        .mem_wr_addr_i    (mem_rd_addr_o        ),
        .mem_wr_data_i    (mem_rd_data_o        ) 
    );

    //ctrl
    ctrl u_ctrl(
        .clk            (clk            ),
        .rstn           (rstn           ),

        .ex_hold_flag_i (ex_hold_flag_o ),
        .ex_jump_en_i   (ex_jump_en_o   ),
        .ex_jump_base_i (ex_jump_base_o ),
        .ex_jump_ofst_i (ex_jump_ofst_o ),
        .prd_jump_en_i  (prd_jump_en_o  ),
        .prd_fail       (prd_fail       ),
        .id_ex_jump_en_i(id_ex_jump_en_o),
        .id_hold_flag_i (id_hold_flag_o ),
        .hold_en_o      (hold_en_o      )
    );

    //pc
    pc u_pc(
        .clk                (clk                ),
        .rstn               (rstn               ),
        .hold_en_i          (hold_en_o          ),
        .prd_fail           (prd_fail           ),

        .ex_instaddr_i      (ex_instaddr_o      ),
        .ex_jump_en_i       (ex_jump_en_o       ),
        .ex_jump_base_i     (ex_jump_base_o     ),
        .ex_jump_ofset_i    (ex_jump_ofst_o     ),
        .prd_jump_en_i      (prd_jump_en_o      ), 
        .prd_jump_base_i    (prd_jump_base_o    ),
        .prd_jump_ofset_i   (prd_jump_ofset_o   ),
        .pc_o               (pc_o               )
    );

    //rom
    rom u_rom(
        .clk            (clk        ),
        .instaddr       (pc_o         ),
        .data_in        (`ZeroWord  ),
        .cs             (1'b1       ),
        .we             (1'b0       ),
        .wem            (4'h0       ),
        .data_o         (rom_data_o )        
    );

    //if_id
    if_id u_if_id(
        .clk            (clk             ),
        .rstn           (rstn            ),
        .inst_i         (rom_data_o      ),
        .instaddr_i     (pc_o              ),
        .inst_o         (if_id_inst_o    ),
        .instaddr_o     (if_id_instaddr_o),
        .hold_en_i      (hold_en_o       )  
    );

    //id
    id u_id(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .inst_i         (if_id_inst_o       ),
        .instaddr_i     (if_id_instaddr_o   ),
        .rs1_data_i     (rs1_data_o         ),
        .rs2_data_i     (rs2_data_o         ),
        .rs1_addr_o     (rs1_addr_o         ),
        .rs2_addr_o     (rs2_addr_o         ),
        .rs1_read_o     (rs1_read_o         ),
        .rs2_read_o     (rs2_read_o         ),
        .inst_o         (id_inst_o          ),
        .instaddr_o     (id_instaddr_o      ),
        .op1_o          (id_op1_o           ),
        .op2_o          (id_op2_o           ),
        .id_rs1_data_o  (id_rs1_data_o      ),
        .id_rs2_data_o  (id_rs2_data_o      ),
        .regs_wen_o     (id_regs_wen_o      ),
        .rd_addr_o      (id_rd_addr_o       ),
        .ex_inst_i      (ex_inst_o          ),
        .ex_wen_i       (ex_regs_wen_o      ),
        .ex_wr_addr_i   (ex_rd_addr_o       ),
        .ex_wr_data_i   (ex_rd_data_o       ),
        .mem_wen_i      (mem_regs_wen_o     ),
        .mem_wr_addr_i  (mem_rd_addr_o      ),
        .mem_wr_data_i  (mem_rd_data_o      ),
        .hold_flag_o    (id_hold_flag_o     )        
    );
    //reg
    regfile u_regfile(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .rs1_addr_i     (rs1_addr_o         ),
        .rs2_addr_i     (rs2_addr_o         ),
        .rs1_read_i     (rs1_read_o         ),
        .rs2_read_i     (rs2_read_o         ),
        .rs1_data_o     (rs1_data_o         ),
        .rs2_data_o     (rs2_data_o         ),
        .wen            (wb_regs_wen_o      ),
        .wr_addr_i      (wb_rd_addr_o       ),
        .wr_data_i      (wb_rd_data_o       )
    );

    //id_ex
    
    id_ex u_id_ex(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .inst_i         (id_inst_o          ),
        .instaddr_i     (id_instaddr_o      ),
        .op1_i          (id_op1_o           ),
        .op2_i          (id_op2_o           ),
        .regs_wen_i     (id_regs_wen_o      ),
        .rd_addr_i      (id_rd_addr_o       ),
        .rs1_data_i     (id_rs1_data_o      ),
        .rs2_data_i     (id_rs2_data_o      ),
        .inst_o         (id_ex_inst_o       ),
        .instaddr_o     (id_ex_instaddr_o   ),
        .op1_o          (id_ex_op1_o        ),
        .op2_o          (id_ex_op2_o        ),
        .regs_wen_o     (id_ex_regs_wen_o   ),
        .rd_addr_o      (id_ex_rd_addr_o    ),
        .rs1_data_o     (id_ex_rs1_data_o   ),
        .rs2_data_o     (id_ex_rs2_data_o   ),
        .prd_jump_en_o  (id_ex_jump_en_o    ),
        .prd_jump_en_i  (prd_jump_en_o      ),
        .hold_en_i      (hold_en_o          )        
    );

    //ex
    ex u_ex(
        .clk            (clk                ), 
        .rstn           (rstn               ), 
        .inst_i         (id_ex_inst_o       ), 
        .instaddr_i     (id_ex_instaddr_o   ),
        .rs1_data_i     (id_ex_rs1_data_o   ),
        .rs2_data_i     (id_ex_rs2_data_o   ),
        .op1_i          (id_ex_op1_o        ), 
        .op2_i          (id_ex_op2_o        ), 
        .regs_wen_i     (id_ex_regs_wen_o   ), 
        .rd_addr_i      (id_ex_rd_addr_o    ), 
        .inst_o         (ex_inst_o          ), 
        .instaddr_o     (ex_instaddr_o      ), 
        .cs_o           (cs_o               ), 
        .mem_we_o       (mem_we_o           ), 
        .mem_wem_o      (mem_wem_o          ), 
        .mem_din        (mem_din            ), 
        .mem_addr_o     (mem_addr_o         ), 
        .regs_wen_o     (ex_regs_wen_o      ), 
        .rd_addr_o      (ex_rd_addr_o       ), 
        .rd_data_o      (ex_rd_data_o       ),
        .ex_hold_flag_o (ex_hold_flag_o     ),
        .ex_jump_en_o   (ex_jump_en_o       ),
        .ex_jump_base_o (ex_jump_base_o     ),
        .ex_jump_ofst_o (ex_jump_ofst_o     ),
        .div_ready_i    (mdu_ready_o        ),
        .div_res_i      (mdu_result_o       ),
        .div_busy_i     (mdu_busy_o         ),
        .div_reg_waddr_i(mdu_reg_waddr_o    ),
        .div_start_o    (div_start_o        ),
        .div_dividend_o (div_dividend_o     ),
        .div_divisor_o  (div_divisor_o      ),
        .div_op_o       (div_op_o           ),
        .div_reg_waddr_o(div_reg_waddr_o    ),
        .mul_ready_i       (mul_ready_o     ), 
        .mul_res_i         (mul_res_o       ),
        .mul_busy_i        (mul_busy_o      ),
        .mul_reg_waddr_i   (mul_reg_waddr_o ),
        .mul_start_o       (mul_start_o     ),
        .mul_multiplicand_o(mul_multiplicand_o),
        .mul_multiplier_o  (mul_multiplier_o),
        .mul_op_o          (mul_op_o        ),
        .mul_reg_waddr_o   (ex_mul_reg_waddr_o)
    );

    //ex_mdu
    ex_mdu u_ex_mdu(
        .clk            (clk),
        .rstn           (rstn),
        .dividend_i     (div_dividend_o     ),
        .divisor_i      (div_divisor_o      ),
        .start_i        (div_start_o        ),
        .op_i           (div_op_o           ),
        .reg_waddr_i    (div_reg_waddr_o    ),
        .result_o       (mdu_result_o       ),
        .ready_o        (mdu_ready_o        ),
        .busy_o         (mdu_busy_o         ),
        .reg_waddr_o    (mdu_reg_waddr_o    )
    );

    //ex_mul
    ex_mul u_ex_mul(
        .clk                (clk                ),
        .rstn               (rstn               ),
        .mul_start_i        (mul_start_o        ),
        .mul_multiplicand_i (mul_multiplicand_o ),
        .mul_multiplier_i   (mul_multiplier_o   ),
        .mul_op_i           (mul_op_o           ),
        .mul_reg_waddr_i    (ex_mul_reg_waddr_o ),
        .mul_ready_o        (mul_ready_o        ),
        .mul_res_o          (mul_res_o          ),
        .mul_busy_o         (mul_busy_o         ),
        .mul_reg_waddr_o    (mul_reg_waddr_o    )
    );
    //ex_mem
    ex_mem u_ex_mem(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .inst_i         (ex_inst_o          ),
        .instaddr_i     (ex_instaddr_o      ),
        //.cs_i           (cs_o               ),
        //.mem_we_i       (mem_we_o           ),
        //.mem_wem_i      (mem_wem_o          ),
        //.mem_din        (mem_din            ),
        .mem_addr_i     (mem_addr_o         ),
        .regs_wen_i     (ex_regs_wen_o      ),
        .rd_addr_i      (ex_rd_addr_o       ),
        .rd_data_i      (ex_rd_data_o       ),
        .inst_o         (ex_mem_inst_o      ),
        .instaddr_o     (ex_mem_instaddr_o  ),
        //.cs_o           (ex_mem_cs_o        ),
       // .mem_we_o       (ex_mem_we_o        ),
        //.mem_wem_o      (ex_mem_wem_o       ),
        //.mem_dout       (ex_mem_dout        ),
        .mem_addr_o     (ex_mem_addr_o      ),
        .regs_wen_o     (ex_mem_regs_wen_o  ),
        .rd_addr_o      (ex_mem_rd_addr_o   ),
        .rd_data_o      (ex_mem_rd_data_o   ),
        .hold_en_i      (hold_en_o          )
    );

    //mem
    mem u_mem(
        .clk            (clk                ), 
        .rstn           (rstn               ), 
        .inst_i         (ex_mem_inst_o      ), 
        .instaddr_i     (ex_mem_instaddr_o  ), 
        .regs_wen_i     (ex_mem_regs_wen_o  ), 
        .rd_addr_i      (ex_mem_rd_addr_o   ), 
        .rd_data_i      (ex_mem_rd_data_o   ), 
        .mem_addr_i     (ex_mem_addr_o      ),
        .mem_data_i     (mem_data_o         ), 
        .inst_o         (mem_inst_o         ), 
        .instaddr_o     (mem_instaddr_o     ), 
        .regs_wen_o     (mem_regs_wen_o     ), 
        .rd_addr_o      (mem_rd_addr_o      ), 
        .rd_data_o      (mem_rd_data_o      )
    );

    //ram
    ram u_ram(
        .clk            (clk                ),
        .addr           (mem_addr_o         ),
        .data_in        (mem_din            ),
        .cs             (cs_o               ),
        .we             (mem_we_o           ),
        .wem            (mem_wem_o          ),
        .mem_data_o     (mem_data_o         )
    );

    //mem_wb
    mem_wb u_mem_wb(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .inst_i         (mem_inst_o         ),
        .instaddr_i     (mem_instaddr_o     ),
        .regs_wen_i     (mem_regs_wen_o     ),
        .rd_addr_i      (mem_rd_addr_o      ),
        .rd_data_i      (mem_rd_data_o      ),
        .inst_o         (mem_wb_inst_o      ),
        .instaddr_o     (mem_wb_instaddr_o  ),
        .regs_wen_o     (mem_wb_regs_wen_o  ),
        .rd_addr_o      (mem_wb_rd_addr_o   ),
        .rd_data_o      (mem_wb_rd_data_o   ),
        .hold_en_i      (hold_en_o          )
    );

    //wb
    wb u_wb(
        .clk            (clk                ),
        .rstn           (rstn               ),
        .inst_i         (mem_wb_inst_o      ),
        .instaddr_i     (mem_wb_instaddr_o  ),
        .regs_wen_i     (mem_wb_regs_wen_o  ),
        .rd_addr_i      (mem_wb_rd_addr_o   ),
        .rd_data_i      (mem_wb_rd_data_o   ),
        .regs_wen_o     (wb_regs_wen_o      ),
        .rd_addr_o      (wb_rd_addr_o       ),
        .rd_data_o      (wb_rd_data_o       )
    );
endmodule
