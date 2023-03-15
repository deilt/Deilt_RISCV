
call {$fsdbDumpfile("riscv_core.fsdb")}
call {$fsdbDumpvars(0,core_tb,"+all")}
run
