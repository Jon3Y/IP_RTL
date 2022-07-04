`timescale 1ns/1ns
module async_reset_tb();

reg rstn_async;
reg clk;
wire rstn;

async_reset u_async_reset(
    .rstn_async(rstn_async),
    .clk(clk),
    .rstn(rstn)
);

initial begin
    clk = 1;
end

always #5 clk = !clk;

initial begin
    rstn_async = 0;
    #4;
    rstn_async = 1;
    #33;
    rstn_async = 0;
    #14;
    rstn_async = 1;
    #28;
    rstn_async = 0;
    #16;
    rstn_async = 0;
    #21;
    rstn_async = 1;
    #10;
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("async_reset.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule