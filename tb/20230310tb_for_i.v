
`timescale  1ns/1ps

module tinyrisc_v_soc_tb;
    reg clk ;
    reg rst ;

    wire x3 = tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_tinyrisc_v.u_regs.regs_memb[3];
    wire x26 = tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_tinyrisc_v.u_regs.regs_memb[26];
    wire x27 = tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_tinyrisc_v.u_regs.regs_memb[27];
    integer r ;
    //initial
    initial begin
        #0 ;
        clk = 0 ;
        rst = 0 ;

        #40 ;
        rst = 1 ;
    end

    //clk gen
    always #10 clk = ~clk ;

    //rom read txt
    initial begin
        $readmemh("../generated/rv32ui-p-auipc.txt",tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_rom.rom_memb);
        $display("rom[0] %h",tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_rom.rom_memb[0]);
    end
    //display
    initial begin
        wait(x26 == 32'h1);
        $display("regs[26] %h",x26);
        #40;
        if(x27 == 32'h1)begin
            $display("######################");
            $display("###########succeed!!!#########");
            $display("######################");
            $display("regs[26] %h",x26);
            $display("regs[27] %h",x27);
            #20 $finish;
        end
        else begin
            $display("######################");
            $display("###########fail !!!#########");
            $display("######################");
            $display("faild test: %d",x3);
            for(r = 0;r<31;r = r + 1)begin
                $display("x%2d register value is %d",r,tinyrisc_v_soc_tb.u_tinyrisc_v_soc.u_tinyrisc_v.u_regs.regs_memb[r]);
            end
            #20 $finish;
        end
    end

    //inst
    tinyrisc_v_soc u_tinyrisc_v_soc(
        .clk(clk),
        .rst(rst)
    );
endmodule