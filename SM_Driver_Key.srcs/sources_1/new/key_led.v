//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           beep_control
// Last modified Date:  2019/4/15 11:30:36
// Last Version:        V1.0
// Descriptions:        按键控制LED
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/4/15 11:30:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    正点原子
// Modified date:
// Version:
// Descriptions:
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module key_led(
    input               sys_clk ,
    input               sys_rst_n ,

    input        [1:0]  key ,
    output       reg [1:0]  led
);

//reg define
reg [24:0] cnt;
reg        led_ctrl;
//*****************************************************
//**                    main code
//*****************************************************

//计数器
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < 25'd2500_0000)  //计数500ms
        cnt <= cnt + 1'b1;
    else
        cnt <= 25'd0;
end

//每隔500ms就更改LED的闪烁状态
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led_ctrl <= 1'b0;
    else if(cnt == 25'd2500_0000)
        led_ctrl <= ~led_ctrl;
end

//根据按键的状态以及LED的闪烁状态来赋值LED
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b11;
    else case(key)
        2'b10 :  //如果按键0按下，则两个LED交替闪烁
            if(led_ctrl == 1'b0)
                led <= 2'b01;
            else
                led <= 2'b10;
        2'b01 :  //如果按键1按下，则两个LED同时亮灭交替
            if(led_ctrl == 1'b0)
                led <= 2'b11;
            else
                led <= 2'b00;
        2'b11 :  //如果两个按键都未按下，则两个LED都保持点亮
                led <= 2'b11;
        default: ;
    endcase
end

endmodule
