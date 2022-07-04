module sync_fifo(clk,rstn,push,pop,din,dout,full,empty);

parameter DATA_WIDTH = 32;
parameter FIFO_DEPTH = 8;

input clk;
input rstn;
input push;
input pop;
input [DATA_WIDTH-1:0] din;
output tri [DATA_WIDTH-1:0] dout;
output full;
output empty;

reg [DATA_WIDTH-1:0] fifo_buf [0:FIFO_DEPTH-1];//定义sync FIFO；

//fifo判空判满计数；
reg [7:0] fifo_cnt;
wire full_t;
wire empty_t;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        fifo_cnt <= 8'b0;
    end
    else if (push&&(!pop)) begin
        fifo_cnt <= fifo_cnt + 1'b1;
    end
    else if ((!push)&&pop) begin
        fifo_cnt <= fifo_cnt - 1'b1;
    end
end
assign full_t = (fifo_cnt == FIFO_DEPTH)? 1:0;
assign full = full_t;
assign empty_t = (fifo_cnt == 0)? 1:0;
assign empty = empty_t;

//写控制；
reg [7:0] push_ptr;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        push_ptr <= 8'b0;
    end
    else if (push&&(!full)) begin
        if (push_ptr == (FIFO_DEPTH-1)) begin
            push_ptr <= 8'b0;
        end
        else begin
            push_ptr <= push_ptr + 1'b1;
        end
    end    
end

//读控制；
reg [7:0] pop_ptr;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        pop_ptr <= 8'b0;
    end
    else if (push&&(!full)) begin
        if (pop_ptr == (FIFO_DEPTH-1)) begin
            pop_ptr <= 8'b0;
        end
        else begin
            pop_ptr <= pop_ptr + 1'b1;
        end
    end    
end

//读写；
always @(posedge clk) begin
    if (push&&(!full_t)) begin
        fifo_buf[push_ptr] <= din;
    end
end
assign dout = (pop&&(!empty_t)) ? fifo_buf[pop_ptr] : 'bz;

endmodule