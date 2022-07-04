module DPRAM #(
    parameter WIDTH = 32,
    parameter DEPTH = 16,
    parameter ADDR = 4
)
(
    input wrclk,
    input rdclk,
    input wr_en,
    input rd_en,
    input  [ADDR-1:0] wr_addr,
    input  [ADDR-1:0] rd_addr,
    input  [WIDTH-1:0] wr_data,
    output reg [WIDTH-1:0] rd_data
);

reg [WIDTH-1:0] dpram[0:DEPTH-1];

always @(posedge wrclk) begin
    if (wr_en) begin
        dpram[wr_addr] <= wr_data;
    end
end

always @(posedge rdclk) begin
    if (rd_en) begin
        rd_data <= dpram[rd_addr];
    end
end

endmodule