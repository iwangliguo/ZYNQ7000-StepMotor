`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/02/04 13:27:41
// Design Name: 
// Module Name: step
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
// 
//////////////////////////////////////////////////////////////////////////////////


module       step_motor     (
                             clk,
							 rst_n,
							 //input,
							 pul_in,
							 ena_in,
							 dir_in,
							 //output
							 pul,
							 ena,
							 dir
							 );
							 
parameter	CLK_CNT	  =  16'd500;  //50M/100K=500;
						 
input                 clk;
input                 rst_n;
//input
input                 pul_in;
input                 ena_in;
input                 dir_in;
//output
output                ena;
output                dir;
output                pul;

reg     [15:0]       cnt;
reg                  cnt_en;

assign pul = cnt_en;
assign dir = dir_in;
assign ena = ena_in;

always @(posedge clk or negedge rst_n)
begin
	if(rst_n == 0)
	begin
		cnt <= 16'd0;
		cnt_en <= 1'b0;
	end
	else
	begin
	   if(pul_in == 1'b1)
	       cnt_en <= 1'b1;
	   else if(cnt >= CLK_CNT)
	       cnt_en <= 1'b0;
	   else
	       cnt_en <= cnt_en;
	       
	   if(cnt_en == 1'b1)
	       cnt <= cnt + 1'b1;
	   else
	       cnt <= 16'd0;
	end
end


endmodule
