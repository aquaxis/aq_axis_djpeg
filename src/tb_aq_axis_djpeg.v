/*
 * Copyright (C)2006-2015 AQUAXIS TECHNOLOGY.
 *  Don't remove this header.
 * When you use this source, there is a need to inherit this header.
 *
 * License
 *  For no commercial -
 *   License:     The Open Software License 3.0
 *   License URI: http://www.opensource.org/licenses/OSL-3.0
 *
 *  For commmercial -
 *   License:     AQUAXIS License 1.0
 *   License URI: http://www.aquaxis.com/licenses
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
`timescale 1ps / 1ps

module tb_aq_axis_djpeg;
  // Reset&Clock
  reg RST_N;
  reg CLK;

  // Write Address Channel
  wire [31:0] S_AXI_AWADDR;
  wire [3:0]  S_AXI_AWCACHE;
  wire [2:0]  S_AXI_AWPROT;
  wire        S_AXI_AWVALID;
  wire        S_AXI_AWREADY;

  // Write Data Channel
  wire [31:0] S_AXI_WDATA;
  wire [3:0]  S_AXI_WSTRB;
  wire        S_AXI_WVALID;
  wire        S_AXI_WREADY;

  // Write Response Channel
  wire        S_AXI_BVALID;
  wire        S_AXI_BREADY;
  wire [1:0]  S_AXI_BRESP;

  // Read Address Channel
  wire [31:0] S_AXI_ARADDR;
  wire [3:0]  S_AXI_ARCACHE;
  wire [2:0]  S_AXI_ARPROT;
  wire        S_AXI_ARVALID;
  wire        S_AXI_ARREADY;

  // Read Data Channel
  wire [31:0] S_AXI_RDATA;
  wire [1:0]  S_AXI_RRESP;
  wire        S_AXI_RVALID;
  wire        S_AXI_RREADY;

  // AXI Stream wire
  wire        S_AXIS_TCLK;
  wire [31:0] S_AXIS_TDATA;
  wire        S_AXIS_TKEEP;
  wire        S_AXIS_TLAST;
  wire        S_AXIS_TREADY;
  wire [3:0]  S_AXIS_TSTRB;
  reg         S_AXIS_TVALID;

  // AXI Stream wire
  wire        M_AXIS_TCLK;
  wire [31:0] M_AXIS_TDATA;
  wire        M_AXIS_TKEEP;
  wire        M_AXIS_TLAST;
  reg         M_AXIS_TREADY;
  wire [3:0]  M_AXIS_TSTRB;
  wire        M_AXIS_TVALID;

  parameter TIME10N = 10;

  always begin
    #(TIME10N/2) CLK = ~CLK;
  end

  assign S_AXIS_TCLK = CLK;

  initial begin
    // Initialize Inputs
    RST_N = 0;
    CLK   = 0;

    M_AXIS_TREADY = 1;
	S_AXIS_TVALID = 0;
    #100;
    RST_N = 1;
  end

	reg [31:0] JPEG_MEM [0:1*1024*1024-1];

	integer	DATA_COUNT;

	parameter clkP = 10000; // 100MHz
	parameter clkH = clkP /2;
	parameter clkL = clkP - clkH;

	integer	 count;
	reg [23:0]	rgb_mem [0:1920*1080-1];

	initial begin
		count = 0;
		while(1) begin
		 @(posedge CLK);
		 count = count +1;
		end
	end

	aq_axis_djpeg u_axis_aq_djpeg
	 (
    // AXI4 Lite Interface
    .ARESETN        ( RST_N         ),
    .ACLK           ( CLK           ),

    // Write Address Channel
    .S_AXI_AWADDR   ( S_AXI_AWADDR  ),
    .S_AXI_AWCACHE  ( S_AXI_AWCACHE ),
    .S_AXI_AWPROT   ( S_AXI_AWPROT  ),
    .S_AXI_AWVALID  ( S_AXI_AWVALID ),
    .S_AXI_AWREADY  ( S_AXI_AWREADY ),

    // Write Data Channel
    .S_AXI_WDATA    ( S_AXI_WDATA   ),
    .S_AXI_WSTRB    ( S_AXI_WSTRB   ),
    .S_AXI_WVALID   ( S_AXI_WVALID  ),
    .S_AXI_WREADY   ( S_AXI_WREADY  ),

    // Write Response Channel
    .S_AXI_BVALID   ( S_AXI_BVALID  ),
    .S_AXI_BREADY   ( S_AXI_BREADY  ),
    .S_AXI_BRESP    ( S_AXI_BRESP   ),

    // Read Address Channel
    .S_AXI_ARADDR   ( S_AXI_ARADDR  ),
    .S_AXI_ARCACHE  ( S_AXI_ARCACHE ),
    .S_AXI_ARPROT   ( S_AXI_ARPROT  ),
    .S_AXI_ARVALID  ( S_AXI_ARVALID ),
    .S_AXI_ARREADY  ( S_AXI_ARREADY ),

    // Read Data Channel
    .S_AXI_RDATA    ( S_AXI_RDATA   ),
    .S_AXI_RRESP    ( S_AXI_RRESP   ),
    .S_AXI_RVALID   ( S_AXI_RVALID  ),
    .S_AXI_RREADY   ( S_AXI_RREADY  ),

    // AXI Stream input
    .S_AXIS_TCLK    ( S_AXIS_TCLK   ),
    .S_AXIS_TDATA   ( S_AXIS_TDATA  ),
    .S_AXIS_TKEEP   ( S_AXIS_TKEEP  ),
    .S_AXIS_TLAST   ( S_AXIS_TLAST  ),
    .S_AXIS_TREADY  ( S_AXIS_TREADY ),
    .S_AXIS_TSTRB   ( S_AXIS_TSTRB  ),
    .S_AXIS_TVALID  ( S_AXIS_TVALID ),

    // AXI Stream output
    .M_AXIS_TCLK    ( M_AXIS_TCLK   ),
    .M_AXIS_TDATA   ( M_AXIS_TDATA  ),
    .M_AXIS_TKEEP   ( M_AXIS_TKEEP  ),
    .M_AXIS_TLAST   ( M_AXIS_TLAST  ),
    .M_AXIS_TREADY  ( M_AXIS_TREADY ),
    .M_AXIS_TSTRB   ( M_AXIS_TSTRB  ),
    .M_AXIS_TVALID  ( M_AXIS_TVALID )
		);

  task_axilm u_task_axilm(
    // AXI4 Lite Interface
    .ARESETN      ( RST_N         ),
    .ACLK         ( CLK           ),

    // Write Address Channel
    .AXI_AWADDR   ( S_AXI_AWADDR  ),
    .AXI_AWCACHE  ( S_AXI_AWCACHE ),
    .AXI_AWPROT   ( S_AXI_AWPROT  ),
    .AXI_AWVALID  ( S_AXI_AWVALID ),
    .AXI_AWREADY  ( S_AXI_AWREADY ),

    // Write Data Channel
    .AXI_WDATA    ( S_AXI_WDATA   ),
    .AXI_WSTRB    ( S_AXI_WSTRB   ),
    .AXI_WVALID   ( S_AXI_WVALID  ),
    .AXI_WREADY   ( S_AXI_WREADY  ),

    // Write Response Channel
    .AXI_BVALID   ( S_AXI_BVALID  ),
    .AXI_BREADY   ( S_AXI_BREADY  ),
    .AXI_BRESP    ( S_AXI_BRESP   ),

    // Read Address Channel
    .AXI_ARADDR   ( S_AXI_ARADDR  ),
    .AXI_ARCACHE  ( S_AXI_ARCACHE ),
    .AXI_ARPROT   ( S_AXI_ARPROT  ),
    .AXI_ARVALID  ( S_AXI_ARVALID ),
    .AXI_ARREADY  ( S_AXI_ARREADY ),

    // Read Data Channel
    .AXI_RDATA    ( S_AXI_RDATA   ),
    .AXI_RRESP    ( S_AXI_RRESP   ),
    .AXI_RVALID   ( S_AXI_RVALID  ),
    .AXI_RREADY   ( S_AXI_RREADY  )
  );

	// Read JPEG File
	initial begin
		$readmemh("/home/hidemi/workspace/IPCORE/aq_axis_djpeg/src/test.mem",JPEG_MEM);
	end

	// Initial
	initial begin
		wait (RST_N);
		@(posedge CLK);
		$display(" Start Clock: %d",count);
	    u_task_axilm.write(32'h0000_0000, 32'h8000_0000);
	    u_task_axilm.write(32'h0000_0000, 32'h0000_0000);

		@(posedge CLK);
		@(posedge CLK);
		forever begin
		 if(S_AXIS_TREADY == 1'b1) begin
		 	S_AXIS_TVALID <= 1'b1;
		 end else begin
		 	S_AXIS_TVALID <= 1'b0;
		 end
		 @(posedge CLK);
		end
	end

	initial begin
		# 0;
		DATA_COUNT	<= 0;
		forever begin
			if(S_AXIS_TREADY & S_AXIS_TVALID) begin
				DATA_COUNT	<= DATA_COUNT +1;
			end
			 @(posedge CLK);
		end
	end
	assign S_AXIS_TDATA = JPEG_MEM[DATA_COUNT];


	integer i;

	initial begin
		@(posedge u_axis_aq_djpeg.u_aq_djpeg.ImageEnable);

		$display("------------------------------");
		$display("Image Run");
		$display("------------------------------");
		$display(" X: %4d",i,u_axis_aq_djpeg.u_aq_djpeg.OutWidth);
		$display(" Y: %4d",i,u_axis_aq_djpeg.u_aq_djpeg.OutHeight);
		$display(" Component: %4d",i,u_axis_aq_djpeg.u_aq_djpeg.JpegComp);
		$display(" BlockWidth: %4d",i,u_axis_aq_djpeg.u_aq_djpeg.JpegBlockWidth);
		$display("------------------------------");
		$display(" DQT Y Table");
		for(i=0;i<64;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dqt.DQT_Y[i]);
		end

		$display("------------------------------");
		$display(" DQT Cb/Cr Table");
		for(i=0;i<64;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dqt.DQT_C[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman Y-DC Code/Number");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x,%2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanTable0r[i],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanNumber0r[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman Y-DC Table");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dht.DHT_Ydc[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman Y-AC Code/Number");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x,%2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanTable1r[i],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanNumber1r[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman Y-AC Table");
		for(i=0;i<162;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dht.DHT_Yac[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman C-DC Table");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x,%2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanTable2r[i],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanNumber2r[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman C-DC Table");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dht.DHT_Cdc[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman C-AC Table");
		for(i=0;i<16;i=i+1) begin
		 $display(" %2d: %2x,%2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanTable3r[i],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanNumber3r[i]);
		end
		$display("------------------------------");

		$display("------------------------------");
		$display(" huffman C-AC Table");
		for(i=0;i<162;i=i+1) begin
		 $display(" %2d: %2x",i,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_dht.DHT_Cac[i]);
		end
		$display("------------------------------");
	end
/*
	integer Phase8Count;
	initial begin
		Phase8Count <= 0;
		while(1) begin
		 @(posedge CLK);
		 if((u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'h8) && !(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessCount < 63)) begin
			Phase8Count <= Phase8Count + 1;
			$display(" Process Phase8: %d", Phase8Count);
		end
		end
	end
*/
	integer DataOutEnable;
	initial begin
		DataOutEnable <= 0;
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.DataOutEnable == 1'b1) begin
			DataOutEnable <= DataOutEnable + 1;
			$display(" DataOutEnable: %d", DataOutEnable);
		end
		end
	end

	integer ConvertEnable;
	initial begin
		ConvertEnable <= 0;
		while(1) begin
		 @(posedge CLK);
		 if((u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_ycbcr.ConvertRead == 1'b1 == 1'b1) && (u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_ycbcr.ConvertAddress == 8'd255)) begin
			ConvertEnable <= ConvertEnable + 1;
			$display(" ConvertEnable: %d", ConvertEnable);
		end
		end
	end


/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'h2)
			$display(" Color: %d,%d",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessColor,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessCount);
		end
	end

	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'h4)
			for(i=0;i<16;i=i+1) begin
				$display(" Data Code: %8x,%8x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanTable[i],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.HuffmanNumber[i]);
			end
		end
	end
*/

/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'h6)
			$display(" Wait for RAM");
		end
	end
*/
/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'h4)
			$display(" Data Code: %8x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessData);
		end
	end
*/
/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.Process == 4'hB)
			$display(" Data Code: %d,%d,%4x,%4x,%4x,%4x,%2x,%4x,%4x,%4x,%8x",
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.CodeNumber,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessCount,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.DhtNumber,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.DhtZero,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.DataNumber,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.TableCode,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.NumberCode,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.DqtData,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.OutCode,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.OutData,
					u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_hm_decode.ProcessData);
		end
	end



	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.HmDecEnable == 1'b1)
				$display(" HmDec Code: %d,%4x",
						u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.HmDecCount,
						u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.HmDecData);
		end
	end
*/

/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.HmOutEnable == 1'b1)
			for(i=0;i<64;i=i+1) begin
				$display(" Data Code: %d,%4x",i,
						u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_huffman.u_jpeg_ziguzagu.RegData[i]);
			end
		end
	end
*/

/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4Enable.O == 1'b1)
		 //if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4Enable == 1'b1)
			$display(" Dct Data[X]: %d:%d,%016x,%016x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4Page,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4Count,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4R0r,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idctx.Phase4R1r);
		end
	end
*/
/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.DctXEnable == 1'b1)
			$display(" Dct Data[X]: %d:%d,%4x,%4x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.DctXPage,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.DctXCount,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.DctXData0r,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.DctXData1r);
		end
	end
*/

/*
	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Enable == 1'b1)
			$display(" Dct Data[Y2]: %d,%8x,%8x,%8x,%8x,%8x,%8x,%8x,%8x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Count,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[0],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[1],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[2],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[3],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[4],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[5],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[6],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase2Reg[7]);
		end
	end

	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase5Enable == 1'b1)
			$display(" Dct Data[Y5]: %d,%8x,%8x,%8x,%8x,%8x,%8x,%8x,%8x,%8x,%8x",u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase5Count,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase5R0w,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase5R1w,u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[0],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[1],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[2],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[3],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[4],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[5],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[6],u_axis_aq_djpeg.u_aq_djpeg.u_jpeg_idct.u_jpeg_idcty.Phase3Reg[7]);
		end
	end



	initial begin
		while(1) begin
		 @(posedge CLK);
		 if(u_axis_aq_djpeg.u_aq_djpeg.DctEnable == 1'b1)
			$display(" Dct Data[Y]: %d,%4x,%4x",u_axis_aq_djpeg.u_aq_djpeg.DctCount,u_axis_aq_djpeg.u_aq_djpeg.Dct0Data,u_axis_aq_djpeg.u_aq_djpeg.Dct1Data);
		end
	end
*/

	integer address;
	integer fp;

	// ??????????????????????????????
	initial begin
		while(1) begin
		 if(u_axis_aq_djpeg.u_aq_djpeg.OutEnable == 1'b1) begin
			address = u_axis_aq_djpeg.u_aq_djpeg.OutWidth * u_axis_aq_djpeg.u_aq_djpeg.OutPixelY + u_axis_aq_djpeg.u_aq_djpeg.OutPixelX;
			$display(" RGB[%4d,%4d][%4d,%4d]: %2x,%2x,%2x",
			u_axis_aq_djpeg.u_aq_djpeg.OutPixelX,
			u_axis_aq_djpeg.u_aq_djpeg.OutPixelY,
			u_axis_aq_djpeg.u_aq_djpeg.OutWidth,
			u_axis_aq_djpeg.u_aq_djpeg.OutHeight,
			u_axis_aq_djpeg.u_aq_djpeg.OutR,
			u_axis_aq_djpeg.u_aq_djpeg.OutG,
			u_axis_aq_djpeg.u_aq_djpeg.OutB);
			rgb_mem[address] = {u_axis_aq_djpeg.u_aq_djpeg.OutR,u_axis_aq_djpeg.u_aq_djpeg.OutG,u_axis_aq_djpeg.u_aq_djpeg.OutB};
		 end
		 @(posedge CLK);
		end
	end


	initial begin
		wait(M_AXIS_TLAST);

		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);
		@(posedge CLK);

		$display(" End Clock %d",count);
		fp = $fopen("sim.dat");
		$fwrite(fp,"%0d\n",u_axis_aq_djpeg.u_aq_djpeg.OutWidth);
		$fwrite(fp,"%0d\n",u_axis_aq_djpeg.u_aq_djpeg.OutHeight);

		for(i=0;i<u_axis_aq_djpeg.u_aq_djpeg.OutWidth*u_axis_aq_djpeg.u_aq_djpeg.OutHeight;i=i+1) begin
		 $fwrite(fp,"%06x\n",rgb_mem[i]);
		end
		$fclose(fp);

//		$coverage_save("sim.cov");
		$finish();
		//$stop();
	end

endmodule
