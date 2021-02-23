# Decode JPEG

* Decode JPEG file
* Base Line
* 4:1:1 only
* Verilog HDL
* AXI Stream Interface

## License

MIT License

If you like this, you can supponsor for me.
If possible as a sponsor, display the sponsor name. 

https://github.com/sponsors/aquaxis

## Quick Simulation

REQUIRE: Install the vivado 2020.2 for `/opt/Xilinx/Vivado/2020.2`.

```
$ make sim
```

When finished the simulation, then create directory with name is `simulation`.
Quikc simulation is decoding to `simlation/output.bmp` from  `model/sample.jpg`.
Compare `simlation/output.bmp` and `model/sample.jpg`.

## Simulation

1. Create a HEX file
2. Simulation
3. Convert bitmap from output log

### Create a HEX file from JPEG file

ex, Convert to sample.hex from sample.jpg.

```
$ hexdump -v -e '1/4 "%08x" "\n"' sample.jpg > sample.hex
```

If you change path of a hex file, then the FILENAME define change in testbench/tb_aq_axis_djpeg.v.

FILE: testbench/tb_aq_axis_djpeg.v

```
`define FILENAME "../model/sample.hex"
```

### Simulation

Let's go simulation.

### Convert bitmap from output log

```
$ raw_hex2bmp sim.dat output.bmp
```

## Model

```
$ cd model
$ gcc -o djpeg djpeg.c
$ ./djpeg sample.jpg sample.bmp
```

## Create JPEG file

```
$ cd model
$ gcc -o cjpeg cjpeg.c
$ ./cjpeg sample.bmp sample.jpg
```
