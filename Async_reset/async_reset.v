//Asynchronous reset, synchronous recovery;

module async_reset(
    input rstn_async,
    input clk,
    output reg rstn
);

reg q1;

always @(posedge clk or negedge rstn_async) begin
    if (!rstn_async) begin
        q1 <= 1'b0;
    end
    else begin
        q1 <= 1'b1;
    end
end

always @(posedge clk or negedge rstn_async) begin
    if (!rstn_async) begin
        rstn <= 1'b0;
    end
    else begin
        rstn <= q1;
    end
end

endmodule