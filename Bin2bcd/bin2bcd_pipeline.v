module bin2bcd_pipeline(clk,rst_n,bin,bin_vld,bcd,bcd_vld);
input clk;
input rst_n;
input bin;
input bin_vld;
output bcd;
output bcd_vld;
wire [10:0] bin;
wire [16:0] bcd;

reg [16:0] bcd_r;
assign bcd = bcd_r;

reg [4:0]bcd_vld_r;
assign bcd_vld = bcd_vld_r[4];

reg [10:0] bin0;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bin0 <= 'b0;
    end
    else if (bin_vld) begin
        bin0[10:0] <= (bin[10])?({bin[10],((~bin[9:0])+1'b1)}):bin[10:0];
    end
    else begin
        bin0 <= 'b0;
    end
end

reg [10:0] bin1;
reg [15:0] bcd_r1;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bin1 <= 'b0;
        bcd_r1 <= 'b0; 
    end
    else if (bin0[9:0]>='d1000) begin 
        bcd_r1[15:12] <= 4'b0001;
        bin1[10:0] <= {bin0[10],(bin0[9:0]-10'd1000)};
    end
    else begin
        bcd_r1[15:12] <= 4'b0;
        bin1 <= bin0;
    end
end

reg [10:0] bin2;
reg [15:0] bcd_r2;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bin2 <= 'b0;
        bcd_r2 <= 'b0; 
    end
    else if (bin1[9:0]>='d900) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd9;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd900)};
    end
    else if (bin1[9:0]>='d800) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd8;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd800)};
    end
    else if (bin1[9:0]>='d700) begin 
       bcd_r2[15:8] <= bcd_r1[15:8] + 4'd7;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd700)};
    end
    else if (bin1[9:0]>='d600) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd6;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd600)};
    end
    else if (bin1[9:0]>='d500) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd5;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd500)};
    end
    else if (bin1[9:0]>='d400) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd4;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd400)};
    end
    else if (bin1[9:0]>='d300) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd3;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd300)};
    end
    else if (bin1[9:0]>='d200) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd2;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd200)};
    end
    else if (bin1[9:0]>='d100) begin 
        bcd_r2[15:8] <= bcd_r1[15:8] + 4'd1;
        bin2[10:0] <= {bin1[10],(bin1[9:0]-10'd100)};
    end
    else begin
        bcd_r2[15:8] <= bcd_r1[15:8];
        bin2 <= bin1;
    end
end

reg [10:0] bin3;
reg [15:0] bcd_r3;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bin3 <= 'b0;
        bcd_r3 <= 'b0; 
    end
    else if (bin2[9:0]>='d90) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd9;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd90)};
    end
    else if (bin2[9:0]>='d80) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd8;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd80)};
    end
        else if (bin2[9:0]>='d70) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd7;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd70)};
    end
        else if (bin2[9:0]>='d60) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd6;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd60)};
    end
        else if (bin2[9:0]>='d50) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd5;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd50)};
    end
        else if (bin2[9:0]>='d40) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd4;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd40)};
    end
        else if (bin2[9:0]>='d30) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd3;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd30)};
    end
        else if (bin2[9:0]>='d20) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd2;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd20)};
    end
        else if (bin2[9:0]>='d10) begin 
        bcd_r3[15:4] <= bcd_r2[15:4] + 4'd1;
        bin3[10:0] <= {bin2[10],(bin2[9:0]-10'd10)};
    end
    else begin
        bcd_r3[15:4] <= bcd_r2[15:4];
        bin3 <= bin2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bcd_r <= 'b0; 
    end
    else begin
        bcd_r[16:0] <= {bin3[10],bcd_r3[15:4],bin3[3:0]};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        bcd_vld_r <= 'b0;
    end
    else if (bin_vld) begin
        bcd_vld_r <= {bcd_vld_r[3:0],1'b1};
    end
    else begin
        bcd_vld_r <= bcd_vld_r << 1;
    end
end

endmodule