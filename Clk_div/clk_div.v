//5.3 div

module clk_div(
    input clk,
    input rstn,
    output reg clk_div
);

parameter NUM = 53;
parameter NUM0 = 5;
parameter NUM1 = 6;

reg [8:0] cnt;
reg [3:0] cnt0;
reg [3:0] cnt1;
reg clk_div_0;
reg clk_div_1;

wire [8:0] cnt_max;
wire [3:0] cnt_max0;
wire [3:0] cnt_max1;
wire [3:0] cnt_half0;
wire [3:0] cnt_half1;

assign cnt_max = NUM - 1'b1;
assign cnt_max0 = NUM0 - 1'b1;
assign cnt_max1 = NUM1 - 1'b1;
assign cnt_half0 = NUM0 >> 1;
assign cnt_half1 = NUM1 >> 1;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt <= 8'b0;
    end
    else if (cnt == cnt_max) begin
        cnt <= 8'b0;
    end
    else begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_div <= 1'b0;
    end
    else if (cnt <= 8'd34) begin
        clk_div <= clk_div_0;
    end
    else begin
        clk_div <= clk_div_1;
    end
end

//5 div;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt0 <= 4'b0;
    end
    else if (cnt0 == cnt_max0) begin
        cnt0 <= 4'b0;
    end
    else begin
        cnt0 <= cnt0 + 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_div_0 <= 4'b0;
    end
    else if (cnt0 == 0) begin
        clk_div_0 <= 1'b1;
    end
    else if (cnt0 == cnt_half0)begin
        clk_div_0 <= 1'b0;
    end
    else begin
        clk_div_0 <= clk_div_0;
    end
end

//6 div;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        cnt1 <= 4'b0;
    end
    else if (cnt1 == cnt_max1) begin
        cnt1 <= 4'b0;
    end
    else begin
        cnt1 <= cnt1 + 1'b1;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        clk_div_1 <= 4'b0;
    end
    else if (cnt1 == 0) begin
        clk_div_1 <= 1'b1;
    end
    else if (cnt1 == cnt_half1)begin
        clk_div_1 <= 1'b0;
    end
    else begin
        clk_div_1 <= clk_div_1;
    end
end

endmodule