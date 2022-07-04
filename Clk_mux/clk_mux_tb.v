`timescale 1ns/1ns

module clk_mux_tb();

reg clk0;
reg clk1;
reg rstn0;
reg rstn1;
reg clk_sel;
wire clk;

clk_mux u_clk_mux(
    .clk0(clk0),
    .clk1(clk1),
    .rstn0(rstn0),
    .rstn1(rstn1),
    .clk_sel(clk_sel),
    .clk(clk)
);

initial begin
    clk0 = 1'b1;
    clk1 = 1'b1;
end

always #1 clk0 = !clk0;
always #3 clk1 = !clk1;

initial begin
    rstn0 = 1'b0;
    rstn1 = 1'b0;
    //clk_sel = 1'b0;
    #6
    rstn0 = 1'b1;
    rstn1 = 1'b1;
    #20
    clk_sel = 1'b0;
    #25
    clk_sel = 1'b1;
    #40
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("clk_mux.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule