SHELL=/bin/bash
SETTING=source /opt/Xilinx/Vivado/2020.2/settings64.sh

.PHONY: all

all:
	$(SETTING); vivado -mode batch -source create_ip.tcl

clean:
	rm -rf aq_axis_djpeg *.log
