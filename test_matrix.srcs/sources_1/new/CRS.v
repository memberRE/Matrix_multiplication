`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/28 10:41:10
// Design Name: 
// Module Name: CRS
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


module CRS(
    input   wire               clk      ,
    input   wire               rst      ,
    // 输入端
    input   wire               valid    , // 输入有效信号
    input   wire               eop      , // 本次传输最后一个数据
    input   wire        [1:0]  transmod , // 11:vector ,00:matrix,10:rows
    input   wire signed [31:0] data     , // 传输数据
    //input   wire        [11:0] row      , // 当前传输非0数据所在行
    input   wire        [11:0] column   , // 当前传输非0数据所在列
    // 输出端
    output  reg                ready    ,//ready to receive data
    output  reg                valid_o  , // 输出有效信号
    output  reg                eop_o    , // 本次传输最后一个数据
    output  reg  signed [75:0] data_o     // 输出数据
    );

    reg [11:0] addr_save; // row number and addr of bram
    wire wea_b,wea_row;
    wire signed [31:0] dout_b;
    wire signed [31:0] dout_offset;
    wire signed [63:0] P;
    assign wea_b = transmod[0]&transmod[1]&valid;
    assign wea_row = transmod[1]&(~transmod[0])&valid;

    reg valid_f1,valid_f2;
    reg eop_f1,eop_f2;
    reg [1:0] transmod_f1;
    reg [1:0] transmod_f2;
    reg signed [75:0] tem_sum;
    reg signed [31:0] data_f1;
    reg [11:0] row_f1;
    reg [11:0] row_f2;
    reg [11:0] row_f3;
    reg [11:0] tot_line;
    reg need_out;
    reg eop_need_out;
    reg [31:0] cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            addr_save<=12'b0;
        end
        else if (wea_b || wea_row) begin
            if (eop) begin
                tot_line <= addr_save + 12'b1;
                addr_save <= 12'b0;
            end
            else begin
                addr_save <= addr_save + 12'b1;
            end
        end
        /*else begin
            addr_save<=addr_save;
        end*/
    end

    blk_mem_gen_0 B_vec(
    .clka  (clk   ), // input wire clka
    .wea   (wea_b   ), // input wire [0 : 0] wea
    .addra (addr_save ), // input wire [11 : 0] addra
    .dina  (data  ), // input wire [31 : 0] dina
    .douta (dout_b )  // output wire [31 : 0] douta
    );

    blk_mem_gen_0 Row_offset( //Row_offest[i] = offset[i+1] !!!!!!
    .clka  (clk   ), // input wire clka
    .wea   (wea_row   ), // input wire [0 : 0] wea
    .addra (addr_save ), // input wire [11 : 0] addra
    .dina  (data  ), // input wire [31 : 0] dina
    .douta (dout_offset )  // output wire [31 : 0] douta
    );
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid_f1    <= 1'b0;
            valid_f2    <= 1'b0;
            eop_f1      <= 1'b0;
            eop_f2      <= 1'b0;
            transmod_f1 <= 1'b0;
            transmod_f2 <= 1'b0;
            data_f1     <= 32'b0;
            row_f1      <= 12'b0;
            row_f2      <= 12'b0;
            row_f3      <= 12'b0;
        end
        else begin
            valid_f1    <= valid      ;
            valid_f2    <= valid_f1   ;
            eop_f1      <= eop        ;
            eop_f2      <= eop_f1     ;
            transmod_f1 <= transmod   ;
            transmod_f2 <= transmod_f1;
            data_f1     <= data       ;
            row_f1      <= addr_save  ;
            row_f2      <= row_f1     ;
            row_f3      <= row_f2     ;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt <= 32'b0;
            ready<=1'b1;
        end
        else if (~(transmod_f1[0] | transmod_f1[1]) & valid_f1 & ready) begin
            if (cnt == dout_offset - 32'b1) begin
                addr_save <= addr_save + 1'b1;
            end
            cnt <= cnt+32'b1;
        end
    end

    my_mult mult__(
        .CLK (clk     ), // input wire CLK
        .A   (data_f1 ), // input wire [31 : 0] A
        .B   (douta   ), // input wire [31 : 0] B
        .P   (P       )  // output wire [63 : 0] P
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tem_sum <= 76'b0;
        end
        else if (valid_f2 & (~transmod_f2[0]) & (~transmod_f2[1]) ) begin
            if (row_f3 == row_f2) begin
                tem_sum <= tem_sum + P;
            end
            else begin
                tem_sum <= P;
            end
        end
        // else begin
        //     temp_sum <= temp_sum;
        // end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            need_out <= 1'b0;
        end
        else if (valid_f2 & (~transmod_f2[0]) & (~transmod_f2[1]) && (row_f2!=row_f1)) begin
            need_out <= 1'b1;
        end
        else begin
            need_out <= 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            eop_need_out <= 1'b0;
        end
        else if (eop_f2& (~transmod_f2[0]) & (~transmod_f2[1]) && (row_f2 + 1'b1 == tot_line)) begin
            eop_need_out <= 1'b1;
        end
        else begin
            eop_need_out <= 1'b0;
        end
    end

    always @(posedge clk or posedge rst) begin
    if (rst) begin
        valid_o <= 1'b0;
        data_o  <= 76'b0;
        eop_o   <= 1'b0;
    end
    else if (need_out) begin
        valid_o <= 1'b1;
        data_o  <= tem_sum;
        eop_o   <= eop_need_out;
    end
    else begin
        valid_o <= 1'b0;
        data_o  <= 76'b0;
        eop_o   <= 1'b0;
    end
end


endmodule
