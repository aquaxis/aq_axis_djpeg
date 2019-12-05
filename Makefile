SHELL=/bin/bash
SETTING=source /opt/Xilinx/Vivado/2019.2/settings64.sh

.PHONY: all

all:
	$(SETTING); vivado -mode batch -source create_ip.tcl
