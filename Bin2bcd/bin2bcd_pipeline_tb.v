`timescale 1ns/1ns
module bin2bcd_pipeline_tb;
reg clk;
reg rst_n;
reg [10:0]bin;
reg bin_vld;
wire [16:0]bcd;
wire bcd_vld;

bin2bcd_pipeline u_bin2bcd_pipeline(
    .clk(clk),
    .rst_n(rst_n),
    .bin(bin),
    .bin_vld(bin_vld),
    .bcd(bcd),
    .bcd_vld(bcd_vld)
);

initial clk = 0;
always #5 clk = ~clk;

integer i;
initial begin
    rst_n = 0;
    bin_vld = 0;
    #10
    rst_n = 1;
    bin_vld = 1;
    for (i= -1023;i<=1023;i=i+1) begin
        #10
        bin = i;
    end
end
endmodule