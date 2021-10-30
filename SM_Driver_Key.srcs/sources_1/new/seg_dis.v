`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/09/30 22:59:30
// Design Name: 
// Module Name: seg_dis
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


module seg_dis(
    input clk,
    input rst_n,
    input [31:0]  dis_data,
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
    output seg_dig6
    );
    
//	Clock Setting
    parameter   CLK_Freq    =  50000000;    //    50    MHz
    parameter   PUL_Freq    =  300;
    parameter   SLOW_Freq   =  3;
    
reg   [7:0]   code;
reg   [3:0]   data;
reg           flash;

reg   [2:0]   cnt; 
reg   [26:0]  LED_CLK_DIV;
reg   [26:0]  SLOW_DIV;

assign  seg_oe_n = (dis_data[31:30] == 2'b10) ? 1'b0 : 1'b1;

assign  seg_a  = code[0];
assign  seg_b  = code[1];
assign  seg_c  = code[2];
assign  seg_d  = code[3];
assign  seg_e  = code[4];
assign  seg_f  = code[5]; 
assign  seg_g  = code[6];
assign  seg_dp = code[7];  


assign  seg_dig1 = (cnt == 3'b000) ? (dis_data[29] == 1'b1 ? flash : 1'b1) : 1'b0; 
assign  seg_dig2 = (cnt == 3'b001) ? (dis_data[28] == 1'b1 ? flash : 1'b1) : 1'b0;  
assign  seg_dig3 = (cnt == 3'b010) ? (dis_data[27] == 1'b1 ? flash : 1'b1) : 1'b0; 
assign  seg_dig4 = (cnt == 3'b011) ? (dis_data[26] == 1'b1 ? flash : 1'b1) : 1'b0;
assign  seg_dig5 = (cnt == 3'b100) ? (dis_data[25] == 1'b1 ? flash : 1'b1) : 1'b0;  
assign  seg_dig6 = (cnt == 3'b101) ? (dis_data[24] == 1'b1 ? flash : 1'b1) : 1'b0; 

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
	   data <= 5'b11111;
	end
	else
	begin
	   case(cnt)
	       3'b000:begin
	           data <= dis_data[23:20];
	       end
	       3'b001:begin
               data <= dis_data[19:16];
           end
           3'b010:begin
               data <= dis_data[15:12];
           end
           3'b011:begin
               data <= dis_data[11:8];
           end
           3'b100:begin
               data <= dis_data[7:4];
           end
           3'b101:begin
               data <= dis_data[3:0];
           end
           default:begin
               data <= 5'b11111;
           end
	    endcase
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		flash  <= 1'b0;
	end
	else
	begin
		if( SLOW_DIV	< (CLK_Freq/SLOW_Freq) )
		begin
		    SLOW_DIV	<=	SLOW_DIV + 1'b1;
		    flash       <=  flash;
		end
		else
		begin
			SLOW_DIV	<=	0;
            flash       <= ~flash;
		end
	end
end

always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt  <= 3'b111;
	end
	else
	begin
		if( LED_CLK_DIV	< (CLK_Freq/PUL_Freq) )
		begin
		    LED_CLK_DIV	<=	LED_CLK_DIV + 1'b1;
		    cnt <= cnt;
		end
		else
		begin
			LED_CLK_DIV	<=	0;
			if(cnt < 3'b101)
			 cnt <= cnt +1;
			else
			 cnt <= 3'b000;
		end
	end
end


  

always @(*)
begin
    case(data[3:0])
        4'b0000:begin
        code = 8'h3f;
    end
        4'b0001:begin
        code = 8'h06;
    end
        4'b0010:begin
        code = 8'h5b;
    end
        4'b0011:begin
        code = 8'h4f;
    end
        4'b0100:begin
        code = 8'h66;
    end
        4'b0101:begin
        code = 8'h6d;
    end
        4'b0110:begin
        code = 8'h7d;
    end
        4'b0111:begin
        code = 8'h07;
    end
        4'b1000:begin
        code = 8'h7f;
    end
        4'b1001:begin
        code = 8'h6f;
    end
        default:begin
        code = 8'h00;
    end
    endcase
end


endmodule