`timescale 1ns/1ns
module tb;

reg clk;
reg rstn;
reg [7:0] din_a;
reg [7:0] din_b;
reg [7:0] din_c;
reg din_vld;
wire [7:0] dout_y;
wire dout_vld;

dec_multip u_dec_multip(
    .clk(clk),
    .rstn(rstn),
    .din_a(din_a),
    .din_b(din_b),
    .din_c(din_c),
    .din_vld(din_vld),
    .dout_y(dout_y),
    .dout_vld(dout_vld)
);

initial begin
    clk = 1'b1;
end

always #5 clk = ~clk;

initial begin
    rstn = 1'b0;
    #10
    rstn = 1'b1;

    cal(0,0,0);
    cal(255,0,0);
    cal(0,255,255);
    cal(255,255,255);
    cal(0,99,99);
    #10
    din_vld = 1'b0;
    
    #20
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars;
    end
`endif

task cal;
    input [7:0] a;
    input [7:0] b;
    input [7:0] c;
    begin
    #10
    din_a = a;
    din_b = b;
    din_c = c;
    din_vld = 1'b1;
    end
endtask

endmodule