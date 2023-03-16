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



# 2 搭建数据通路（RV32I，Base Integer Instructions，40条）

![image-20230315163017147](attachment/inst_AA.png)

## 2.1 I 型指令的实现
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

通过上图我们可以看到I型指令的其中9种类型。下面我会一一解释。

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

### 流水线冒险

由上可知已经建立了五级流水线，到此为止，它是一个十分简单的流水线，但是它解决不了实际中遇到的一些问题。所以现在必须面对的问题是流水线冒险，在流水线正常运行的过程中，会遇到一些相关性的问题，这些问题会造成指令在运行的某个阶段产生错误，以致整条流水线出错。

#### 流水线数据相关性

`结构冒险`： 因**缺乏硬件**支持而导致指令不能在预定的时钟周期内执行的情况。即，硬件不支持多条指令在同一时钟周期执行。

`数据冒险`： 因无法提供指令执行所需的**数据**而导致指令不能在预定的时钟周期内执行。即，一条指令依赖于前面一条尚在流水线中指令。

- 解决方法：前递，不需要等待指令完成就可以尝试解决数据冒险。
  - 其中，数据冒险又有RAW，WAR，WAW
  - RAW是此条流水线必须会遇到的情况。我们主要解决RAW。

`控制冒险`(分支冒险)： 由于取到的指令不是所需要的，或者指令地址的流向不是流水线所预期的，导致**正确的指令**无法在正确的时钟周期内执行。

- 解决方法：停顿、预测、延迟转移（放一条不受影响的指令

#### 数据冒险（RAW）情况与解决（load冒险先不考虑）

`发生冒险的三种情况`

- **相邻指令**间存在数据相关

>![image-20230314173556527](attachment/raw1.png)
>
>上图中，第一条指令需要将执行的结果写回reg的\$1中，但是第二条指令需要读$1。第一条指令在wb阶段最后一个时钟上升沿才能写\$1，所以第二条指令从reg中读出的数据是错误的，且执行结果也是错误的。

- **相隔1条**指令间存在数据相关

>![image-20230314193814777](attachment/raw2.png)
>
>第一条指令需要将执行的结果写回reg的\$1中，但是第三条指令需要读寄存器$1。此时第一条指令处于访存阶段，所以得到的值是错误的。

- **相隔2条**指令间存在数据相关

>![image-20230314194210931](attachment/raw3.png)
>
>此时，第一条指令需要将执行的结果写回reg的\$1中，相对于第四条指令的译码阶段，第一条指令处于写回阶段，但是第四条指令需要读寄存器$1，所以得到的是错误的值。
>
>这种情况下，对于第一条指令，此时处于写回阶段，且其端口的写数据、地址、写使能连接的是reg，因此，可以在reg模块中将数据直接传递给处于译码阶段的第四条指令。



`解决方法`

- **插入气泡**

  - 当检测到相关后，在流水线中插入气泡，暂停一些周期。
  - ![image-20230314200201352](attachment/pop.png)

- **编译器调度**

  - 编译器检测到相关后，可以改变部分无关指令的**执行顺序**，从而去除数据相关的影响。

- **数据前递**

  - 将计算出的结果直接送到其他指令所需要处，避免流水线暂停。
  - 但是，对于load指令，所需要的数据没有在执行阶段产生，而是在访存阶段产生。这种情况后面给出解决方案。
  - ![image-20230314200513900](attachment/maoxianjiejue.png)

  

#### 解决数据冲突流水线

![image-20230314202014604](attachment/pipeline_ct.png)

代码修改请自行参考RTL目录。

1. 修改regfile，将wb写回的数据地址，与此时读regfile的地址对比，如果相同，则将wb写回的数据赋值给读端口。同时添加了读使能。
2. 修改ID模块。
3. 修改riscv_core模块。

##### 仿真测试

###### 仿真测试tb

```verilog
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
        $readmemb("../isa/rom_addi_inst_test_relation.txt",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r);//for sim dir
    end
    //display
    initial begin
        //$readmemb("./rom_addi_inst_test.data",riscv_core.u_rom.u_gnrl_rom.mem_r);
        $display("rom_memb[0] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[0]);
        $display("rom_memb[1] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[1]);
        $display("rom_memb[2] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[2]);
        $display("rom_memb[3] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[3]);
        $display("rom_memb[4] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[4]);
        $display("rom_memb[5] rom_memb value is %b",core_tb.u_riscv_core.u_rom.u_gnrl_rom.mem_r[5]);


        #1000;
        $display("x1 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[1]);
        $display("x2 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[2]);
        $display("x3 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[3]);
        $display("x4 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[4]);
        $display("x5 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[5]);
        //$display("x29 regs value is %d",core_tb.u_riscv_core.u_regfile.regs_mem[29]);
        #100 $finish;
    end

    //inst
    riscv_core u_riscv_core(
        .clk(clk),
        .rstn(rstn)
    );
endmodule
```

