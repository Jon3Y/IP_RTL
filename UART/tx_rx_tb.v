`timescale 1ns/1ns
module tx_rx_tb;

reg clk;
reg rstn;
reg send_en;
reg [7:0] data;
reg [2:0] baud_set;
wire uart_tx;
wire tx_done;
wire uart_sate;

reg uart_rx;
wire [7:0] data_byte;
wire rx_done;

uart_byte_tx u_uart_byte_tx(
    .clk(clk),
    .rstn(rstn),
    .send_en(send_en),
    .data(data),
    .baud_set(baud_set),
    .uart_tx(uart_tx),
    .tx_done(tx_done),
    .uart_state(uart_sate)
);  

uart_byte_rx u_uart_byte_rx(
    .clk(clk),
    .rstn(rstn),
    .uart_rx(uart_tx),
    .baud_set(baud_set),
    .data_byte(data_byte),
    .rx_done(rx_done)
);

initial begin
    clk = 0;
end
always #1 clk = ~clk;

initial begin
    rstn = 1'b0;
    send_en = 1'b0;
    #10
    rstn = 1'b1;
    data = 8'b1001_1001;
    baud_set = 3'd0;
    send_en = 1'b1;
    #110000
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule
