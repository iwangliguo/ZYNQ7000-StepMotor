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
 
input   clk;	//��ʱ���ź�
input   rst_n;	//��λ�źţ�����Ч
input   sw1_n,sw2_n,sw3_n; 	//���������������ͱ�ʾ����
output  [2:0] sw_out;
 
//---------------------------------------------------------------------------
reg key_rst;  
 
always @(posedge clk  or negedge rst_n)
    if (!rst_n) key_rst <= 1'b1;
    else key_rst <= sw3_n&sw2_n&sw1_n;
 
reg key_rst_r;       //ÿ��ʱ�����ڵ������ؽ�low_sw�ź����浽low_sw_r��
 
always @ ( posedge clk  or negedge rst_n )
    if (!rst_n) key_rst_r <= 1'b1;
    else key_rst_r <= key_rst;
   
//���Ĵ���key_rst��1��Ϊ0ʱ��led_an��ֵ��Ϊ�ߣ�ά��һ��ʱ������ 
wire key_an = key_rst_r & (~key_rst);
/*
key_rst     1 1 1 0 0 1
~key_rst    0 0 0 1 1 0
key_rst_r     1 1 1 0 0 1
key_an        0 0 1 0 0
*/
//---------------------------------------------------------------------------
reg[19:0]  cnt;	//�����Ĵ���
 
always @ (posedge clk  or negedge rst_n)
    if (!rst_n) cnt <= 20'd0;	//�첽��λ
	else if(key_an) cnt <=20'd0;
    else cnt <= cnt + 1'b1;
  
reg[2:0] low_sw;
 
always @(posedge clk  or negedge rst_n)
    if (!rst_n) low_sw <= 3'b111;
    else if (cnt == 20'hB71B0) 	//50mhz ,��15ms��������ֵ���浽�Ĵ���low_sw��
      low_sw <= {sw3_n,sw2_n,sw1_n};
      
assign sw_out = low_sw;


endmodule