![image-20230315152717413](attachment/isa_addi_pip.png)

##### 测试结果

![image-20230315152157900](attachment/pipeline_adv_sim.png)

## 2.2 R型指令的实现

### R型指令介绍

![](attachment/inst.png)

![image-20230315155912021](attachment/r_inst.png)

![image-20230315161930941](attachment/r_inst_opcode.png)

R型指令通常包括

- opcode（操作码，7）
- funct3（功能码，3）
- rs1（源寄存器1，5）
- rs2（源寄存器1，5）
- rd（目标寄存器，5）
- funct7（功能码，7）
  其中opcode用于判断指令的类型与M拓展指令相同（0110011）；funct7用于进一步分辨是R型还是M拓展指令，func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rs2也是需要访问通用寄存器的地址，将取到的值用于运算操作；rd是将运算结果写回的目的寄存器地址。



通过上图我们可以看到R型指令有10种类型。下面我会一一解释。

```c
`ADD`
- ADD rd，rs1，rs2
- x[rd] = x[rs1] + x[rs2]
- 将rs1寄存器的值加上rs2寄存器的值，然后将结果写入rd寄存器里，忽略算术溢出。
```

```
`SUB`(subtract)
- sub rd, rs1, rs2
- x[rd] = x[rs1] - x[rs2]
- 将rs1寄存器的值减去rs2寄存器的值，然后将结果写入rd寄存器里，忽略算术溢出。
```

```c
`SLL`（shift left logical）
- sll rd, rs1, rs2
- x[rd] = x[rs1] << x[rs2]
- 将rs1左移rs2位(低5位有效)，空出的位补0，结果写入rd寄存器。
```

```
`SLT`（set less than）
- slt rd, rs1, rs2
- x[rd] = (x[rs1] <  x[rs2])? 1:0
- 将rs1的值与rs2的值比较(有符号数比较)，如果rs1的值更小，则向rd寄存器写1，否则写0。
```

```c
`SLTU`（set less than unsigned）
- sltu rd, rs1, rs2
- x[rd] = (x[rs1] <  x[rs2])? 1:0
- 将rs1的值与rs2的值比较(无符号数比较)，如果rs1的值更小，则向rd寄存器写1，否则写0。
```

```
`XOR`（exclusive or）
- xor rd, rs1, rs2
- x[rd] = x[rs1] ^ x[rs2]
- 将rs1与rs2按位异或，结果写入rd寄存器
```

```c
`SRL`（shift right logical）
- srl rd, rs1, rs2
- x[rd] = x[rs1] >> x[rs2]
- 将rs1右移rs2位(低5位有效)，空出的位补0，结果写入rd寄存器。
```

```
`SRA`（shift right arithmetic）
- sra rd, rs1, rs2
- x[rd] = x[rs1] >> x[rs2]
- 将rs1右移rs2位(低5位有效)，空出的位用rs1的最高位补充，结果写入rd寄存器。
```

```c
`OR`（or）
- or rd, rs1, rs2
- x[rd] = x[rs1] | x[rs2]
- 将rs1与rs2按位或，结果写入rd寄存器
```

```
`AND`（and）
- and rd, rs1, rs2
- x[rd] = x[rs1] + x[rs2]
- 将rs1与rs2按位与，结果写入rd寄存器。
```



### R型指令数据通路图

![](attachment/pipeline_ct.png)

### verilog代码实现

- 补全R型指令
- 修改了regfile里面的赋值情况(bug)
- 修改了ID，EX模块
- 代码请参考`rtl_history/rtl_20230316_pipeline_m_inst`文件夹

### 编译仿真结果

