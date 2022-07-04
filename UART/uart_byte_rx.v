module uart_byte_rx(
    clk,
    rstn,

    uart_rx,
    baud_set,

    data_byte,
    rx_done
);

input wire clk;
input wire rstn;
input wire uart_rx;
input wire [2:0] baud_set;
output reg [7:0] data_byte;
output reg rx_done;

reg [2:0] START_BIT;
reg [2:0] STOP_BIT;
reg [7:0] bps_cnt;

//one bit CDC;
reg uart_rx_sync0;
reg uart_rx_sync1;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        uart_rx_sync0 <= 1'b0;
        uart_rx_sync1 <= 1'b0;
    end
    else begin
        uart_rx_sync0 <= uart_rx;
        uart_rx_sync1 <= uart_rx_sync0;
    end
end

//edge detect;
reg uart_rx_sync1_dly0;
reg uart_rx_sync1_dly1;
wire uart_rx_sync1_dly1_negedge;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        uart_rx_sync1_dly0 <= 1'b0;
        uart_rx_sync1_dly1 <= 1'b0;
    end
    else begin
        uart_rx_sync1_dly0 <= uart_rx_sync1;
        uart_rx_sync1_dly1 <= uart_rx_sync1_dly0;
    end
end

assign uart_rx_sync1_dly1_negedge = (!uart_rx_sync1_dly0) & uart_rx_sync1_dly1;

//uart_state;
reg uart_state;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        uart_state <= 1'b0;
    end
    else if (uart_rx_sync1_dly1_negedge) begin
        uart_state <= 1'b1;
    end
    else if (rx_done || ((bps_cnt == 8'd12) && (START_BIT > 2)) || ((bps_cnt == 8'd155) && (STOP_BIT < 3))) begin
        uart_state <= 1'b0;
    end
    else begin
        uart_state <= uart_state;
    end
end

//bps_dr gen;
reg [15:0] bps_dr;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bps_dr <= 16'd0;
    end
    else begin
        case (baud_set) 
            3'd0:       bps_dr <= 16'd324;
            3'd1:       bps_dr <= 16'd162;
            3'd2:       bps_dr <= 16'd80;
            3'd3:       bps_dr <= 16'd53;
            3'd4:       bps_dr <= 16'd26;
            default:    bps_dr <= 16'd324;
        endcase
    end
end

//bps_clk gen;
reg [15:0] div_cnt;
reg bps_clk;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        div_cnt <= 16'd0;
    end
    else if (uart_state) begin
        if (div_cnt == bps_dr) begin
            div_cnt <= 16'd0;
        end
        else begin
            div_cnt <= div_cnt + 1'b1;
        end
    end
    else begin
        div_cnt <= 16'b0;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bps_clk <= 1'b0;
    end
    else if (div_cnt == 16'd1) begin
        bps_clk <= 1'b1;
    end
    else begin
        bps_clk <= 1'b0;
    end
end

//bps_cnt gen;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        bps_cnt <= 8'd0;
    end
    else if ((bps_cnt == 8'd155) || ((bps_cnt == 8'd12) && (START_BIT > 2))) begin
        bps_cnt <= 8'd0;
    end
    else if (bps_clk) begin
        bps_cnt <= bps_cnt + 1'b1;
    end
    else begin
        bps_cnt <= bps_cnt;
    end
end

//rx_done;
always @(posedge clk  or negedge rstn) begin
    if (!rstn) begin
        rx_done <= 1'b0;
    end
    else if (bps_cnt == 8'd155) begin
        rx_done <= 1'b1;
    end
    else begin
        rx_done <= 1'b0;
    end
end

//data_byte_pre;
reg [2:0] data_byte_pre[0:7];
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        START_BIT <= 3'd0;
        data_byte_pre[0] <= 3'd0;
        data_byte_pre[1] <= 3'd0;
        data_byte_pre[2] <= 3'd0;
        data_byte_pre[3] <= 3'd0;
        data_byte_pre[4] <= 3'd0;
        data_byte_pre[5] <= 3'd0;
        data_byte_pre[6] <= 3'd0;
        data_byte_pre[7] <= 3'd0;
        STOP_BIT <= 3'd0;
    end
    else if (bps_clk) begin
        case (bps_cnt) 
            0:  begin
                START_BIT <= 3'd0;
                data_byte_pre[0] <= 3'd0;
                data_byte_pre[1] <= 3'd0;
                data_byte_pre[2] <= 3'd0;
                data_byte_pre[3] <= 3'd0;
                data_byte_pre[4] <= 3'd0;
                data_byte_pre[5] <= 3'd0;
                data_byte_pre[6] <= 3'd0;
                data_byte_pre[7] <= 3'd0;
                STOP_BIT <= 3'd0;
            end
            6,7,8,9,10,11:  begin
                START_BIT <= START_BIT + uart_rx_sync1_dly1;
            end
            22,23,24,25,26,27:  begin
                data_byte_pre[0] <= data_byte_pre[0] + uart_rx_sync1_dly1;
            end
            38,39,40,41,42,43:  begin
                data_byte_pre[1] <= data_byte_pre[1] + uart_rx_sync1_dly1;
            end
            54,55,56,57,58,59:  begin
                data_byte_pre[2] <= data_byte_pre[2] + uart_rx_sync1_dly1;
            end
            70,71,72,73,74,75:  begin
                data_byte_pre[3] <= data_byte_pre[3] + uart_rx_sync1_dly1;
            end
            86,87,88,89,90,91:  begin
                data_byte_pre[4] <= data_byte_pre[4] + uart_rx_sync1_dly1;
            end
            102,103,104,105,106,107:  begin
                data_byte_pre[5] <= data_byte_pre[5] + uart_rx_sync1_dly1;
            end
            118,119,120,121,122,123:  begin
                data_byte_pre[6] <= data_byte_pre[6] + uart_rx_sync1_dly1;
            end
            134,135,136,137,138,139:  begin
                data_byte_pre[7] <= data_byte_pre[7] + uart_rx_sync1_dly1;
            end
            150,151,152,153,154,155:  begin
                STOP_BIT <= STOP_BIT + uart_rx_sync1_dly1;
            end
            default:    begin
                START_BIT <= START_BIT;
                data_byte_pre[0] <= data_byte_pre[0];
                data_byte_pre[1] <= data_byte_pre[1];
                data_byte_pre[2] <= data_byte_pre[2];
                data_byte_pre[3] <= data_byte_pre[3];
                data_byte_pre[4] <= data_byte_pre[4];
                data_byte_pre[5] <= data_byte_pre[5];
                data_byte_pre[6] <= data_byte_pre[6];
                data_byte_pre[7] <= data_byte_pre[7];
                STOP_BIT <= STOP_BIT;
            end
        endcase
    end       
end

//data_byte;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        data_byte <= 8'b0;
    end
    else if (bps_cnt == 8'd155) begin
        data_byte[0] <= data_byte_pre[0][2];
        data_byte[1] <= data_byte_pre[1][2];
        data_byte[2] <= data_byte_pre[2][2];
        data_byte[3] <= data_byte_pre[3][2];
        data_byte[4] <= data_byte_pre[4][2];
        data_byte[5] <= data_byte_pre[5][2];
        data_byte[6] <= data_byte_pre[6][2];
        data_byte[7] <= data_byte_pre[7][2];
    end   
end

endmodule
