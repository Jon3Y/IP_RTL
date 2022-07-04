module sync_handshake_data_bus(src_clk,src_rst_n,src_vld,din,src_ack,dst_clk,dst_rst_n,dst_vld,dout,dst_ack);

input src_clk;
input src_rst_n;
input src_vld;
input [7:0] din;
output src_ack;
input dst_clk;
input dst_rst_n;
input dst_ack;
output [7:0] dout;
output dst_vld;



//src_vld_lev：src->dst;
reg dst_vld_r0;
reg dst_vld_r1;
reg dst_vld_r2;
wire dst_pos_pulse;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_vld_r0 <= 1'b0;
        dst_vld_r1 <= 1'b0;
        dst_vld_r2 <= 1'b0;
    end
    else begin
        dst_vld_r0 <= src_vld_lev;
        dst_vld_r1 <= dst_vld_r0;
        dst_vld_r2 <= dst_vld_r1;
    end
end
assign dst_pos_pulse = dst_vld_r1 && (!dst_vld_r2);

//dst_sync_idle -> src_sync_idle;
wire dst_sync_idle;
reg dst_sync_idle_r;
assign dst_sync_idle = dst_pos_pulse && dst_ack;

always @(posedge dst_clk or dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_sync_idle_r <= 1'b0;
    end
    else begin
        dst_sync_idle_r <= dst_sync_idle;
    end   
end

reg src_sync_idle_r0;
reg src_sync_idle_r1;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_sync_idle_r0 <= 1'b0;
        src_sync_idle_r1 <= 1'b0;
    end
    else begin
        src_sync_idle_r0 <= dst_sync_idle_r;
        src_sync_idle_r1 <= src_sync_idle_r0;
    end
end

//src_sync_idle_r1 -> dst_sync_s0_r1;
reg src_sync_s0_r;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_sync_s0_r <= 1'b0;
    end
    else begin
        src_sync_s0_r <= src_sync_idle_r1;
    end    
end

reg dst_sync_s0_r0;
reg dst_sync_s0_r1;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_sync_s0_r0 <= 1'b0;
        dst_sync_s0_r1 <= 1'b0;
    end
    else begin
        dst_sync_s0_r0 <= src_sync_s0_r;
        dst_sync_s0_r1 <= dst_sync_s0_r0;
    end
end

//dst_sync_s0_r1 -> src_sync_s1_r1;
reg dst_sync_s1_r;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_sync_s1_r <= 1'b0;
    end
    else begin
        dst_sync_s1_r <= dst_sync_s0_r1;
    end    
end

reg src_sync_s1_r0;
reg src_sync_s1_r1;
reg src_sync_s1_r2;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_sync_s1_r0 <= 1'b0;
        src_sync_s1_r1 <= 1'b0;
    end
    else begin
        src_sync_s1_r0 <= dst_sync_s1_r;
        src_sync_s1_r1 <= src_sync_s1_r0;
        src_sync_s1_r2 <= src_sync_s1_r1;
    end
end
assign src_pos_pulse = src_sync_s1_r1 && (~src_sync_s1_r2);
assign src_ack =  src_pos_pulse;

//src_sync_s1_r1 -> dst_sync_s2_r1;
reg src_sync_s2_r;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_sync_s2_r <= 1'b0;
    end
    else begin
       src_sync_s2_r <=src_pos_pulse;
    end    
end

reg dst_sync_s2_r0;
reg dst_sync_s2_r1;
reg dst_sync_s2_r2;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        dst_sync_s2_r0 <= 1'b0;
        dst_sync_s2_r1 <= 1'b0;
    end
    else begin
        dst_sync_s2_r0 <= src_sync_s2_r;
        dst_sync_s2_r1 <= dst_sync_s0_r0;
        dst_sync_s2_r2 <= dst_sync_s0_r1;
    end
end
assign dst_vld =  dst_sync_s2_r1 && (~dst_sync_s2_r2);

//拓宽src_vld;
reg src_vld_lev;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        src_vld_lev <= 1'b0;
    end
    else if (src_vld&&(~src_sync_idle_r1)) begin
        src_vld_lev <= 1'b1;
    end
    else begin
        src_vld_lev <= 1'b0;
    end
end

//src din -> data_in_r;
reg [7:0] data_in_r;
always @(posedge src_clk or negedge src_rst_n) begin
    if (!src_rst_n) begin
        data_in_r <= 8'b0;
    end
    else if (src_vld && (~src_vld_lev)) begin
        data_in_r <= din;
    end
    else begin
        data_in_r <= data_in_r;
    end
end

//src ->dst data_in_r -> data_out_r;
reg [7:0] data_out_r;
always @(posedge dst_clk or negedge dst_rst_n) begin
    if (!dst_rst_n) begin
        data_out_r <= 8'b0;
    end
    else if (dst_sync_idle) begin
        data_out_r <= data_in_r;
    end
    else begin
        data_out_r <= data_out_r;
    end
end
assign dout = data_out_r;

endmodule