- R型指令测试用例：

  ```
  000000000001_00000_000_00001_0010011 //addi $1,$0,1
  000000000010_00000_000_00010_0010011 //addi $2,$0,2
  000000000011_00000_000_00011_0010011 //addi $3,$0,3
  000000000100_00000_000_00100_0010011 //addi $4,$0,4
  000000000101_00000_000_00101_0010011 //addi $5,$0,5
  000000000110_00000_000_00110_0010011 //addi $6,$0,6
  //test R inst
  //add 0000000_rs2_rs1_000_rd_0110011
  0000000_00010_00001_000_00111_0110011 //add $7,$1,$2
  0100000_00010_00011_000_01000_0110011//sub $8,$3,$2
  0000000_00001_00011_001_01001_0110011//SLL $9,$3,$1
  0000000_00100_00011_010_01010_0110011//SLT $10,$3,$4
  0000000_00100_00011_100_01011_0110011//XOR $11,$3,$4
  0000000_00001_00011_101_01100_0110011//SRl $12,$3,$1
  0100000_00001_00011_101_01101_0110011//SRA$13,$3,$1
  0000000_00001_00011_110_01110_0110011//OR $14,$3,$1
  0000000_00001_00011_111_01111_0110011//AND $15,$3,$1
  ```

- 仿真结果

  - tb文件参考`tb_history/tb_20230316_pipeline_m_inst/core_tb.v`
  - 仿真问价参考`sim_history/sim_20230316_pipeline_m_inst`

  ![image-20230316170845293](attachment/sim_r_0.png)

  

## 2.3 流水线暂停

在流水线进行的过程中，由于乘法、除法、访存等指令可能在执行阶段或者访存阶段需要占用多个时钟周期，因此需要暂停流水线。

本设计中，执行阶段的乘法、除法指令（RV32M）需要多个时钟周期，但是访存阶段的访存指令能够在一个时钟周期内完成读写操作，所以不考虑访存阶段的流水线暂停。暂停信号仅由执行阶段发出。

具体的实现方法如下：

- 假如，位于流水线执行阶段的指令需要多个时钟周期，进而请求流水线暂停
- 那么，需要保持取指地址PC不变
- 同时保持流水线当前阶段（执行阶段）不变，同时，之前的各个阶段的寄存器不变，
- 当前阶段的后面的指令继续进行。



因此，添加CTRL模块，作用是接受各个阶段传递过来的流水线暂停请求信号。从而控制力流水线各阶段的运行。

为了实现流水线暂停机制，对系统结构作了如下修改。

![image-20230316220233041](attachment/pipeline_ctrl.png)

执行阶段向CTRL模块发出流水线暂停请求，由CTRL模块产生流水线暂停信号，输出到PC、IF/ID、ID/EX、EX/MEM、MEM/WB等模块，从而控制PC的值，以及流水线各个阶段的寄存器。



## 2.4 跳转指令的实现(JAL=J型,JALR=I型)

### 跳转指令介绍

<img src="attachment/inst.png" />

![image-20230315162045939](attachment/j_inst.png)

![image-20230315162121675](attachment/j_inst_opcode.png)

跳转指令通常包括

- opcode（操作码，7）

- funct3（功能码，3）

- rs1（源寄存器1，5）

- rd（目标寄存器，5）

- Imm（立即数，12）

  其中opcode用于判断指令的类型，func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rd是将运算结果写回的目的寄存器地址;IMM立即数是进行运算操作的数，这里直接给出，可以直接扩展后使用，不需要访问寄存器取值。

  

通过上图我们可以看到跳转指令有2种类型。下面我会一一解释。

```c
`JAL`(jump and link)
- JAL rd，offset  /   JAL rd，imm
- x[rd] = pc+4; pc += sext(offset)   /   x[rd] = pc+4; pc += imm
- 把下一条指令的地址(PC+4)存入rd寄存器中，然后把PC设置为当前值加上符号位扩展的偏移量
```

```
`JALR`(jump and link reg)
- JALR rd，offset(rs1)   /   JALR rd，(imm)rs1
- x[rd] = pc+4; pc = rs1 + offset   /   x[rd] = pc+4; pc = rs1 + imm
- 将PC设置为rs1寄存器中的值加上符号位扩展的偏移量，把计算出地址的最低有效位设为0，并将原PC+4的值写入rd寄存器.如果不需要目的寄存器，可以将rd设置为x0。
- 将最低有效位设置为0的原因是为了保证跳转地址是4字节对齐的，因为RISCV 32位的指令长度都是4字节的.
```





### 跳转指令数据通路图



### verilog代码实现



### 编译仿真结果



## 2.4 B型指令的实现

### B型指令介绍

![](attachment/inst.png)

![image-20230315162208139](attachment/b_inst.png)

![image-20230315162238865](attachment/b_inst_opcode.png)



B型指令通常包括

- opcode（操作码，7）

- funct3（功能码，3）

- rs1（源寄存器1，5）

- rs2（源寄存器1，5）

