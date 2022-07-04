`timescale 1ns/1ns

module mat_trans_tb();

reg clk;
reg rstn;
reg in_req;
reg in_vld;
reg out_ack;
reg [31:0] in_data;
wire in_ack;
wire out_req;
wire out_vld;
wire [31:0] out_data;

//instance mat_trans;
mat_trans u_mat_trans (
    .clk(clk),
    .rstn(rstn),
    .in_req(in_req),
    .in_vld(in_vld),
    .out_ack(out_ack),
    .in_data(in_data),
    .in_ack(in_ack),
    .out_req(out_req),
    .out_vld(out_vld),
    .out_data(out_data)
);

//generate clock;
initial begin
    clk = 0;
end
always #5 clk = ~clk;

reg [6:0] i;
reg [4:0] j;
reg [31:0] mat[0:63];
reg [31:0] mat_t[0:63];
reg [31:0] data_f;          //standard output;
reg flag;                   //error flag;

//generate mat;
initial begin
    for (i=0;i<64;i=i+1) begin
        mat[i] = {$random}%100;
    end
    for (i=0;i<8;i=i+1) begin
        for (j=0;j<8;j=j+1) begin
            mat_t[i*8+j] = mat[i+j*8];
        end
    end
end

//timing input;
initial begin
    rstn = 1'b0;
    flag = 1'b0;
    #5;
    rstn = 1'b1;
    in_req = 1'b0;
    in_vld = 1'b0;
    out_ack = 1'b0;
    #10;
    in_req = 1'b1;
    in_vld = 1'b1;
    for (i=0;i<64;i=i+1) begin
        in_data <= mat[i];
        #10;
    end
    #20;
    out_ack = 1'b1;
    in_vld = 1'b0;
    #40;
    out_ack = 1'b0;
    for (i=0;i<64;i=i+1) begin
        #10;
        data_f = mat_t[i];
        flag = (data_f==out_data) ? 1'b0:1'b1;  
    end
    #50;
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("mat_trans_tb.fsdb");
    $fsdbDumpvars;
    end
`endif

endmodule