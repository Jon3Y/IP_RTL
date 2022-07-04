module SAD_cal(rstn,clk,din,refi,cal_en,sad,sad_val);
input rstn;
input clk;
input [2047:0] din;
input [2047:0] refi;
input cal_en;
output [15:0] sad;
output sad_val;

//get value;
reg [7:0] din_0[0:15][0:15];
reg [7:0] refi_0[0:15][0:15];
generate
    genvar i,j;
    for (i = 0;i <= 15;i = i+1) begin : getval_row
        for (j = 0;j <= 15;j = j+1) begin : getval_col
            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    din_0[i][j] <= 8'b0;
                    refi_0[i][j] <= 8'b0;
                end
                else if (cal_en) begin
                    din_0[i][j] <= din[(128*i+8*j)+:8];
                    refi_0[i][j] <= refi[(128*i+8*j)+:8]; 
                end
            end
        end    
    end
endgenerate

//sub_abs;
reg [7:0] abs[0:15][0:15];
generate
    genvar i_0,j_0;
    for (i_0 = 0;i_0 <= 15;i_0 = i_0+1) begin : sub_abs_row
        for (j_0 = 0;j_0 <= 15;j_0 = j_0+1) begin : sub_abs_col
            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    abs[i_0][j_0] <= 8'b0;
                end
                else if (din_0[i_0][j_0] >= refi_0[i_0][j_0]) begin
                    abs[i_0][j_0] <= din_0[i_0][j_0] - refi_0[i_0][j_0]; 
                end
                else begin
                    abs[i_0][j_0] <= refi_0[i_0][j_0] -din_0[i_0][j_0];
                end
            end        
        end
    end
endgenerate

//16x16->16x4;
reg [9:0] acc_16x4[0:15][0:3];
generate
    genvar i_1,j_1;
    for (i_1 = 0;i_1 <= 15;i_1 = i_1+1) begin : acc_0_row
        for (j_1 = 0;j_1 <= 3;j_1 = j_1+1) begin : acc_0_col
            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    acc_16x4[i_1][j_1] <= 10'b0;
                end
                else begin
                    acc_16x4[i_1][j_1] <= ({2'b0,abs[i_1][j_1]} + {2'b0,abs[i_1][j_1+4]}) + ({2'b0,abs[i_1][j_1+8]} + {2'b0,abs[i_1][j_1+12]}); 
                end
            end        
        end
    end
endgenerate

//16x4->4x4;
reg [11:0] acc_4x4[0:3][0:3];
generate
    genvar i_2,j_2;
    for (i_2 = 0;i_2 <= 3;i_2 = i_2+1) begin : acc_1_row
        for (j_2 = 0;j_2 <= 3;j_2 = j_2+1) begin : acc_1_col
            always @(posedge clk or negedge rstn) begin
                if(!rstn) begin
                    acc_4x4[i_2][j_2] <= 12'b0;
                end
                else begin
                    acc_4x4[i_2][j_2] <= ({2'b0,acc_16x4[i_2][j_2]} + {2'b0,acc_16x4[i_2+4][j_2]}) + ({2'b0,acc_16x4[i_2+8][j_2]} + {2'b0,acc_16x4[i_2+12][j_2]}); 
                end
            end        
        end
    end
endgenerate

//4x4->4x1;
reg [13:0] acc_4x1[0:3];
generate
    genvar i_3;
    for (i_3 = 0;i_3 <= 3;i_3 = i_3+1) begin : acc_2
        always @(posedge clk or negedge rstn) begin
            if(!rstn) begin
                acc_4x1[i_3] <= 14'b0;
            end
            else begin
                acc_4x1[i_3] <= ({2'b0,acc_4x4[i_3][0]} + {2'b0,acc_4x4[i_3][1]}) + ({2'b0,acc_4x4[i_3][2]} + {2'b0,acc_4x4[i_3][3]}); 
            end
        end        
    end
endgenerate

//4x1->acc;
reg [15:0] acc;
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        acc <= 16'b0;
    end
    else begin
        acc <= ({2'b0,acc_4x1[0]} + {2'b0,acc_4x1[1]}) + ({2'b0,acc_4x1[2]} + {2'b0,acc_4x1[3]});
    end
end
assign sad = (sad_val)?acc:16'b0;

//sad_val signal;
reg [4:0] sad_val_d;
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        sad_val_d <= 5'b0;
    end
    else if(cal_en) begin
        sad_val_d[4:0] <= {sad_val_d[3:0],1'b1};
    end
    else begin
        sad_val_d[4:0] <= sad_val_d[4:0] << 1;
    end
end
assign sad_val = sad_val_d[4];

endmodule