/*
 * Don't remove this header. 
 *
 * Decode JPEG
 *
 * Copyright (C)2006-2015 AQUAXIS TECHNOLOGY.
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 * License URI: http://github.com/aquaxis/aq_axis_djpeg/LICENSE
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: hidemi(at)aquaxis.com
 */
module aq_djpeg_dqt(
    input           rst,
    input           clk,

    input           DataInEnable,
    input           DataInColor,
    input [5:0]     DataInCount,
    input [7:0]     DataIn,

    input           TableColor,
    input  [5:0]    TableNumber,
    output [7:0]    TableData
);
    // RAM
    reg [7:0]       DQT_Y [0:63];
    reg [7:0]       DQT_C [0:63];

    // RAM
    always @(posedge clk) begin
        if(DataInEnable ==1'b1 && DataInColor ==1'b0) begin
            DQT_Y[DataInCount] <= DataIn;
        end
        if(DataInEnable ==1'b1 && DataInColor ==1'b1) begin
            DQT_C[DataInCount] <= DataIn;
        end
    end

    reg [7:0] TableDataY;
    reg [7:0] TableDataC;

    // RAM out
    always @(posedge clk) begin
        TableDataY <= DQT_Y[TableNumber];
        TableDataC <= DQT_C[TableNumber];
    end

    // Selector
    assign TableData = (TableColor)?TableDataC:TableDataY;
endmodule
