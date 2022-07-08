//key filter;
//default state of the key is 1;
//button press is 0;
//clk -> 50Mhz;

module key_filter(
    clk,
    rstn,
    key,
    key_pulse
);

input wire clk;
input wire rstn;
input wire key;
output wire key_pulse;

parameter COUNTER = 499999;     //jitter time -> 10ms;

reg key_r;
reg key_r_d;
reg [19:0] cnt;
reg key_current;
reg key_pre;
wire key_negedge;

//key reg;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        key_r <= 1'b1;
        key_r_d <= 1'b1;
    end
    else begin
        key_r <= key;
        key_r_d <= key_r;
    end
end

//key negedge detected;
assign key_negedge = ((~key_r) & key_r_d);

//jitter counter;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt <= 20'h0;
    end
    else if (key_negedge) begin
        cnt <= 20'h0;
    end
    else if (cnt==COUNTER) begin
        cnt <= 20'h0;
    end
    else begin
        cnt <= cnt + 1'b1;
    end    
end

//stable signal detected;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        key_current <= 1'b1;
    end
    else if (cnt==COUNTER) begin
        key_current <= key;
    end
    else begin
        key_current <= key_current;
    end
end

//previous state of the key;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        key_pre <= 1'b1;
    end
    else begin
        key_pre <= key_current;
    end
end

//stable key negedge detected;
assign key_pulse = (key_pre & (~key_current));


endmodule