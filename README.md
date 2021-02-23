# Decode JPEG

* Decode JPEG file
* Base Line
* 4:1:1 only
* Verilog HDL
* AXI Stream Interface

## License

MIT License

## Simulation

```
$ hexdump -v -e '1/4 "%08x" "\n"' sample.jpg > sample.hex
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
