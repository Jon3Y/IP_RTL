module clk_div_dec(
    input clk,
    input rstn,
    input load,
    output clk_div
);

parameter M = 5;

reg [15:0] div_mask_sf;
reg [15:0] div_mask;

assign div_mask = {M{1'b1}};
assign clk_div = (clk | (!div_mask_sf[0]));

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        div_mask_sf <= 16'hffff;
    end
    else if (load) begin
        div_mask_sf <= div_mask;
    end
    else begin
        div_mask_sf <= {div_mask_sf[0],div_mask_sf[15:1]};
    end
end

endmodule