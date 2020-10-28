`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/25 23:41:06
// Design Name: 
// Module Name: mult
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mult(
    input wire clk,
    input wire valid,
    input wire [31:0] data,
    input wire [11:0] out_addr,
    output wire [31:0] bram_o
    );

blk_mem_gen_0 U_blk_mem_gen_0(
    .clka  (clk   ), // input wire clka
    .wea   (valid ), // input wire [0 : 0] wea
    .addra (out_addr ), // input wire [11 : 0] addra
    .dina  (data  ), // input wire [31 : 0] dina
    .douta (bram_o)  // output wire [31 : 0] douta
);

endmodule
