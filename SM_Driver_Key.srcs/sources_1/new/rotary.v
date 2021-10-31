`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/18 00:56:35
// Design Name: 
// Module Name: rotary
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

module     rotary     (
//                       input a_in,
//                       input b_in,
//                       input z_in,
                       input        [1:0]  key_led ,
                       input        [2:0]  key_sm,
                      // output dir,
                      // output zero,
                       //seg
                       output seg_a,
                       output seg_b,
                       output seg_c,
                       output seg_d,
                       output seg_e,
                       output seg_f,
                       output seg_g,
                       output seg_dp,
                       output seg_oe_n,
                       output seg_dig1,
                       output seg_dig2,
                       output seg_dig3,
                       output seg_dig4,
                       output seg_dig5,
                       output seg_dig6, 
                       //step motor
                       output motor_pul,
                       output motor_dir,
                       output motor_ena,           
                       //led
                       output [1:0]  led
                       );    
wire clk;
wire rst_n;

wire [3:0] spd_index;
wire [3:0] spd_dir;

wire [15:0] dis_data;
wire pulse;
wire dir;

zynq      u0        (
                     .FCLK_CLK0(clk),
                     .FCLK_RESET0_N(rst_n)
                     );
                     
encoder   u1        (
                     .clk(clk),
                     .rst_n(rst_n),
//                     .a_in(a_in),
//                     .b_in(b_in),
//                     .z_in(z_in),
                     .key(key_sm),
                     //output
                     .spd_index(spd_index),
                     .dir(dir),
                    // .zero(zero),
                     .pulse(pulse),
                     .bcd_data(dis_data)
                     );  
 
assign spd_dir = {3'b000,motor_dir};                    
seg_dis    u2       (
                     .clk(clk),      
                     .rst_n(rst_n),      
                     .dis_data({8'h80,spd_index,spd_dir,dis_data}),   
                     //output   
                     .seg_a(seg_a),     
                     .seg_b(seg_b),     
                     .seg_c(seg_c),     
                     .seg_d(seg_d),     
                     .seg_e(seg_e),     
                     .seg_f(seg_f),         
                     .seg_g(seg_g),         
                     .seg_dp(seg_dp),          
                     .seg_oe_n(seg_oe_n),         
                     .seg_dig1(seg_dig1),         
                     .seg_dig2(seg_dig2),         
                     .seg_dig3(seg_dig3),          
                     .seg_dig4(seg_dig4),          
                     .seg_dig5(seg_dig5),          
                     .seg_dig6(seg_dig6)
                      ); 
                      
step_motor     u3     (
                      .clk(clk),
                      .rst_n(rst_n),
                       //input,
                      .pul_in(pulse),
                      .ena_in(1'b0),
                      .dir_in(dir),
                      //output
                      .pul(motor_pul),
                      .ena(motor_ena),
                      .dir(motor_dir)
                      );       
                      
key_led        u4       (
                         .sys_clk(clk) ,
                         .sys_rst_n(rst_n) ,
                      
                         .key(key_led), 
                         .led(led)
                      );                                             
              
endmodule
