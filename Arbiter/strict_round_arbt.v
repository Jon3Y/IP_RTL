module strict_round_arbt(clk,rst_n,req0,req1,req2,req3,gnt0,gnt1,gnt2,gnt3);
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
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        arbt_time_d <= 1'b0;
    end
    else begin
        arbt_time_d <= arbt_time;
    end
end
assign arbt_time = (!arbt_time_d)&&(req0|req1|req2|req3);

reg [7:0] cur_pri;
reg [3:0] req_t;
generate
    genvar i;
    for(i=0;i<=3;i=i+1) begin : req2req_t
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                req_t[i] <= 1'b0;
            end
            else begin
                case(cur_pri[(7-2*i)-:2])
                    2'b00: req_t[i] <= req0;
                    2'b01: req_t[i] <= req1;
                    2'b10: req_t[i] <= req2;
                    2'b11: req_t[i] <= req3;
                endcase
            end
        end
    end
endgenerate

reg [1:0] gnt_id_w;
always @(*) begin
    if (req_t[0]) begin
        gnt_id_w = 2'b00;
    end
    else if (req_t[1]) begin
        gnt_id_w = 2'b01;
    end
    else if (req_t[2]) begin
        gnt_id_w = 2'b10;
    end
    else begin
        gnt_id_w = 2'b11;
    end
end

//反推cur_pri中第几位触发了；
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cur_pri <= 8'b00_01_10_11;
    end
    else if (arbt_time_d) begin
        case (gnt_id_w)
            2'b00: cur_pri[7:0] <= {cur_pri[5:0],cur_pri[7:6]};
            2'b01: cur_pri[7:0] <= {cur_pri[7:6],cur_pri[3:0],cur_pri[5:4]};
            2'b10: cur_pri[7:0] <= {cur_pri[7:4],cur_pri[1:0],cur_pri[3:2]};
            2'b11: cur_pri[7:0] <= {cur_pri[7:2],cur_pri[1:0]};
        endcase
    end
end

reg [3:0] gnt_t;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        gnt_t <= 4'b0;
    end
    else if (arbt_time) begin
        case (gnt_id_w)
            2'b00: gnt_t[0] <= 1'b1;
            2'b01: gnt_t[1] <= 1'b1;
            2'b10: gnt_t[2] <= 1'b1;
            2'b11: gnt_t[3] <= 1'b1;
        endcase
    end
    else if (arbt_time_d) begin
        gnt_t <= 4'b0;
    end
end

generate
    genvar i;
    for(i=0;i<=3;i=i+1) begin : gnt_t2gnt
        always @(posedge clk or negedge rst_n) begin
            if (!rst_n) begin
                gnt_t[i] <= 1'b0;
            end
            else begin
                case(cur_pri[(7-2*i)-:2])
                    2'b00: gnt0 <= gnt_t[i];
                    2'b01: gnt1 <= gnt_t[i];
                    2'b10: gnt2 <= gnt_t[i];
                    2'b11: gnt3 <= gnt_t[i];
                endcase
            end
        end
    end
endgenerate

endmodule