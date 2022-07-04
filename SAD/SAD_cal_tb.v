`timescale 1ns/1ns
module SAD_cal_tb();
reg rst_n;
reg clk;
reg [2047:0] din;
reg [2047:0] refi;
reg cal_en;
wire [15:0] sad;
wire sad_val;

SAD_cal u_SAD_cal(.rst_n(rst_n),.clk(clk),.din(din),.refi(refi),.cal_en(cal_en),.sad(sad),.sad_val(sad_val));

initial clk = 0;
always #5 clk = ~clk;

reg [2047:0] din_test;
reg [2047:0] refi_test;
reg [7:0] sub_test[0:255];
reg [15:0] sad_test;
reg [15:0] sad_test_0;
reg error_flag;
reg[8:0] m;
reg[11:0] n;
reg [7:0] rander;

initial begin
    rst_n = 0;
    error_flag = 0;
    sad_test = 16'b0;
    sad_test_0 = 16'b0;
    #10
    rst_n = 1;
    cal_en = 1;
    for (m = 0;m <= 255;m = m+1) begin
        n = 8*m;
        rander = {$random}%256;
        din[n+:8] = rander;
        din_test = din;
        rander = {$random}%256;
        refi[n+:8] = rander;
        refi_test = refi;
        if (din_test[n+:8] >= refi_test[n+:8]) begin
            sub_test[m] = din_test[n+:8] - refi_test[n+:8];
        end
        else begin
            sub_test[m] = refi_test[n+:8] - din_test[n+:8];
        end
        sad_test = sad_test + {8'b0,sub_test[m]};
    end
    wait(sad_val == 1) begin
        if (sad == sad_test) begin
            error_flag = 0;
        end
        else begin
            error_flag = 1;
        end
    end
    #10
    #10
    for (m = 0;m <= 255;m = m+1) begin
        n = 8*m;
        rander = {$random}%256;
        din[n+:8] = rander;
        din_test = din;
        rander = {$random}%256;
        refi[n+:8] = rander;
        refi_test = refi;
        if (din_test[n+:8] >= refi_test[n+:8]) begin
            sub_test[m] = din_test[n+:8] - refi_test[n+:8];
        end
        else begin
            sub_test[m] = refi_test[n+:8] - din_test[n+:8];
        end
        sad_test_0 = sad_test_0 + {8'b0,sub_test[m]};
    end
    wait(sad_val == 1) begin
        if (sad == sad_test_0) begin
            error_flag = 0;
        end
        else begin
            error_flag = 1;
        end
    end
    #1000
    $finish;
end

`ifdef USE_VERDI_SIM
initial begin
    $fsdbDumpfile("SAD_cal_tb.fsdb");
    $fsdbDumpvars;
    end
`endif


endmodule