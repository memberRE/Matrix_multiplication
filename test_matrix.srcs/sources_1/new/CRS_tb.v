`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/10/28 17:08:47
// Design Name: 
// Module Name: CRS_tb
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


module CRS_tb(
    );
    reg clk;
    reg rst;
    reg valid;
    reg eop;
    reg [1:0] transmod;
    reg signed [31:0] data;
    reg [11:0] column;
    wire valid_o;
    wire eop_o;
    wire signed [75:0] data_o;
    reg [11:0] column_r [35839:0];
    reg [31:0] dataA_r  [35839:0];
    reg [31:0] offset_r [35839:0];
    reg [31:0] dataB_r  [ 2687:0];

    always #5 clk = ~clk;

    integer f1, f1_x, f1_b, offset_data, file_out;
    integer ia, ib, ic, tema,temb,temc;
    initial begin
        f1 = $fopen("D:/FPGA/test_matrix/test_matrix/test_matrix.srcs/sources_1/new/data_real.txt","r");
        f1_x = $fopen("D:/FPGA/test_matrix/test_matrix/test_matrix.srcs/sources_1/new/b_real.txt","r");
        offset_data = $fopen("D:/FPGA/test_matrix/test_matrix/test_matrix.srcs/sources_1/new/offset_real.txt","r");
        ia = 0;
        ib = 0;
        ic = 0;
        while (!$feof(f1)) begin
            tema = $fscanf(f1, "%d %d", column_r[ia], dataA_r[ia]);
            ia = ia + 1;
        end 
        while (!$feof(f1_x)) begin
            temb = $fscanf(f1_x, "%d", dataB_r[ib]);
            ib = ib + 1;
        end 
        while (!$feof(offset_data)) begin
            temc = $fscanf(offset_data, "%d", offset_r[ic]);
            ic = ic + 1;
        end
        $fclose(f1);
        $fclose(f1_x);
    end

    integer i,j;
    initial begin
        file_out = $fopen("D:/FPGA/test_matrix/test_matrix/test_matrix.srcs/sources_1/new/circuit_1_d.mtx","w");
        clk <= 1'b1;
        rst <= 1'b1;
        valid    <= 1'b0;
        eop      <= 1'b0;
        transmod <= 2'b0;
        data     <= 32'b0;
        column   <= 12'b0;
        #100;
        rst<=1'b0;
        for (i=0;i<ib - 1;i=i+1) begin
            eop      <= 1'b0;
            valid    <= 1'b1;
            transmod <= 2'b11;
            data     <= dataB_r[i];
            # 10;
        end
        eop      <= 1'b1;
        valid    <= 1'b1;
        transmod <= 2'b11;
        data     <= dataB_r[ib-1];
        # 10;
        for (i=1;i<ic-1;i=i+1) begin
            eop      <= 1'b0;
            valid    <= 1'b1;
            transmod <= 2'b10;
            data     <= offset_r[i] + offset_r[i];//(offset_r[i] - offset_r[i-1] == 1)?offset_r[i]:offset_r[i]+32'd1;
            # 10;
        end
        eop      <= 1'b1;
        valid    <= 1'b1;
        transmod <= 2'b10;
        data     <= offset_r[ic-1]+offset_r[ic-1];
        # 10;
        for (j=0;j<ia-1;j=j+1) begin
            eop      <= 1'b0;
            valid    <= 1'b1;
            transmod <= 2'b00;
            data     <= dataA_r[j];
            column   <= column_r[j] - 32'b1;
            # 10;

            eop      <= 1'b0;
            valid    <= 1'b1;
            transmod <= 2'b00;
            data     <= 0;
            column   <= 0;
            # 10;
        end
        eop      <= 1'b1;
        valid    <= 1'b1;
        transmod <= 2'b00;
        data     <= dataA_r[ia-1];
        column   <= column_r[ia-1];
        # 10;
        eop      <= 1'b1;
        valid    <= 1'b1;
        transmod <= 2'b00;
        data     <= 0;
        column   <= 0;
        # 10;
        valid    <= 1'b0;
        eop      <= 1'b0;
        transmod <= 2'b00;
        data     <= 32'b0;
        column   <= 12'b0;
        # 500;
        $fclose(file_out);
        $stop;
    end

    always @(posedge clk) begin
        if (valid_o) begin
            $fwrite(file_out,"%d\n",data_o);
        end
    end

    CRS my_CRS(
        .clk      (clk),
        .rst      (rst),
        .valid    (valid),
        .eop      (eop),
        .transmod (transmod),
        .data     (data), 
        .column   (column), 
        .valid_o  (valid_o), 
        .eop_o    (eop_o),
        .data_o   (data_o)
    );
endmodule
