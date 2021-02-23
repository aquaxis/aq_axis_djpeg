SHELL=/bin/bash
SETTING=source /opt/Xilinx/Vivado/2020.2/settings64.sh

.PHONY: all

all:
	$(SETTING); vivado -mode batch -source ./scripts/create_ip.tcl

bin2hex:
	cd model; hexdump -v -e '1/4 "%08x" "\n"' sample.jpg > sample.hex

raw_hex2bmp:	./model/raw_hex2bmp.c
	gcc -o ./model/raw_hex2bmp ./model/raw_hex2bmp.c

sim:
	make bin2hex
	make raw_hex2bmp
	mkdir -p simulation
	$(SETTING); cd simulation; xvlog --incr --relax -prj ../scripts/simulation.prj 2>&1 | tee compile.log
	$(SETTING); cd simulation; xelab --incr --debug typical --relax --mt 8 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot tb_aq_axis_djpeg_behav xil_defaultlib.tb_aq_axis_djpeg xil_defaultlib.glbl -log elaborate.log
	$(SETTING); cd simulation; xsim tb_aq_axis_djpeg_behav -key {Behavioral:sim_1:Functional:tb_aq_axis_djpeg} -tclbatch ../scripts/simulation.tcl -log simulate.log
	cd simulation; ../model/raw_hex2bmp sim.dat output.bmp

clean:
	rm -rf aq_axis_djpeg *.log
