module fixed_arbt(clk,rst_n,req0,req1,req2,req3,gnt0,gnt1,gnt2,gnt3);
input clk;
input rst_n;
input req0;
input req1;
input req2;
input req3;
output reg gnt0;//寄存器型输出；
output reg gnt1;
output reg gnt2;
output reg gnt3;

wire arbt_time;
reg arbt_time_d;
reg [1:0] gnt_id_w;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        arbt_time_d <= 1'b0;
    end
    else begin
        arbt_time_d <= arbt_time;
    end
end
assign arbt_time = (!arbt_time_d)&&(req0|req1|req2|req3);//每两个周期接受一次响应；

always @(*) begin
    if (req0) begin
        gnt_id_w = 2'b00;
    end
    else if (req1) begin
        gnt_id_w = 2'b01;
    end
    else if (req2) begin
        gnt_id_w = 2'b10;
    end
    else begin
        gnt_id_w = 2'b11;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gnt0 <= 1'b0;
        gnt1 <= 1'b0;
        gnt2 <= 1'b0;
        gnt3 <= 1'b0;
    end
    else if (arbt_time) begin
        case (gnt_id_w)
            2'b00: gnt0 <= 1'b1;
            2'b01: gnt1 <= 1'b1;
            2'b10: gnt2 <= 1'b1;
            2'b11: gnt3 <= 1'b1;
        endcase
    end
    else if (arbt_time_d) begin
        gnt0 <= 1'b0;
        gnt1 <= 1'b0;
        gnt2 <= 1'b0;
        gnt3 <= 1'b0;
    end
end

endmodule