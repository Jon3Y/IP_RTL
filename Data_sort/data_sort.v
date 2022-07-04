module data_sort(
    input clk,
    input rst_n,
    input in_vld,
    input signed [15:0] din,
    output signed [15:0] dout,
    output out_vld
);

parameter DATA_MIN = 16'h8000;

//----------
//cmd_path;
//----------
reg [4:0] cnt;
wire in_vld_rise;
reg in_vld_d;
wire direction;
wire cmp_en;
reg temp;

assign in_vld_rise = in_vld & (!in_vld_d);//rise edge dete;
assign out_vld = temp;//output en;      
assign direction = temp;//cmp direction;
assign cmp_en = in_vld | temp;//cmp en;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        in_vld_d <= 1'b0;
    end
    else begin
        in_vld_d <= in_vld;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 1'b0;
    end
    else if (in_vld_rise) begin
        cnt <= 1'b1;
    end
    else if (cnt != 0) begin
        cnt <= cnt + 1'b1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        temp <= 1'b0;
    end
    else if (cnt[4]) begin
        temp <= 1'b1;
    end
    else begin
        temp <= temp;
    end
end

//----------
//data_path;
//----------
wire signed [15:0] cmp_in [0:7];
wire signed [15:0] cmp_out [0:7];

assign dout = (temp)?cmp_out[0]:DATA_MIN;//output;
assign cmp_in[0] = (!direction)?din:cmp_out[1];
assign cmp_in[7] = (!direction)?cmp_out[6]:DATA_MIN;

generate
    genvar i;
    for (i=1;i<7;i=i+1) begin : cmp_inout
        assign cmp_in[i] = (!direction)?cmp_out[i-1]:cmp_out[i+1];
    end
endgenerate

generate
    genvar j;
    for (j=0;j<8;j=j+1) begin : cmp_instance
        cmp u_cmp(
            .clk(clk),
            .rst_n(rst_n),
            .in_vld(cmp_en),
            .direction(direction),
            .din(cmp_in[j]),
            .dout(cmp_out[j])
        );
    end
endgenerate

endmodule