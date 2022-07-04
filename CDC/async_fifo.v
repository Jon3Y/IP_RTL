 module async_fifo #(
    parameter WIDTH = 32,
    parameter PTR = 4
)
(
    input wrclk,
    input wr_rst_n,
    input wr_en,
    input [WIDTH-1:0] wr_data,
    input rdclk,
    input rd_rst_n,
    input rd_en,
    output reg [WIDTH-1:0] rd_data,
    output reg wr_full,
    output reg rd_empty
);

//写时钟域，写指针生成；
reg [PTR:0] wr_ptr;
always @(posedge wrclk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr <= 'b0;
    end
    else if (wr_en && (!wr_full)) begin
        wr_ptr <= wr_ptr + 1'b1;
    end
    else begin
        wr_ptr <= wr_ptr;
    end
end

//写指针转换为格雷码；
reg [PTR:0] wr_ptr_gray;
always @(posedge wrclk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        wr_ptr_gray <= 'b0;
    end
    else begin
        wr_ptr_gray <= {wr_ptr[PTR],(wr_ptr[PTR-1:1]^wr_ptr[PTR-2:0])};
    end
end

//写指针：写时钟域->读时钟域；
reg [PTR:0] wr_ptr_gray_f1;
reg [PTR:0] wr_ptr_gray_f2;
always @(posedge rdclk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        wr_ptr_gray_f1 <= 'b0;
        wr_ptr_gray_f2 <= 'b0;
    end
    else begin
        wr_ptr_gray_f1 <= wr_ptr_gray;
        wr_ptr_gray_f2 <= wr_ptr_gray_f1;
    end
end

//在读时钟域将写指针翻译回二进制；
integer i;
reg [PTR:0] wr_ptr_rd;
always @(*) begin
    wr_ptr_rd[PTR] = wr_ptr_gray_f2[PTR];
    for (i = PTR-1; i >= 0; i = i - 1) begin
        wr_ptr_rd[i] = wr_ptr_rd[i+1]^wr_ptr_gray_f2[i];
    end
end

//读时钟域，读指针生成；
reg [PTR:0] rd_ptr;
always @(posedge rdclk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr <= 'b0;
    end
    else if (rd_en && (!rd_empty)) begin
        rd_ptr <= rd_ptr + 1'b1;
    end
    else begin
        rd_ptr <= rd_ptr;
    end
end

//读指针转换为格雷码；
reg [PTR:0] rd_ptr_gray;
always @(posedge rdclk or negedge rd_rst_n) begin
    if (!rd_rst_n) begin
        rd_ptr_gray <= 'b0;
    end
    else begin
        rd_ptr_gray <= {rd_ptr[PTR],(rd_ptr[PTR-1:1]^rd_ptr[PTR-2:0])};
    end
end

//读指针：读时钟域->写时钟域；
reg [PTR:0] rd_ptr_gray_f1;
reg [PTR:0] rd_ptr_gray_f2;
always @(posedge wrclk or negedge wr_rst_n) begin
    if (!wr_rst_n) begin
        rd_ptr_gray_f1 <= 'b0;
        rd_ptr_gray_f2 <= 'b0;
    end
    else begin
        rd_ptr_gray_f1 <= rd_ptr_gray;
        rd_ptr_gray_f2 <= rd_ptr_gray_f1;
    end
end

//在写时钟域将读指针翻译回二进制；
integer j;
reg [PTR:0] rd_ptr_wr;
always @(*) begin
    rd_ptr_wr[PTR] = rd_ptr_gray_f2[PTR];
    for (j = PTR-1; j >= 0; j = j - 1) begin
        rd_ptr_wr[j] = rd_ptr_wr[j+1]^rd_ptr_gray_f2[j];
    end
end

//在读时钟域产生读空信号；
always @(*) begin
    if (wr_ptr_rd == rd_ptr) begin
        rd_empty = 1'b1;
    end
    else begin
        rd_empty = 1'b0;
    end
end

//在写时钟域产生写满信号；
always @(*) begin
    if ((rd_ptr_wr[PTR-1:0] == wr_ptr[PTR-1:0]) && (rd_ptr_wr[PTR] != wr_ptr[PTR])) begin
        wr_full = 1'b1;
    end
    else begin
        wr_full = 1'b0;
    end
end

wire push;
wire pop;
wire [PTR-1:0] wr_addr;
wire [PTR-1:0] rd_addr;
assign push = (wr_en && !wr_full)?1'b1:1'b0;
assign pop = (rd_en && !rd_empty)?1'b1:1'b0;
assign wr_addr = wr_ptr[PTR-1:0];
assign rd_addr = rd_ptr[PTR-1:0];

//调用双端口ram，实现FIFO；
DPRAM #(
    .WIDTH(32),
    .DEPTH(16),
    .ADDR(4)
)
u_DPRAM
(
    .wrclk(wrclk),
    .rdclk(rdclk),
    .wr_en(push),
    .rd_en(pop),
    .wr_addr(wr_addr),
    .rd_addr(rd_addr),
    .wr_data(wr_data),
    .rd_data(rd_data)
);

endmodule