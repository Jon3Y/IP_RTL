module clk_div_odd(
    input clk,
    input rstn,
    output reg clk_div
);

parameter ODD_NUM = 5;

wire [3:0] cnt_max;
wire [3:0] cnt_half;
reg [3:0] cnt;
reg clk_div_p;
reg clk_div_n;

assign cnt_max = ODD_NUM - 1'b1;
assign cnt_half = cnt_max >> 1;
assign clk_div = (clk_div_n | clk_div_p);

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt <= 1'b0;
    end
    else if (cnt == cnt_max) begin
        cnt <= 1'b0;
    end
    else begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_div_p <= 1'b0;
    end
    else if (cnt == 0) begin
        clk_div_p <= 1;
    end
    else if (cnt == cnt_half) begin
        clk_div_p <= 0;
    end
    else begin
        clk_div_p <= clk_div_p;
    end
end

always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_div_n <= 1'b0;
    end
    else if (cnt == 0) begin
        clk_div_n <= 1;
    end
    else if (cnt == cnt_half) begin
        clk_div_n <= 0;
    end
    else begin
        clk_div_n = clk_div_n;
    end
end

endmodule