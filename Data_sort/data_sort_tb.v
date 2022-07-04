`timescale 1ns/1ns
module data_sort_tb;

parameter DATA_MIN = 16'h8000;

reg clk;
reg rst_n;
reg in_vld;
reg signed [15:0] din;
wire signed [15:0] dout;
wire out_vld;

reg [4:0] i;

data_sort u_data_sort(
        .clk(clk),
        .rst_n(rst_n),
        .in_vld(in_vld),
        .din(din),
        .dout(dout),
        .out_vld(out_vld)
);

initial begin
    clk = 0;
end

always #5 clk = ~clk;

initial begin
    rst_n = 0;
    in_vld = 0;
    #10
    rst_n = 1;
    #5
    in_vld = 1;
    for (i=0;i<16;i=i+1) begin
        din = $random%32767;
        #10;
    end
    din = DATA_MIN;
    #1000
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("data_sort_tb.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule