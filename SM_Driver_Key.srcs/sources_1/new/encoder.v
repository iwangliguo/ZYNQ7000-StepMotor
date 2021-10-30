`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/02 23:15:34
// Design Name: 
// Module Name: encoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// https://www.stepfpga.com/doc/%E6%97%8B%E8%BD%AC%E7%BC%96%E7%A0%81%E5%99%A8%E6%A8%A1%E5%9D%97
//////////////////////////////////////////////////////////////////////////////////


module     encoder     (
                       input clk,
                       input rst_n,
//                       input a_in,
//                       input b_in,
//                       input z_in,
                       output dir,
                       output zero,
                       output [15:0] cnt,
                       output [15:0] bcd_data,
                       output pulse
                       );
                       
                    
reg dir;
reg [15:0] cnt;  
reg [15:0] bcd_data;                    
                  
reg a_in ;
reg b_in ;
reg z_in ; 
reg l1_a_in;
reg l2_a_in;
reg l1_b_in;
reg l2_b_in;
reg l1_z_in;
reg l2_z_in;

wire a_sig;
wire b_sig;
wire z_sig;

reg  l1_a_sig;
reg  l2_a_sig;

reg  a_pos;
reg  a_neg;

reg tran_en;
wire [15:0] data;
wire  tran_done;
wire [15:0] cnt_out;

//虚假encoder信号
localparam				NUM_50MS	=	25'd250_0000;
reg				[31:0]	fake_encoder_cnt;
//计数器周期为500ms
always@(posedge clk or negedge rst_n) begin
   
	if(!rst_n) fake_encoder_cnt <= 0;
	else if(fake_encoder_cnt <= NUM_50MS/4-1) 
	begin
	 a_in <= 1'b1;
	 b_in <= 1'b1;
	 fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
	end
	else if(fake_encoder_cnt <= NUM_50MS/2-1) 
    begin
     a_in <= 1'b0;
     b_in <= b_in;
     fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
    end
    else if(fake_encoder_cnt <= 3*NUM_50MS/4-1) 
    begin
     a_in <= a_in;
     b_in <= 1'b0;
     fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
    end
    else if(fake_encoder_cnt <= NUM_50MS-1) 
    begin
     a_in <= 1'b1;
     b_in <= b_in;
     fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
    end
	else fake_encoder_cnt <= 1'b0;
	//else fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
end

assign a_sig = l2_a_in & l1_a_in & a_in;
assign b_sig = l2_b_in & l1_b_in & b_in;
//assign z_sig = l2_z_in & l1_z_in & z_in;
assign z_sig = 1'b0;

assign zero = z_sig;
assign pulse = tran_en;

assign cnt_out = (cnt >= 16'd5000) ? cnt-16'd5000 : 16'd5000-cnt;


always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0)
    begin
        l1_a_in <= 1'b0;
        l2_a_in <= 1'b0;
        
        l1_b_in <= 1'b0;
        l2_b_in <= 1'b0;
        
        l1_z_in <= 1'b0;
        l2_z_in <= 1'b0;    
    end
else
    begin
        l1_a_in <= a_in;
        l2_a_in <= l1_a_in;
        
        l1_b_in <= b_in;
        l2_b_in <= l1_b_in;
        
        l1_z_in <= z_in;
        l2_z_in <= l1_z_in;        
    end
end    



always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0)
    begin
        l1_a_sig <= 1'b0;
        l2_a_sig <= 1'b0;
    end
    else
    begin
        l1_a_sig <= a_sig;
        l2_a_sig <= l1_a_sig;    
    end
end

always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0)
    begin
        a_pos <= 1'b0;
        a_neg <= 1'b0;        
    end
    else
    begin
        if(l1_a_sig == 1'b0 && a_sig == 1'b1)
            a_pos <= 1'b1;
        else
            a_pos <= 1'b0;
            
        if(l1_a_sig == 1'b1 && a_sig == 1'b0)
            a_neg <= 1'b1;
        else
            a_neg <= 1'b0;                           
    end
end


always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0)
    begin
        cnt <= 16'd5000;
        dir <= 1'b0;
        tran_en <= 1'b0;
    end
    else
    begin
//        if(z_sig == 1'b1)
//        begin
//            cnt <= 16'd1000;
//            dir <= dir;
//            tran_en <= 1'b0;
//        end
//        else if((b_sig == 1'b0 && a_pos == 1'b1) || (b_sig == 1'b1 && a_neg == 1'b1))
//        begin
//            cnt <= cnt + 1'b1;
//            dir <= 1'b1;
//            tran_en <= 1'b1;
//        end
//        else if((b_sig == 1'b1 && a_pos == 1'b1) || (b_sig == 1'b0 && a_neg == 1'b1))
//        begin
//            cnt <= cnt - 1'b1;
//            dir <= 1'b0;
//            tran_en <= 1'b1;
//        end
//        else
//        begin
//            cnt <= cnt;
//            dir <= dir;
//            tran_en <= 1'b0;
//        end    

        if(a_pos == 1'b1 && z_sig == 1'b1)
        begin
            cnt <= 16'd5000;
            dir <= dir;
            tran_en <= 1'b0;
        end
        else if( a_pos == 1'b1 && b_sig == 1'b0)
        begin
            cnt <= cnt + 1'b1;
            dir <= 1'b1;
            tran_en <= 1'b1;
        end
        else if( a_pos == 1'b1 && b_sig == 1'b1)
        begin
            cnt <= cnt - 1'b1;
            dir <= 1'b0;
            tran_en <= 1'b1;
        end
        else
        begin
            cnt <= cnt;
            dir <= dir;
            tran_en <= 1'b0;
        end          
    end
end



bin_bcd   u1    (
                 .clk(clk),
                 .rst_n(rst_n),
                 .tran_en(tran_en),
                 .data_in(cnt_out),
                 .tran_done(tran_done),
                 .thou_data(data[15:12]),      //千位
                 .hund_data(data[11:8]),      //百位
                 .tens_data(data[7:4]),      //十位
                 .unit_data(data[3:0])       //个位 
                 );
                 
always @(posedge clk or negedge rst_n)
begin
    if(rst_n == 0)
    begin
        bcd_data = 16'h0000;
    end
    else
    begin
        if(tran_done == 1'b1)
            bcd_data = data;
        else
            bcd_data = bcd_data;
    end
end



endmodule
