/*--------64*32bit sram--------*/
module spram (
    input clk,
    input cs,
    input we,
    input wire [31:0] din,
    input wire [5:0] addr,
    output reg [31:0] dout
);

reg [31:0] mem[0:63];

always @(posedge clk) begin
    if (cs) begin
        if (we) begin
            mem[addr] <= din;
        end
        else begin
            dout <= mem[addr];
        end
    end
end

endmodule