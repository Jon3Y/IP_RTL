module key_led(
    clk,
    rstn,
    key,
    led
);

input wire clk;
input wire rstn;
input wire key;
output reg led;

wire key_pulse;

key_filter u_key_filter(
    .clk(clk),
    .rstn(rstn),
    .key(key),
    .key_pulse(key_pulse)
);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        led <= 1'b1;
    end
    else if (key_pulse) begin
        led <= ~led;
    end
    else begin
        led <= led;
    end
end

endmodule