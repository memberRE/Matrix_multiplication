`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/27 21:12:39
// Design Name: 
// Module Name: mult_tb
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


module mult_tb(

    );
    reg clk;
    reg [11:0] addr;
    reg valid;
    reg [31:0] data;
    wire [31:0] outppp;
    always #5 clk = ~clk;
    initial begin
        clk <= 1'b1;
        addr<= 12'd0;
        valid <= 1'b1;
        data<=32'h3f3f3f3f;
        #10
        addr<= 12'd1;
        data<=32'haaaaaaaa;
        #10
        addr<= 12'd2;
        valid <= 1'b1;
        data<=32'h87654321;
        #10
        valid<=1'b0;
        #10
        addr<=12'd1;
        #10
        addr<=12'd0;
        #10
        addr<=12'd1;
    end

    mult my_mult(
        .clk(clk),
        .valid(valid),
        .data(data),
        .out_addr(addr),
        .bram_o(outppp)
    );

endmodule
