module z_scan(sob,zid,zid_vld,clk,rst_n);
input sob;
input clk;
input rst_n;
output zid;
output zid_vld;

wire [5:0] zid;

reg [5:0] ras_cnt;
assign zid = {ras_cnt[5],ras_cnt[3],ras_cnt[1],ras_cnt[4],ras_cnt[2],ras_cnt[0]};
reg zid_vld_r;
assign zid_vld = zid_vld_r;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        zid_vld_r <= 'b0;
        ras_cnt <= 'b0;
    end
    else if(sob) begin
        zid_vld_r <= 'b1;
        ras_cnt <= 0;
    end
    else if(zid_vld_r) begin
        if(ras_cnt == 'd63) begin
            zid_vld_r <= 'b0;
        end
        else begin
            ras_cnt <= ras_cnt + 1'b1;
        end
    end
end

endmodule
