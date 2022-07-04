module clk_div_even(
    input clk,
    input rstn,
    output reg clk_div
);

parameter EVEN_NUM = 8;

wire [3:0] cnt_max;
reg [3:0] cnt;

assign cnt_max = (EVEN_NUM >> 1) - 1'b1;

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
        clk_div <= 1'b0;
    end
    else if (cnt == 0) begin
        clk_div <= ~clk_div;
    end
    else begin
        clk_div <= clk_div;
    end
end

endmodule