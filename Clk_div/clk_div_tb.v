`timescale 1ns/1ns

module clk_div_tb;

reg clk;
reg rstn;
wire clk_div;

clk_div u_clk_div(
    .clk(clk),
    .rstn(rstn),
    .clk_div(clk_div)
);

initial clk = 1'b1;
always #1 clk = ~clk;

initial begin
    rstn = 1'b0;
    #2
    rstn = 1'b1;
    #200
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("clk_div.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule