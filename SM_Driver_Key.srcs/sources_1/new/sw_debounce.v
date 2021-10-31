`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/31 09:59:42
// Design Name: 
// Module Name: sw_debounce
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
module sw_debounce(
    		clk,rst_n,
			sw1_n,sw2_n,sw3_n,
	   		sw_out
    		);
 
input   clk;	//主时钟信号
input   rst_n;	//复位信号，低有效
input   sw1_n,sw2_n,sw3_n; 	//三个独立按键，低表示按下
output  [2:0] sw_out;
 
//---------------------------------------------------------------------------
reg key_rst;  
 
always @(posedge clk  or negedge rst_n)
    if (!rst_n) key_rst <= 1'b1;
    else key_rst <= sw3_n&sw2_n&sw1_n;
 
reg key_rst_r;       //每个时钟周期的上升沿将low_sw信号锁存到low_sw_r中
 
always @ ( posedge clk  or negedge rst_n )
    if (!rst_n) key_rst_r <= 1'b1;
    else key_rst_r <= key_rst;
   
//当寄存器key_rst由1变为0时，led_an的值变为高，维持一个时钟周期 
wire key_an = key_rst_r & (~key_rst);
/*
key_rst     1 1 1 0 0 1
~key_rst    0 0 0 1 1 0
key_rst_r     1 1 1 0 0 1
key_an        0 0 1 0 0
*/
//---------------------------------------------------------------------------
reg[19:0]  cnt;	//计数寄存器
 
always @ (posedge clk  or negedge rst_n)
    if (!rst_n) cnt <= 20'd0;	//异步复位
	else if(key_an) cnt <=20'd0;
    else cnt <= cnt + 1'b1;
  
reg[2:0] low_sw;
 
always @(posedge clk  or negedge rst_n)
    if (!rst_n) low_sw <= 3'b111;
    else if (cnt == 20'hB71B0) 	//50mhz ,满15ms，将按键值锁存到寄存器low_sw中
      low_sw <= {sw3_n,sw2_n,sw1_n};
      
assign sw_out = low_sw;


endmodule