- Imm（立即数，12）

  其中opcode用于判断指令的类型，func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rs2也是需要访问通用寄存器的地址，将取到的值用于运算操作；;IMM立即数是进行运算操作的数，这里直接给出，可以直接扩展后使用，不需要访问寄存器取值。

  

通过上图我们可以看到分支指令有6种类型。下面我会一一解释。imm/offset

```c
`BEQ`(相等时分支跳转 (Branch if Equal))
- beq rs1, rs2, imm/(offset) 
- if (rs1 == rs2) pc += imm
- 若寄存器 x[rs1]和寄存器 x[rs2]的值相等，把pc的值设为当前值加上符号位扩展的偏移 imm (offset)。
```

```c
`BNE`(不相等时分支跳转 (Branch if Not Equal))
- bne rs1, rs2, imm
- if (rs1 ≠ rs2) pc += imm
- 若寄存器 x[rs1]和寄存器 x[rs2]的值不相等，把 pc 的值设为当前值加上符号位扩展的偏移imm。
```

```c
`BLT`(小于时分支跳转 (Branch if Less Than))
- blt rs1, rs2, imm
- if (rs1 <s rs2) pc += imm
- 若寄存器 x[rs1]的值小于寄存器 x[rs2]的值（均视为二进制补码），把 pc 的值设为当前值加上符号位扩展的偏移 imm
```

```c
`BGE`(大于等于时分支跳转(Branch if Greater Than or Equal))
- bge rs1, rs2, imm
- if (rs1 ≥s rs2) pc += imm
- 若寄存器 x[rs1]的值大于等于寄存器 x[rs2]的值（均视为二进制补码），把 pc 的值设为当前值加上符号位扩展的偏移imm。
```

```c
`BLTU`(无符号小于时分支跳转 (Branch if Less Than, Unsigned))
- bltu rs1, rs2, imm
- if (rs1 <u rs2) pc += imm
- 若寄存器 x[rs1]的值小于寄存器 x[rs2]的值（均视为无符号数），把 pc 的值设为当前值加上符号位扩展的偏移 imm。
```

```c
`BGEU`(无符号大于等于时分支跳转 (Branch if Greater Than or Equal, Unsigned))
- bgeu rs1, rs2, imm
- if (rs1 ≥u rs2) pc += imm
- 若寄存器 x[rs1]的值大于等于寄存器 x[rs2]的值（均视为无符号数），把 pc 的值设为当前值加上符号位扩展的偏移 imm。
```





### B型指令数据通路图

### verilog代码实现

### 编译仿真结果



## 2.5 访存指令的实现(sotore = S型，load=I型)

### 访存指令介绍

![](attachment/inst.png)

![image-20230315162344305](attachment/s_inst.png)

![image-20230315162327221](attachment/s_inst_opcode.png)

访存指令store(S型)通常包括,load属于I型

- opcode（操作码，7）

- funct3（功能码，3）

- rs1（源寄存器1，5）

- rs2（源寄存器1，5）

- Imm（立即数，13）

  其中opcode用于判断指令的类型，func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rs2也是需要访问通用寄存器的地址，将取到的值用于运算操作；;IMM立即数是进行运算操作的数，这里直接给出，可以直接扩展后使用，不需要访问寄存器取值。

  

通过上图我们可以看到访存指令有8种类型。下面我会一一解释。offset=imm

```c
`LB`(字节加载 (Load Byte))
- lb rd, offset(rs1)
- x[rd] = sext(M[x[rs1] + sext(offset)][7:0])
- 从地址 x[rs1] + sign-extend(offset)读取一个字节，经符号位扩展后写入x[rd]。
```

```c
`LH`(半字加载 (Load Halfword))
- lh rd, offset(rs1)
- x[rd] = sext(M[x[rs1] + sext(offset)][15:0])
- 从地址 x[rs1] + sign-extend(offset)读取两个字节，经符号位扩展后写入 x[rd]。
```

```c
`LW`(字加载 (Load Word))
- lw rd, offset(rs1)
- x[rd] = sext(M[x[rs1] + sext(offset)][31:0])
- 从地址 x[rs1] + sign-extend(offset)读取四个字节，写入 x[rd]。
```

```c
`LBU`(无符号字节加载 (Load Byte, Unsigned))
- lbu rd, offset(rs1)
- x[rd] = M[x[rs1] + sext(offset)][7:0]
- 从地址 x[rs1] + sign-extend(offset)读取一个字节，经零扩展后写入 x[rd]。
```

```c
`LHU`(无符号半字加载 (Load Halfword, Unsigned))
- lhu rd, offset(rs1)
- x[rd] = M[x[rs1] + sext(offset)][15:0]
- 从地址 x[rs1] + sign-extend(offset)读取两个字节，经零扩展后写入 x[rd]。
```

