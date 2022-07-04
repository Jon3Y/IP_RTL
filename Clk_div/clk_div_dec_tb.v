`timescale 1ns/1ns

module clk_div_dec_tb;

reg clk;
reg rstn;
reg load;
wire clk_div;

clk_div_dec u_clk_div_dec(
    .clk(clk),
    .rstn(rstn),
    .load(load),
    .clk_div(clk_div)
);

initial clk = 1'b1;
always #2 clk = ~clk;

initial begin
    rstn = 1'b0;
    #4
    load = 1'b1;
    rstn = 1'b1;
    #4
    load = 1'b0;
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