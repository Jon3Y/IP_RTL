`timescale 1ns/1ns
module bin2bcd_tb;
reg clk;
reg rst_n;
reg [10:0]bin;
reg bin_vld;
wire [16:0]bcd;
wire bcd_vld;

bin2bcd u_bin2bcd(
    .clk(clk),
    .rst_n(rst_n),
    .bin(bin),
    .bin_vld(bin_vld),
    .bcd(bcd),
    .bcd_vld(bcd_vld)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    rst_n = 0;
    bin_vld = 0;
    #10
    rst_n = 1;
    bin_vld = 1;
    bin = 0423;
    #10;
    bin_vld = 0;
end
endmodule