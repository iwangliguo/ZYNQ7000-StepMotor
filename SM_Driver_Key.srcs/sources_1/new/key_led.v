//****************************************Copyright (c)***********************************//
//ԭ�Ӹ����߽�ѧƽ̨��www.yuanzige.com
//����֧�֣�www.openedv.com
//�Ա����̣�http://openedv.taobao.com
//��ע΢�Ź���ƽ̨΢�źţ�"����ԭ��"����ѻ�ȡZYNQ & FPGA & STM32 & LINUX���ϡ�
//��Ȩ���У�����ؾ���
//Copyright(C) ����ԭ�� 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           beep_control
// Last modified Date:  2019/4/15 11:30:36
// Last Version:        V1.0
// Descriptions:        ��������LED
//----------------------------------------------------------------------------------------
// Created by:          ����ԭ��
// Created date:        2019/4/15 11:30:56
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
// Modified by:		    ����ԭ��
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

//������
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        cnt <= 25'd0;
    else if(cnt < 25'd2500_0000)  //����500ms
        cnt <= cnt + 1'b1;
    else
        cnt <= 25'd0;
end

//ÿ��500ms�͸���LED����˸״̬
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led_ctrl <= 1'b0;
    else if(cnt == 25'd2500_0000)
        led_ctrl <= ~led_ctrl;
end

//���ݰ�����״̬�Լ�LED����˸״̬����ֵLED
always @ (posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n)
        led <= 2'b11;
    else case(key)
        2'b10 :  //�������0���£�������LED������˸
            if(led_ctrl == 1'b0)
                led <= 2'b01;
            else
                led <= 2'b10;
        2'b01 :  //�������1���£�������LEDͬʱ������
            if(led_ctrl == 1'b0)
                led <= 2'b11;
            else
                led <= 2'b00;
        2'b11 :  //�������������δ���£�������LED�����ֵ���
                led <= 2'b11;
        default: ;
    endcase
end

endmodule
