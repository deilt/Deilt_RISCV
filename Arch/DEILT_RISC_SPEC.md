# 1 概览
## 1 overview
![](./attachment/deilt_riscv_arch.png)


### features
- RV32I（40条指令）（32位通用寄存器,基础整数指令集）
- 拓展指令Ｍ，乘除拓展（4条乘法，2条除法，2条取余），试商法实现除法运算
- 仅支持机器模式（Machine Mode）
- 采用静态预测机制
- 单周期
- 按序发射按序执行按序写回的五级流水线 
- 配备完整的ITCM 和DTCM(Sram)
- verilog 2001语法编写
- 支持JTAG调试
- IP模块包括：中断控制器、计时器（TImer）、UART、SPI
- 模块与模块的接口均采用严谨的 valid-ready 握手接口
- ECC保护sram(?)
- 总线选择ICB(Internal Chip Bus,蜂鸟e203的总线）
- 存储接口：
	- 私有的 ITCM（指令紧耦合存储64bit）与 DTCM（数据紧耦合存储32bit），实现指令与数据的分离存储同时提高性能。(使用不同的总线访问)？？
	- 总线用于访存指令或者数据。？？
	- 中断接口用于与 SoC 级 别的中 断控制器 连接。
	- 紧耦合的私有外设接口，用于访存数据。可以将系统中的私有外设直接接到此接口 上，使得处理器核无须经过与数据和指令共享的总线便可访问这些外设。？？
	- 紧耦合的快速 I/O 接口，用于访存数据。可以将系统中的快速 I/O 模块直接接到此接 口上，使得处理器核无须经过与数据和指令共享的总线便可访问这些模块。？？
	- 所有的 ITCM、DTCM、系统总线接口、私有外设接口以及快速 I/O 接口均可以配置 地址区间。？？

## 2编码风格及注意要点
- 统一采用Verilog RTL编码风格
- 使用标准 DFF 模块例化生成寄存器。(带有 reset 的寄存器面积和时序会稍微差一点, ，因此在数据通路上可以使用不带 reset 的寄存器，而只在控制通路上使用带 reset 的寄存器)
- 推荐使用 Verilog 中的 assign 语法替代 if-else 和 case 语法进行代码编写。
- 由于带有 reset 的寄存器面积和时序会稍微差一点 ，因此在**数据通路**上可以使用不带 reset 的寄存器，而只在**控制通路**上使用带 reset 的寄存器。
- 
### DFF
标准DFF例化的好处
- 便于全局替换寄存器类型
- 便于在寄存器中全局插入延迟
- 明确的 load- enable 使能信号方便综合工具自动插入寄存器级的门控时钟以降低动态功耗
- 便于规避 Verilog 语法 if-else 、case不能传播不定态的问题

![](attachment/gnrl_dffs.png)

## 3 Deilt_RISC core
### features
本项目拟设计一个五级流水的单核32位处理器（Deilt_RISC），采用Verilog编写。其具有以下特点：

- 按序发射按序执行按序写回的五级流水线
- 采用静态预测机制
- RV32I（40条指令）（32位通用寄存器,基础整数指令集）
- 拓展指令Ｍ，乘除拓展（4条乘法，2条除法，2条取余），试商法实现除法运算
- 仅支持机器模式（Machine Mode）
- 配备完整的ITCM 和DTCM(Sram)
- verilog 2001语法编写
- 支持中断
- 模块与模块的接口均采用严谨的 valid-ready 握手接口
- IP模块包括：中断控制器、计时器（TImer）、UART、SPI
- 支持JTAG调试
- 未完待续。。。
- 
### Hierarchy
![](attachment/deilt_riscv_arch.png)



# 2 搭建数据通路
## 1 I 型指令的实现
### I型指令介绍
![](attachment/inst.png)
![](attachment/i.png)
![](attachment/i_opcode.png)
- I型指令通常包括
	- opcode（操作码，7）
	- funct3（功能码，3）
	- rs1（源寄存器1，5）
	- rd（目标寄存器，5）
	- Imm（立即数，12）
	- shamt（位移次数，5）(因为是32位数据，所以最多只能位移32次，5位位宽即可)
其中opcode用于判断指令的类型；func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rd是将运算结果写回的目的寄存器地址，立即数是进行运算操作的数，这里直接给出，可以直接扩展后使用，不需要访问寄存器取值。

通过上图我们可以看到I型指令有9种类型。下面我会一一解释。

```
`ADDI`
- addi rd, rs1, imm
- rd = rs1 + imm
- 将符号扩展的立即数imm的值加上rs1的值，结果写入rd寄存器，忽略算术溢出。
```

```
`ORI`
- ori rd, rs1, imm
- rd = rs1 | imm
- 将rs1的值与符号扩展的立即数imm的值按位或，结果写入rd寄存器，忽略算术溢出。
```

```
`XORI`
- xori rd, rs1, imm
- rd = rs1 ^ imm
- 将rs1与符号位扩展的imm按位异或，结果写入rd寄存器。
```

```
`ANDI`
- andi rd, rs1, imm
- rd = rs1 & imm
- 将rs1与符号位扩展的imm按位与，结果写入rd寄存器。
```

```
`SLLI` shift left logical imm
- slli rd, rs1, shamt
- rd = rs1 << imm
- 将rs1左移shamt位，空出的位补0，结果写入rd寄存器
```

```
`SRLI` shift right logical imm 
- srli rd, rs1, shamt
- rd = rs1 >> imm
- 将rs1右移shamt位，空出的位补0，结果写入rd寄存器
```

```
`SRAI` shift right arith imm(算术位移)
- srai rd, rs1, shamt
- rd = rs1 >> imm
- 将rs1右移shamt位，空出的位用rs1的最高位补充，结果写入rd寄存器
```

```
`SLTI` set less than imm 
- slti rd, rs1, imm
- rd = (rs1 < imm) ? 1:0 ;
- 将符号扩展的立即数imm的值与rs1的值比较(有符号数比较)，如果rs1的值更小，则向rd寄存器写1，否则写0。
```

```
`SLTIU` set less than imm(u)
- sltiu rd, rs1, imm
- rd = (rs1 < imm) ? 1:0 ;
- 将符号扩展的立即数imm的值与rs1的值比较(无符号数比较)，如果rs1的值更小，则向rd寄存器写1，否则写0。
```


### I型指令数据通路图
数据通路的建立如图所示。
![](attachment/pipeline_i.png)
- PC是程序计数器，用于指出指令的地址，即ROM的地址。
- 程序存储在ROM中，目前用ROM代替。
- EX用于进行运算
- RAM是访存会用到的寄存器，目前没有用，可忽略
- WB是将运算结果写回reg（32位通用寄存器，可参考“寄存器”文档）

其中，if_id,id_ex,ex_mem,mem_wb模块均为时序逻辑，信号使用带load_enable使能信号，复位为默认值的寄存器例化模块。
### verilog代码实现
#### define
```
`define CpuResetAddr    32'h0
`define RstEnable       1'b0 
`define True            1'b1
`define False           1'b0

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
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000  //addi rd,rs1,imm            
`define INST_SLTI   3'b010  //SLTI  slti  rd, rs1, imm   $signed(rs1) < $signed(imm) ? 1 : 0
`define INST_SLTIU  3'b011  //sltiu sltiu rd, rs1, imm   rs1 < imm ? 1:0
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111

`define INST_SLLI   3'b001  //逻辑左移 SLLI  slli rd, rs1, imm rd = rs1 << imm (低位补0)
`define INST_SRLI   3'b101  //逻辑右移 SRLI  srli rd, rs1, imm rd = rs1 >> imm (高位补0)
`define INST_SRAI   3'b101  //算术右移 符号位填充
```
#### 文件目录
```
Deilt_RISC                                                                             
├─ Arch                                                                                                                                               
├─ book                                                                                                                                    
├─ DC                                                                                  
├─ isa                                                                                 
│  └─ rom_addi_inst_test.txt             //简单的指令测试文件                                              
├─ libs                                                                                
├─ rtl                                                                                 
│  ├─ core                              //riscv_core                                               
│  │  ├─ ex.v                           //执行模块                                               
│  │  ├─ ex_mem.v                       //ex_mem模块                                               
│  │  ├─ id.v                           //译码模块                                               
│  │  ├─ id_ex.v                                                                       
│  │  ├─ if_id.v                                                                       
│  │  ├─ mem.v                          //访存模块                                               
│  │  ├─ mem_wb.v                                                                      
│  │  ├─ pc.v                           //program counter                                               
│  │  ├─ ram.v                          //存储器                                               
│  │  ├─ regfile.v                      //32位通用寄存器                                               
│  │  ├─ riscv_core.v                   //core                                                
│  │  ├─ rom.v                          //rom，用于存储指令                                               
│  │  └─ wb.v                           //写回模块                                               
│  ├─ debug                                                                            
│  ├─ defines                           //定义文件夹                                               
│  │  └─ defines.v                                                                     
│  ├─ general                                                                          
│  │  ├─ gnrl_dffs.v                    //通用D触发器                                               
│  │  ├─ gnrl_ram.v                     //通用SRAM                                               
│  │  ├─ gnrl_ram_2clock.v                                                             
│  │  └─ gnrl_xchecker.v                //不定态检测模块                                               
│  ├─ perips                                                                           
│  └─ soc                                                                              
├─ sdk                                                                                 
├─ sim                                                                                 
├─ tb                                                                                  
│  ├─ 20230310tb_for_i.v                                                               
│  └─ core_tb(addi).v                  //2023-3-13简单测试add的tb模块                                                
├─ tools                                                                               
├─ LICENSE                                                                             
├─ README.md                                                                           
└─ tree.tree                                      
```
#### Module description
- rom，ram模块例化了gnrl_ram,这是一个sram模块，配备了不定态检测，可以将x强制设为零。其中，读写均在一个时钟周期内完成。同时支持不对齐写入数据。
- 各个流水线寄存器均使用gnrl_dffs里面的模块例化，便于全局替换及插入延时；带有load_enable端口，便于综合工具自动插入寄存器级的门控时钟以降低动态功耗。
- pc采用的是字节寻址，所以pc+4，rom，ram需对输入的地址除以4
- 其他请详见代码
#### testbench for ADD
```
`timescale  1ns/1ps
module core_tb;
    reg clk ;
    reg rstn ;

    //initial
    initial begin
        #0 ;
        clk = 0 ;
        rstn = 0 ;

        #40 ;
        rstn = 1 ;
    end

    //clk gen
    always #10 clk = ~clk ;

    //rom
    initial begin
        $readmemb("../isa/addi.txt",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r);//for sim dir
    end
    //display
    initial begin
        //$readmemb("./rom_addi_inst_test.data",riscv_core.u_rom.u_gnrl_rom.mem_r);
        $display("rom_memb[0] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[0]);
        $display("rom_memb[1] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[1]);
        $display("rom_memb[2] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[2]);


        #100;
        $display("x27 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[27]);
        $display("x28 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[28]);
        $display("x29 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[29]);
        #1000;
        $display("x27 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[27]);
        $display("x28 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[28]);
        $display("x29 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[29]);
        #100 $finish;
    end

    //inst
    riscv_core u_riscv_core(
        .clk(clk),
        .rstn(rstn)
    );
    //stop

endmodule
```
### 编译仿真结果
![](attachment/add_test.jpg)
从图中可以看出，这是典型的五级流水，各个模块正常，没有问题。写进rom的数据在流水线中正确运行，reg中分别写入了数据，符合设计期望。