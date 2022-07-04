`timescale 1ns/1ns
module clock_gating_tb();

reg en;
reg clk;
reg rstn;
wire [7:0] dout;

clock_gating u_clock_gating(
    .en (en),
    .clk (clk),
    .rstn (rstn),
    .dout (dout)
);

initial begin
    clk = 1;
end

always #5 clk = !clk;

initial begin
    rstn = 0;
    en = 0;
    #10
    rstn = 1;
    #10
    en = 0;
    #13
    en = 1;
    #31
    en = 0;
    #10
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("clock_gating.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule