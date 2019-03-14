//**************************************************************************************/
// Module:  	PC_REG - PC register
// File:    	pc_reg.v
// Description: PC register stores the instruction address and +8 per clock cycle
// 		PC is 32 bits fixed length
// History: 	Created by Weilun Cheng, Mar 15,2018
//		Modify by Ning Kang, Mar 25, 2018 - modify the PC length
//***************************************************************************************/

`include "defines.v"

module PC_REG(

	input wire clk, 	//SPC clock
	input wire rst, 	//SPU reset
	input wire [0:12] stall, //from CTRL module

	input wire id_pc,
	input wire branch_flag_i,
	//input wire branch_clr,

	input wire[0:31] branch_target_addr_i,
	
	output reg[0:31] pc, 	//PC register: instruction address, to if_pc
	output reg ce 		//Cache eanble, posedge active
	
);

	reg[0:31] pc_echo;
	//reg branch_flag;
	reg i=0;
	
	
	always @(*) begin
		//branch_flag = (branch_flag_i&&branch_clr);
		i = 0;
	end

	always @ (posedge clk) begin
		if (rst == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;
		end else begin
			ce <= `CHIP_ENABLE; 
		end
	end
	
	always @ (posedge clk) begin
		if (ce == `CHIP_DISABLE) begin
			pc = `ZERO_WORD32;
		end else if (stall[0] == `NOSTOP) begin
			if((branch_flag_i == `BRANCH) &&(i==0)) begin
				pc = branch_target_addr_i;
				i = 1;
			end else if (stall==13'h7) begin
				pc = pc;
			end else if (stall==13'h8) begin
				pc = pc_echo;
			end else begin 
				pc = pc + 4'h8; 
				pc_echo = pc-4'h8;
			end 
		end 
	end

endmodule
