module bin2bcd(clk,rst_n,bin,bin_vld,bcd,bcd_vld);
input clk;
input rst_n;
input bin;
input bin_vld;
output bcd;
output bcd_vld;

wire [10:0] bin;
wire [16:0] bcd;

reg [9:0] bin_t;
reg [15:0] u_bcd_r;
reg bcd_vld_t;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        u_bcd_r <= 'b0;
        bin_t <= 'b0;
        bcd_vld_t <= 'b0;
    end
    else if (bin_vld) begin
        if (bin[10]) bin_t <= (~bin[9:0])-1'b1;
        else bin_t <= bin[9:0];
        bcd_vld_t <= 'b0;
    end
    else if (bin_t[9:0] >= 'd1000) begin
        bin_t <= bin_t - 'd1000;
        u_bcd_r[15:12] <= u_bcd_r[15:12] + 1'b1;
    end
    else if (bin_t[9:0] >= 'd100) begin
        bin_t <= bin_t - 'd100;
        u_bcd_r[11:8] <= u_bcd_r[11:8] + 1'b1;
    end
    else if (bin_t[9:0] >= 'd10) begin
        bin_t <= bin_t - 10;
        u_bcd_r[7:4] <= u_bcd_r[7:4] + 1'b1;
    end
    else if (bin_t[9:0] >= 'd0)begin
        u_bcd_r[3:0] <= bin_t; 
        bcd_vld_t <= 1'b1;     
    end
end

reg [16:0]u_bcd_r_t;
reg bcd_vld_t_r;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)begin
        u_bcd_r_t <= 'b0;
        bcd_vld_t_r <= 'b0;
    end
    if (bcd_vld_t) begin
        u_bcd_r_t <= {bin[10],u_bcd_r[15:0]};
        bcd_vld_t_r <= 1'b1;
    end
    else begin
        u_bcd_r_t <= 'b0;
        bcd_vld_t_r <= 'b0;
    end
end

assign bcd_vld = bcd_vld_t_r;
assign bcd = u_bcd_r_t;

endmodule