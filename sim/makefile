OBJECT = riscv_core
TESTBENCH = core_tb


all: vcs sim verdi

# compiling, corresponding to run_vcs.sh
vcs:
	vcs -full64 -notice -debug_acc+all -debug_region+cell+encrypt -j8 -timescale=1ns/1ps \
	+plusarg_save +libext+.v+.V+.sv+.svh -sverilog +memcbk \
	-P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab \
	${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a \
	-cpp /usr/bin/g++ -cc /usr/bin/gcc \
	-f file.list -f macro.list -top ${TESTBENCH} \
	-l compile.log
# simulation, corresponding to run_simv.sh
sim:
	./simv -ucli -i wave_gen.tcl -l sim.log
# start verdi, corresponding to run_verdi.sh
verdi:
	verdi -f file.list -f macro.list \
	-top ${TESTBENCH} -ssf ${OBJECT}.fsdb -nologo &

# delete useless files
clean:
	rm -rf simv* *.log *.fsdb novas* *.key csrc verdiLog
