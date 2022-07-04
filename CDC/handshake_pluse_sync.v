module handshake_pluse_sync(src_clk,src_rst_n,src_pulse,src_sync_fail,dst_clk,dst_rst_n,dst_pulse);
input src_clk;
input src_rst_n;
input src_pulse;
input dst_clk;
input dst_rst_n;
output reg src_sync_fail;
output dst_pulse;

wire src_idle;
reg src_in_r;
reg src_in_ack;

//同步失败信号；
assign src_idle = ~ (src_in_r | src_in_ack);
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_sync_fail <= 1'b0;
    end
    else if (src_pulse&&(~src_idle)) begin
        src_sync_fail <= 1'b1;
    end
    else begin
        src_sync_fail <= 1'b0;
    end
end

//输入脉冲展开；
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_in_r <= 1'b0;
    end
    else if (src_pulse&&src_idle) begin
        src_in_r <= 1'b1;
    end
    else if (src_in_ack) begin
        src_in_r <= 1'b0;
    end
end

//pulse: src->dst;
reg dst_sync_0;
reg dst_sync_1;
reg dst_sync_2;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_clk) begin
        dst_sync_0 <= 1'b0;
        dst_sync_1 <= 1'b0;
        dst_sync_2 <= 1'b0;
    end
    else begin
        dst_sync_0 <= src_in_r;
        dst_sync_1 <= dst_sync_0;
        dst_sync_2 <= dst_sync_1;
    end
end
assign dst_pulse = dst_sync_1 && (~dst_sync_2);

//反馈信号生成；
reg dst_out_ack;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_out_ack <= 1'b0;
    end
    else if (dst_sync_1) begin
        dst_out_ack <= 1'b1;
    end
    else begin
        dst_out_ack <= 1'b0;
    end
end

//ack: dst->src;
reg src_sync_0;
reg src_sync_1;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_in_ack <= 1'b0;
        src_sync_0 <= 1'b0;
        src_sync_1 <= 1'b0;
    end
    else begin
        src_sync_0 <= dst_out_ack;
        src_sync_1 <= src_sync_0;
        src_in_ack <= src_sync_1;
    end
end

endmodule