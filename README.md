# 前言
本人目前是一个小小的硕士研究生，正在学习数字IC前端设计相关知识。创建此项目的目的是为了学习RISC-V，希望可以通过此项目的学习加深对数字IC设计的理解。由于本人是非专业人士，代码等方面可能会有错误的地方，望大家能够谅解。


## 相关资料参考
> 《计算机组成与设计——硬件软件接口(risc-v)》
> 《Computer Organization and Design RISC-V edition》
> 《手把手教你设计CPU-RISC-V处理器篇》
> 《RISC-V架构与嵌入式开发快速入门》
> 《The RISC-V Instruction Set Manual Volume I: Unprivileged ISA》
> 《RISC-V 指令集手册 卷1：用户级指令集体系结构（User-Level ISA） 2.1 版》
> 《The RISC-V Instruction Set Manual Volume II: Privileged Architecture》
> 《RISC-V 指令集手册 卷2：特权体系结构（Privileged Architecture） 特权体系结构 1.7 版》
> 《The RISC-V Reader中文版》
> 《riscv-debug-spec-stable_0.13》
> 《riscv-debug-release_0.13.2》


# Deilt_RISC介绍
## 目的
本项目拟设计一个五级流水的单核32位处理器（Deilt_RISC），采用Verilog编写。其具有以下特点：
- 五级流水
- 支持RV32IM指令集 
- 支持中断
- 支持AMBA总线
- 支持UART、GPIO、SPI、Timer
- ROM
- RAM
- JTAG
- 后续跟新

## 整体框架图

### CORE
### peripherals
