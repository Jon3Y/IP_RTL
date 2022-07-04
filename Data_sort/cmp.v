module cmp(
    input clk,
    input rst_n,
    input in_vld,
    input direction,
    input signed [15:0] din,
    output signed [15:0] dout
);

parameter DATA_MIN = 16'h8000;

wire signed [15:0] cmp0;
wire signed [15:0] cmp1;

reg signed [15:0] dmax;
reg signed [15:0] dmin;

assign cmp0 = (!direction)?din:dmin;
assign cmp1 = (!direction)?dmax:din;
assign dout = (!direction)?dmin:dmax;       //0->min;1->max;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        dmax <= DATA_MIN;
        dmin <= DATA_MIN;
    end
    else if (in_vld) begin
        if(cmp0 > cmp1) begin
            dmax <= cmp0;
            dmin <= cmp1;
        end
        else begin
            dmax <= cmp1;
            dmin <= cmp0;
        end
    end
end

endmodule