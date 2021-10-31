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
                       input [2:0] key,
//                       output [1:0]key_out,
                       output [3:0]spd_index,
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

//虚假encoder 速度等级信号
localparam				NUM_50MS	=	25'd250_0000;
localparam				NUM_45MS	=	25'd225_0000;
localparam				NUM_40MS	=	25'd200_0000;
localparam				NUM_35MS	=	25'd175_0000;
localparam				NUM_30MS	=	25'd150_0000;
localparam				NUM_25MS	=	25'd125_0000;
localparam				NUM_20MS	=	25'd100_0000;
localparam				NUM_15MS	=	25'd75_0000;
localparam				NUM_10MS	=	25'd50_0000;
localparam				NUM_5MS 	=	25'd25_0000;

reg [24:0] speed_level[9:0];

reg [3:0] speed_level_index;

reg dir_cmd;

//initialize speed _level memory
initial begin
speed_level[0] = NUM_50MS;
speed_level[1] = NUM_45MS;
speed_level[2] = NUM_40MS;
speed_level[3] = NUM_35MS;
speed_level[4] = NUM_30MS;
speed_level[5] = NUM_25MS;
speed_level[6] = NUM_20MS;
speed_level[7] = NUM_15MS;
speed_level[8] = NUM_10MS;
speed_level[9] = NUM_5MS;

speed_level_index = 4'h0; //lowest speed;
dir_cmd = 1'b0;  //cw
end

//按键去抖
wire [2:0] key_out;
sw_debounce u0(
    		.clk(clk),
    		.rst_n(rst_n),
			.sw1_n(key[0]),
			.sw2_n(key[1]),
			.sw3_n(key[2]),
	   		.sw_out(key_out)
    		);
 //https://blog.csdn.net/weixin_30702413  keyword；按键的使用
//加速按键(R29)下降沿检测
//----------key1----------------
reg     [2:0]    key_1_reg;
wire             key_1_neg;
always @(posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
       key_1_reg <= 3'b111;                //默认按键没有按下时为高电平
    end
  else 
    begin
        key_1_reg  <= {key_1_reg[1:0],key_out[0]};
    end
  end

assign key_1_neg = key_1_reg[2]&(~key_1_reg[1]);

//加速按键(R29)逻辑 + 减速按键(R35)逻辑
always @(posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
      speed_level_index <= 4'h0;
    end
  else if(key_1_neg && !key_2_neg)
    begin
      if(speed_level_index <= 4'h8) speed_level_index <= speed_level_index + 4'h1; 
      else speed_level_index <= 4'h0;
    end
    else if(!key_1_neg && key_2_neg)
     begin
           if(speed_level_index >= 4'h1) speed_level_index <= speed_level_index - 4'h1; 
           else speed_level_index <= 4'h9;
     end
    else
      speed_level_index <= speed_level_index ;   
  end
  
  assign spd_index = speed_level_index;
//减速按键(R35)逻辑
//  always @(posedge clk or negedge rst_n)
//   begin
//    if(!rst_n)
//     begin
//        speed_level_index <= 0;
//      end
//    else if(key_2_neg)
//      begin
//        if(speed_level_index >= 0) speed_level_index <= speed_level_index - 1; 
//        else speed_level_index = 9;
//      end
//      else 
//        speed_level_index <= speed_level_index ;   
//    end    

//减速按键(R35)下降沿检测
//----------key2----------------
reg     [2:0]    key_2_reg;
wire             key_2_neg;
always @(posedge clk or negedge rst_n)
 begin
  if(!rst_n)
   begin
       key_2_reg <= 3'b111;                //默认按键没有按下时为高电平
    end
  else 
    begin
        key_2_reg  <= {key_2_reg[2:0],key_out[1]};
    end
  end

assign key_2_neg = key_2_reg[2]&(~key_2_reg[1]);

 //换向按键(R36)下降沿检测
  //----------key3----------------
  reg     [2:0]    key_3_reg;
  wire             key_3_neg;
  always @(posedge clk or negedge rst_n)
   begin
    if(!rst_n)
     begin
         key_3_reg <= 3'b111;                //默认按键没有按下时为高电平
      end
    else 
      begin
          key_3_reg  <= {key_3_reg[2:0],key_out[2]};
      end
    end
  
  assign key_3_neg = key_3_reg[2]&(~key_3_reg[1]);
  
  //换向按键(R36)逻辑
  always @(posedge clk or negedge rst_n)
   begin
    if(!rst_n)
     begin
        dir_cmd <= 1'b0;  //cw
      end
    else if(key_3_neg)
      begin
        dir_cmd <=  ~dir_cmd ;  //cw - ccw
      end
      else 
        dir_cmd <=  dir_cmd ;  
    end    

reg				[31:0]	fake_encoder_cnt;
//计数器周期为500ms
always@(posedge clk or negedge rst_n) begin
   
	if(!rst_n) fake_encoder_cnt <= 0;
	else if(fake_encoder_cnt <= speed_level[speed_level_index]/4-1) 
	begin
	//if(dir_cmd == 1'b0)
	// begin
	 a_in <= 1'b1;
	 b_in <= 1'b1;
	 //end
	 fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
	end
	else if(fake_encoder_cnt <= speed_level[speed_level_index]/2-1) 
    begin
    if(dir_cmd == 1'b0)
    begin
     a_in <= 1'b0;
     b_in <= b_in;
     end
     else
     begin
      b_in <= 1'b0;
      a_in <= a_in;
     end
     fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
    end
    else if(fake_encoder_cnt <= 3*speed_level[speed_level_index]/4-1) 
    begin
     if(dir_cmd == 1'b0)
     begin
     a_in <= a_in;
     b_in <= 1'b0;
     end
     else
     begin
      b_in <= b_in;
      a_in <= 1'b0;
     end
     fake_encoder_cnt <= fake_encoder_cnt + 1'b1;
    end
    else if(fake_encoder_cnt <= speed_level[speed_level_index]-1) 
    begin
     if(dir_cmd == 1'b0)
        begin
     a_in <= 1'b1;
     b_in <= b_in;
     end
     else
     begin
      b_in <= 1'b1;
      a_in <= a_in;
     end
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
