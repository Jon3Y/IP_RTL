`timescale 1ns/1ns
module z_scan_tb();

reg sob;
reg clk;
reg rst_n;
wire zid_vld;
wire [5:0] zid;

z_scan u_z_scan(
    .sob(sob),
    .zid(zid),
    .zid_vld(zid_vld),
    .clk(clk),
    .rst_n(rst_n)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
rst_n = 0;
#10
rst_n = 1;
sob = 1;
#10
sob = 0;
#100
$finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("z_scan_tb.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule
