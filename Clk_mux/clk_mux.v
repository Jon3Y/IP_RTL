//glitch free clock mux;

module clk_mux(
    input clk0,
    input clk1,
    input rstn0,
    input rstn1,
    input clk_sel,
    output clk
);

wire en_clk0;
reg en_clk0_d0;
reg en_clk0_d1;
reg en_clk0_d2;
wire en_clk1;
reg en_clk1_d0;
reg en_clk1_d1;
reg en_clk1_d2;

assign en_clk0 = (!clk_sel) & (!en_clk1_d2);
assign en_clk1 = clk_sel & (!en_clk0_d2);
assign clk = (en_clk0_d2 & clk0) | (en_clk1_d2 & clk1);

//clk0 en;
always @(posedge clk0 or negedge rstn0) begin
    if (!rstn0) begin
        en_clk0_d0 <= 1'b0;
    end
    else begin
        en_clk0_d0 <= en_clk0;
    end
end

always @(posedge clk0 or negedge rstn0) begin
    if (!rstn0) begin
        en_clk0_d1 <= 1'b0;
    end
    else begin
        en_clk0_d1 <= en_clk0_d0;
    end
end

always @(negedge clk0 or negedge rstn0) begin
    if (!rstn0) begin
        en_clk0_d2 <= 1'b0;
    end
    else begin
        en_clk0_d2 <= en_clk0_d1;
    end
end

//clk1 en;
always @(posedge clk1 or negedge rstn1) begin
    if (!rstn1) begin
        en_clk1_d0 <= 1'b0;
    end
    else begin
        en_clk1_d0 <= en_clk1;
    end
end

always @(posedge clk1 or negedge rstn1) begin
    if (!rstn1) begin
        en_clk1_d1 <= 1'b0;
    end
    else begin
        en_clk1_d1 <= en_clk1_d0;
    end
end

always @(negedge clk1 or negedge rstn1) begin
    if (!rstn1) begin
        en_clk1_d2 <= 1'b0;
    end
    else begin
        en_clk1_d2 <= en_clk1_d1;
    end
end

endmodule