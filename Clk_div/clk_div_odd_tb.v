`timescale 1ns/1ns

module clk_div_odd_tb;

reg clk;
reg rstn;
wire clk_div;

clk_div_odd u_clk_div_odd(
    .clk(clk),
    .rstn(rstn),
    .clk_div(clk_div)
);

initial clk = 1'b1;
always #2 clk = ~clk;

initial begin
    rstn = 1'b0;
    #6
    rstn = 1'b1;
    #60
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("clk_div.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule