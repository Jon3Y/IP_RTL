module mat_trans (
    input clk,
    input rstn,
    input in_req,
    input in_vld,
    input out_ack,
    input wire [31:0] in_data,
    output in_ack,
    output reg out_req,
    output reg out_vld,
    output reg [31:0] out_data
);

wire buf_empty;
wire buf_full;
wire in_busy_end;               //input end;
wire mem_rd;                    //buf read enable;
wire [5:0] raddr;               //read addr;
wire [31:0] dout_mux;           //output from mem0 or mem1;
wire mem0_we;                   //mem0 write enable;
wire mem0_rd;                   //mem0 read enable;
wire mem1_we;                   //mem1 write enable;
wire mem1_rd;                   //mem1 read enable;
wire mem0_cs;                   //mem0 cs;
wire mem1_cs;                   //mem1 cs;
wire [5:0] mem0_addr;           //mem0 addr;
wire [5:0] mem1_addr;           //mem1_addr;
wire [31:0] mem0_dout;          //mem0 output;
wire [31:0] mem1_dout;          //mem1 output;
reg [1:0] wptr;                 //write ptr;
reg [1:0] rptr;                 //read ptr;
reg [31:0] mem_in;              //buf input;
reg mem_we;                     //buf write enable;
reg mem_we_d;                   //buf write enable delay;
reg in_busy;                    //input busy;
reg [5:0] waddr;                //write addr;
reg out_busy;                   //output busy;
reg [5:0] rcnt;                 //output counter;
reg mem_rd_d;                   //reg mem_rd;


/*----------------------------input-----------------------------*/
//ping pong buffer empty or full;
assign buf_empty = (wptr==rptr) ? 1'b1:1'b0;
assign buf_full = ((wptr[0]==rptr[0]) && (wptr[1]!=rptr[1])) ? 1'b1:1'b0;

assign in_ack = (!in_busy) & (!buf_full);                                        //input bus free;
assign in_busy_end = (waddr==6'd63) & (mem_we);                                  //input transfer end;

//data input;
always @(posedge clk) begin
    if (in_vld) begin
        mem_in <= in_data;
    end
end

//buffer write enable delay;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_we_d <= 1'b0;
    end
    else if (in_vld) begin
        mem_we_d <= 1'b1;
    end
    else begin
        mem_we_d <= 1'b0;
    end
end

//buffer write enable;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_we <= 1'b0;
    end
    else begin
        mem_we <= mem_we_d;
    end
end

//input bus busy signal;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        in_busy <= 1'b0;
    end
    else if (in_req && in_ack) begin
        in_busy <= 1'b1;
    end
    else if (in_busy_end) begin
        in_busy <= 1'b0;
    end
end

//burst transfer write addr;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        waddr <= 6'b0;
    end
    else if (in_req && in_ack) begin
        waddr <= 6'b0;
    end
    else if (mem_we) begin
        waddr <= waddr + 1'b1;
    end
end

//switch mem input;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wptr <= 1'b0;
    end
    else if (in_busy_end) begin
        wptr <= wptr + 1'b1;
    end
end

/*----------------------------output-----------------------------*/
assign raddr = {rcnt[2:0], rcnt[5:3]};                      //mat trans;   
assign mem_rd = out_busy;                                   //output read enable;
assign dout_mux = (rptr[0]) ? mem1_dout:mem0_dout;          //output mem select;

//output bus busy signal;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        out_busy <= 1'b0;
    end
    else if (out_req && out_ack) begin
        out_busy <= 1'b1;
    end
    else if ((mem_rd) && (rcnt==6'd63)) begin
        out_busy <= 1'b0;
    end
end

//output counter;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rcnt <= 6'b0;
    end
    else if (out_req && out_ack) begin
        rcnt <= 6'b0;
    end
    else if (mem_rd) begin
        rcnt <= rcnt + 1'b1;
    end
end

//output req signal;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        out_req <= 1'b0;
    end
    else if ((!out_req) && (!out_busy) && (!buf_empty) && (!out_vld)) begin
        out_req <= 1'b1;
    end
    else if (out_ack) begin
        out_req <= 1'b0;
    end
end

//mem_rd_d;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        mem_rd_d <= 1'b0;
    end
    else begin
        mem_rd_d <= mem_rd;
    end
end

//output data vld signal;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        out_vld <= 1'b0;
    end
    else begin
        out_vld <= mem_rd_d;
    end
end

//switch mem output;
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rptr <= 1'b0;
    end
    else if ((!mem_rd_d) && (out_vld)) begin
        rptr <= rptr + 1'b1;
    end
end

//data output;
always @(posedge clk) begin
    if (mem_rd_d) begin
        out_data <= dout_mux;
    end
end

/*----------------------------instance mem-----------------------------*/
assign mem0_we = mem_we & (!wptr[0]);
assign mem1_we = mem_we & (wptr[0]);
assign mem0_rd = mem_rd & (!rptr[0]);
assign mem1_rd = mem_rd & (rptr[0]);
assign mem0_cs = mem0_we | mem0_rd;
assign mem1_cs = mem1_we | mem1_rd;
assign mem0_addr = mem0_we ? waddr:raddr;
assign mem1_addr = mem1_we ? waddr:raddr;

//instance mem0;
spram u_apram0 (
    .clk(clk),
    .cs(mem0_cs),
    .we(mem0_we),
    .din(mem_in),
    .addr(mem0_addr),
    .dout(mem0_dout)
);

//instance mem1;
spram u_apram1 (
    .clk(clk),
    .cs(mem1_cs),
    .we(mem1_we),
    .din(mem_in),
    .addr(mem1_addr),
    .dout(mem1_dout)
);

endmodule