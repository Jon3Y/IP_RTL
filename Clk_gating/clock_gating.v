//ICG;
module clock_gating(
    input en,
    input clk,
    input rstn,
    output wire [7:0] dout
);

reg en_d;
wire clk_en;
reg [7:0] cnt;

//latch;
always @(*) begin
    if (!clk) begin
        en_d = en;
    end
end

//& gate;
assign clk_en = en_d && clk;

always @(posedge clk_en or negedge rstn) begin
    if (!rstn) begin
        cnt <= 8'b0;
    end
    else begin
        cnt = cnt + 1'b1;
    end  
end

assign dout = cnt;

endmodule