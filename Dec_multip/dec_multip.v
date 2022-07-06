module dec_multip(
    clk,
    rstn,

    din_a,
    din_b,
    din_c,
    din_vld,

    dout_y,
    dout_vld
);

parameter A = 130;          //0.511*256;
parameter B = -118;         //-0.464*256;
parameter C = -12;          //-0.047*256;
parameter D = 128;          //128;

input wire clk;
input wire rstn;
input wire din_vld;
input wire [7:0] din_a;
input wire [7:0] din_b;
input wire [7:0] din_c;
output wire [7:0] dout_y;
output wire dout_vld;

reg signed [17:0] temp0;
reg signed [17:0] temp1;
reg signed [17:0] temp2;
reg signed [9:0] temp3;
reg [8:0] dout_y_pre;
reg [1:0] dout_vld_r;

//cal 0.511*a, 0.464*b, 0.047*c;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        temp0 <= 18'd0;
        temp1 <= 18'd0;
        temp2 <= 18'd0;
    end
    else if (din_vld) begin
        temp0 <= A*din_a;
        temp1 <= B*din_b;
        temp2 <= C*din_c;
    end
    else begin
        temp0 <= temp0;
        temp1 <= temp1;
        temp2 <= temp2;
    end
end

//cal 0.511*a-0.464*b-0.047*c+128;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        temp3 <= 10'd0;
    end
    else begin
        temp3 <= ((temp0 + temp1 + temp2)/256) + D;
    end    
end

//output vld;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        dout_vld_r <= 2'd0;
    end
    else begin
        dout_vld_r <= {dout_vld_r[0],din_vld};
    end
end

//cal y;
always @(*) begin
    if (temp3[9]) begin
        dout_y_pre = (~temp3[8:0]) + 1'b1;
    end
    else if ((!temp3[9]) && (temp3[8:0] >= 9'd255)) begin
        dout_y_pre = 9'd255;
    end
    else begin
        dout_y_pre = temp3[8:0];
    end
end

//output;
assign dout_vld = dout_vld_r[1];
assign dout_y = dout_vld ? dout_y_pre[7:0] : 8'd0;
    
endmodule