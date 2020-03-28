/*
 * Copyright (C)2014-2015 AQUAXIS TECHNOLOGY.
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

module aq_axis_djpeg
(
  // --------------------------------------------------
  // AXI4 Lite Interface
  // --------------------------------------------------
  input         ARESETN,
  input         ACLK,

  // Write Address Channel
  input [31:0]  S_AXI_AWADDR,
  input [3:0]   S_AXI_AWCACHE,
  input [2:0]   S_AXI_AWPROT,
  input         S_AXI_AWVALID,
  output        S_AXI_AWREADY,

  // Write Data Channel
  input [31:0]  S_AXI_WDATA,
  input [3:0]   S_AXI_WSTRB,
  input         S_AXI_WVALID,
  output        S_AXI_WREADY,

  // Write Response Channel
  output        S_AXI_BVALID,
  input         S_AXI_BREADY,
  output [1:0]  S_AXI_BRESP,

  // Read Address Channel
  input [31:0]  S_AXI_ARADDR,
  input [3:0]   S_AXI_ARCACHE,
  input [2:0]   S_AXI_ARPROT,
  input         S_AXI_ARVALID,
  output        S_AXI_ARREADY,

  // Read Data Channel
  output [31:0] S_AXI_RDATA,
  output [1:0]  S_AXI_RRESP,
  output        S_AXI_RVALID,
  input         S_AXI_RREADY,

  // AXI Stream input
  input         TCLK,
  input [31:0]  S_AXIS_TDATA,
  input         S_AXIS_TKEEP,
  input         S_AXIS_TLAST,
  output        S_AXIS_TREADY,
  input [3:0]   S_AXIS_TSTRB,
  input         S_AXIS_TVALID,

  // AXI Stream output
  output [31:0] M_AXIS_TDATA,
  output        M_AXIS_TKEEP,
  output        M_AXIS_TLAST,
  input         M_AXIS_TREADY,
  output [3:0]  M_AXIS_TSTRB,
  output        M_AXIS_TVALID
);

wire JpegDecodeRst, JpegDecodeIdle, JpegProgressive;
wire [15:0] OutWidth, OutHeight, OutPixelX, OutPixelY;
wire [7:0] OutR, OutG, OutB;

  aq_axis_djpeg_ctrl u_aq_axis_djpeg_ctrl
  (
    .ARESETN        ( ARESETN         ),
    .ACLK           ( ACLK            ),

    .S_AXI_AWADDR   ( S_AXI_AWADDR    ),
    .S_AXI_AWCACHE  ( S_AXI_AWCACHE   ),
    .S_AXI_AWPROT   ( S_AXI_AWPROT    ),
    .S_AXI_AWVALID  ( S_AXI_AWVALID   ),
    .S_AXI_AWREADY  ( S_AXI_AWREADY   ),

    .S_AXI_WDATA    ( S_AXI_WDATA     ),
    .S_AXI_WSTRB    ( S_AXI_WSTRB     ),
    .S_AXI_WVALID   ( S_AXI_WVALID    ),
    .S_AXI_WREADY   ( S_AXI_WREADY    ),

    .S_AXI_BVALID   ( S_AXI_BVALID    ),
    .S_AXI_BREADY   ( S_AXI_BREADY    ),
    .S_AXI_BRESP    ( S_AXI_BRESP     ),

    .S_AXI_ARADDR   ( S_AXI_ARADDR    ),
    .S_AXI_ARCACHE  ( S_AXI_ARCACHE   ),
    .S_AXI_ARPROT   ( S_AXI_ARPROT    ),
    .S_AXI_ARVALID  ( S_AXI_ARVALID   ),
    .S_AXI_ARREADY  ( S_AXI_ARREADY   ),

    .S_AXI_RDATA    ( S_AXI_RDATA     ),
    .S_AXI_RRESP    ( S_AXI_RRESP     ),
    .S_AXI_RVALID   ( S_AXI_RVALID    ),
    .S_AXI_RREADY   ( S_AXI_RREADY    ),

    .LOGIC_RST      ( JpegDecodeRst   ),
    .LOGIC_IDLE     ( JpegDecodeIdle  ),
    .LOGIC_PROGRESSIVE(JpegProgressive),

    .WIDTH          ( OutWidth[15:0]  ),
    .HEIGHT         ( OutHeight[15:0] ),
    .PIXELX         ( OutPixelX[15:0] ),
    .PIXELY         ( OutPixelY[15:0] )
  );

aq_djpeg u_aq_djpeg(
  .rst            ( ~JpegDecodeRst  ),
  .clk            ( TCLK     ),

  // From FIFO
  .DataIn         ( S_AXIS_TDATA[31:0]  ),
  .DataInEnable   ( S_AXIS_TVALID   ),
  .DataInRead     (),
  .DataInReq      ( S_AXIS_TREADY   ),

  .JpegDecodeIdle ( JpegDecodeIdle  ),
  .JpegProgressive( JpegProgressive  ),

  .OutEnable      ( M_AXIS_TVALID   ),
  .OutWidth       ( OutWidth[15:0]  ),
  .OutHeight      ( OutHeight[15:0] ),
  .OutPixelX      ( OutPixelX[15:0] ),
  .OutPixelY      ( OutPixelY[15:0] ),
  .OutR           ( OutR[7:0]       ),
  .OutG           ( OutG[7:0]       ),
  .OutB           ( OutB[7:0]       )
);

assign M_AXIS_TKEEP = 1'b0;
assign M_AXIS_TLAST = (OutPixelX == (OutWidth - 1)) && (OutPixelY == (OutHeight - 1));
assign M_AXIS_TSTRB = 4'b1111;
assign M_AXIS_TDATA[31:0] = {8'd0, OutR[7:0], OutG[7:0], OutB[7:0]};
//assign M_AXIS_TDATA[31:0] = {OutPixelY[15:0], OutPixelX[15:0]};

endmodule