```c
`SB`(存字节(Store Byte))
- sb rs2, offset(rs1) 
- M[x[rs1] + sext(offset)] = x[rs2][7: 0]
- 将 x[rs2]的低位字节存入内存地址 x[rs1]+sign-extend(offset)。
```

```c
`SH`(存半字(Store Halfword))
- sh rs2, offset(rs1)
- M[x[rs1] + sext(offset) = x[rs2][15: 0]
- 将 x[rs2]的低位 2 个字节存入内存地址 x[rs1]+sign-extend(offset)。
```

```c
`SW`(存字(Store Word))
- sw rs2, offset(rs1)
- M[x[rs1] + sext(offset) = x[rs2][31: 0]
- 将 x[rs2]的低位 4 个字节存入内存地址 x[rs1]+sign-extend(offset)。
```



### 访存指令数据通路图

### verilog代码实现

### 编译仿真结果



# 3 搭建数据通路（RV32M Standard Extension，8条）

### M拓展指令介绍

![](attachment/inst.png)

![image-20230315161637824](attachment/rv32m_e.png)

- M拓展指令通常包括
  - opcode（操作码，7）
  - funct3（功能码，3）
  - rs1（源寄存器1，5）
  - rs2（源寄存器1，5）
  - rd（目标寄存器，5）
  - funct7（功能码，7）
    其中opcode用于判断指令的类型与R型指令相同（0110011）；funct7用于进一步分辨是R型还是M拓展指令，func3用于判断具体指令需要进行的操作；rs1是需要访问通用寄存器的地址，将取到的值用于运算操作；rs2也是需要访问通用寄存器的地址，将取到的值用于运算操作；rd是将运算结果写回的目的寄存器地址。

通过上图我们可以看到M拓展指令有8种类型。下面我会一一解释。

```c
`MUL`（乘(Multiply)）
- mul rd, rs1, rs2
- x[rd] = x[rs1] × x[rs2]
- 把寄存器 x[rs2]乘到寄存器 x[rs1]上，乘积写入 x[rd]。忽略算术溢出。
```

```
`MULH`（高位乘(Multiply High)）
- mulh rd, rs1, rs2
- x[rd] = (x[rs1] s ×s x[rs2]) ≫s XLEN
- 把寄存器 x[rs2]乘到寄存器 x[rs1]上，都视为 2 的补码，将乘积的高位写入 x[rd]。
```

```
`MULHU`（高位无符号乘(Multiply High Unsigned)）
- mulhu rd, rs1, rs2
- x[rd] = (x[rs1]u ×u x[rs2]) ≫u XLEN
- 把寄存器 x[rs2]乘到寄存器 x[rs1]上， x[rs1]、 x[rs2]均为无符号数，将乘积的高位写入 x[rd]。
```

```
`MULHSU`（高位有符号-无符号乘(Multiply High Signed-Unsigned)）
- mulhsu rd, rs1, rs2
- x[rd] = (x[rs1]u ×s x[rs2]) ≫s XLEN
- 把寄存器 x[rs2]乘到寄存器 x[rs1]上， x[rs1]为 2 的补码， x[rs2]为无符号数，将乘积的高位写入 x[rd]
```

```
`DIV`（除法(Divide)）
- div rd, rs1, rs2 
- x[rd] = x[rs1] ÷s x[rs2]
- 用寄存器 x[rs1]的值除以寄存器 x[rs2]的值，向零舍入，将这些数视为二进制补码，把商写入 x[rd]。
```

```
`DIVU`（无符号除法(Divide, Unsigned)）
- divu rd, rs1, rs2
- x[rd] = x[rs1] ÷u x[rs2]
- 用寄存器 x[rs1]的值除以寄存器 x[rs2]的值，向零舍入，将这些数视为无符号数，把商写入x[rd]。
```

```
`REM`(求余数(Remainder))
- rem rd, rs1, rs2
- x[rd] = x[rs1] %s x[rs2]
- x[rs1]除以 x[rs2]，向 0 舍入，都视为 2 的补码，余数写入 x[rd]。
```

```
`REMU`(求无符号数的余数(Remainder, Unsigned))
- remu rd, rs1, rs2
- x[rd] = x[rs1] %u x[rs2]
- x[rs1]除以 x[rs2]，向 0 舍入，都视为无符号数，余数写入 x[rd]。
```

### 指令数据通路图



### verilog代码实现



### 编译仿真结果
