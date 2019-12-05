/*
 * AXI4 Lite Slave
 *
 * Copyright (C)2014-2019 AQUAXIS TECHNOLOGY.
 *  Don't remove this header.
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
module aq_axis_djpeg_ctrl
(
  // AXI4 Lite Interface
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

  // Local Interface
  output        LOGIC_RST,
  input         LOGIC_IDLE,

  input [15:0]  WIDTH,
  input [15:0]  HEIGHT,
  input [15:0]  PIXELX,
  input [15:0]  PIXELY,

  output [31:0] DEBUG
);

/*
  CACHE[3:0]
    WA RA C  B
    0  0  0  0 Noncacheable and nonbufferable
    0  0  0  1 Bufferable only
    0  0  1  0 Cacheable, but do not allocate
   *0  0  1  1 Cacheable and Bufferable, but do not allocate
    0  1  1  0 Cacheable write-through, allocate on reads only
    0  1  1  1 Cacheable write-back, allocate on reads only
    1  0  1  0 Cacheable write-through, allocate on write only
    1  0  1  1 Cacheable write-back, allocate on writes only
    1  1  1  0 Cacheable write-through, allocate on both reads and writes
    1  1  1  1 Cacheable write-back, allocate on both reads and writes

  PROR[2:0]
    [2]:0:Data Access(*)
        1:Instruction Access
    [1]:0:Secure Access(*)
        1:NoSecure Access
    [0]:0:Privileged Access(*)
        1:Normal Access

  RESP[1:0]
    00: OK
    01: EXOK
    10: SLVERR
    11: DECERR
*/

  localparam S_IDLE   = 2'd0;
  localparam S_WRITE  = 2'd1;
  localparam S_WRITE2 = 2'd2;
  localparam S_READ   = 2'd3;

  reg [1:0]     state;
  reg           reg_rnw;
  reg [31:0]    reg_addr, reg_wdata;
  reg [3:0]     reg_be;
  reg           reg_wallready;

  wire          local_cs, local_rnw, local_ack;
  wire [3:0]    local_be;
  wire [31:0]   local_addr, local_wdata, local_rdata;

  always @( posedge ACLK or negedge ARESETN ) begin
    if( !ARESETN ) begin
      state         <= S_IDLE;
      reg_rnw       <= 1'b0;
      reg_addr      <= 32'd0;
      reg_wdata     <= 32'd0;
      reg_be        <= 4'd0;
      reg_wallready <= 1'b0;
    end else begin
      // Receive wdata
      if( S_AXI_WVALID ) begin
        reg_wdata     <= S_AXI_WDATA;
        reg_be        <= S_AXI_WSTRB;
        reg_wallready <= 1'b1;
      end else if( local_ack & S_AXI_BREADY ) begin
        reg_wallready <= 1'b0;
      end

      // Address state
      case( state )
        S_IDLE: begin
          if( S_AXI_AWVALID ) begin
            reg_rnw   <= 1'b0;
            reg_addr  <= S_AXI_AWADDR;
            state     <= S_WRITE;
          end else if( S_AXI_ARVALID ) begin
            reg_rnw   <= 1'b1;
            reg_addr  <= S_AXI_ARADDR;
            state     <= S_READ;
          end
        end
        S_WRITE: begin
          if( reg_wallready ) begin
            state     <= S_WRITE2;
          end
        end
        S_WRITE2: begin
          if( local_ack & S_AXI_BREADY ) begin
            state     <= S_IDLE;
          end
        end
        S_READ: begin
          if( local_ack & S_AXI_RREADY ) begin
            state     <= S_IDLE;
          end
        end
        default: state <= S_IDLE;
      endcase
    end
  end

  // Write Channel
  assign S_AXI_AWREADY  = ( state == S_WRITE || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_WREADY   = ( state == S_WRITE || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_BVALID   = ( state == S_WRITE2 )?local_ack:1'b0;
  assign S_AXI_BRESP    = 2'b00;

  // Read Channel
  assign S_AXI_ARREADY  = ( state == S_READ  || state == S_IDLE )?1'b1:1'b0;
  assign S_AXI_RVALID   = ( state == S_READ )?local_ack:1'b0;
  assign S_AXI_RRESP    = 2'b00;
  assign S_AXI_RDATA    = ( state == S_READ )?local_rdata:32'd0;

  // Local Interface
  wire          wr_ena, rd_ena, wr_ack;
  reg           rd_ack;
  reg [31:0]    reg_rdata;

  assign local_cs           = (( state == S_WRITE2 )?1'b1:1'b0) | (( state == S_READ )?1'b1:1'b0) | 1'b0;
  assign local_rnw          = reg_rnw;
  assign local_addr[31:0]   = reg_addr[31:0];
  assign local_be[3:0]      = reg_be[3:0];
  assign local_wdata[31:0]  = reg_wdata[31:0];
  assign local_ack          = wr_ack | rd_ack;
  assign local_rdata[31:0]  = reg_rdata[31:0];

  assign wr_ena = (local_cs & ~local_rnw)?1'b1:1'b0;
  assign rd_ena = (local_cs &  local_rnw)?1'b1:1'b0;
  assign wr_ack = wr_ena;

  // local logic
  localparam A_STATUS    = 8'h00;
  localparam A_SIZE      = 8'h04;
  localparam A_PIXEL     = 8'h08;

  reg         reg_rst;

  // Write Register
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      reg_rst <= 1'b0;
    end else begin
      if(wr_ena) begin
        case(local_addr[7:0] & 8'hFC)
          A_STATUS: begin
            reg_rst <= local_wdata[31];
          end
          A_SIZE: begin
          end
          A_PIXEL: begin
          end
          default: begin
          end
        endcase
      end
    end
  end

  // Read Register
  always @(posedge ACLK or negedge ARESETN) begin
    if(!ARESETN) begin
      reg_rdata[31:0] <= 32'd0;
      rd_ack <= 1'b0;
    end else begin
      rd_ack <= rd_ena;
      if(rd_ena) begin
        case(local_addr[7:0] & 8'hFC)
          A_STATUS: reg_rdata[31:0] <= {reg_rst, 30'd0, LOGIC_IDLE};
          A_SIZE:   reg_rdata[31:0] <= {HEIGHT[15:0], WIDTH[15:0]};
          A_PIXEL:  reg_rdata[31:0] <= {PIXELY[15:0], PIXELX[15:0]};
          default:  reg_rdata[31:0] <= 32'd0;
        endcase
      end else begin
        reg_rdata[31:0] <= 32'd0;
      end
    end
  end

  assign LOGIC_RST = reg_rst;

  assign DEBUG[31:0] = {32'd0};

endmodule
