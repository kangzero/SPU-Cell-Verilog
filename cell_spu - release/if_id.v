//**************************************************************************************/
// Module:  	IF_ID
// File:    	if_id.v
// Description: Buffer between instruction fetch an instruction decode
// History: 	Created by Weilun Cheng, Mar 15,2018
//		Modify by Ning Kang, Mar 25, 2018 
//			- change if_pc to 32 bits fixed length
//			- modify inst from 32 bits to 64 bits for 2 ins fetch at a time
//		Modify by Ning Kang, Apr 24, 2018
//			- add Stall mechanism
//***************************************************************************************/

`include "defines.v"

module IF_ID(

	input wire clk, //SPU clock
	input wire rst, //SPU reset

	input wire[`INST_ADDR_BUS32] if_pc, //PC in instruction fetch stage, from pc to id_pc
	input wire[`INST2_BUS64] if_inst, //2 instructions fetch in IF stage, to id_inst
	//input wire[`INST2_BUS64] inst_echo,
	input wire pipe_l, pipe_h,
	
	input wire[0:12] stall, // ctrl bits from CTRL module

	output reg[`INST_ADDR_BUS32] id_pc, //PC in instruction decode stage
	output reg[`INST2_BUS64] id_inst //2 instructions in ID stage, further split to 2 ins in ID
);

	reg[0:63] inst_echo;

 	always @ (posedge clk) begin
		if ( rst == `RST_ENABLE ) begin
			id_pc <= `ZERO_WORD32;
			id_inst <= `ZERO_DWORD64;
		end else if (stall[1] == `STOP && stall[2] == `NOSTOP) begin //
			id_pc <= `ZERO_WORD32;
			id_inst <= `ZERO_DWORD64;
		//end else if ((stall[2] == `STOP) && (stall[3] == `NOSTOP))begin
		end else if ((stall == 13'h7) && (pipe_l==`PIPE_ODD)&&(pipe_h==`PIPE_ODD) ) begin
			id_pc <= if_pc;
			id_inst <= {inst_echo[32:63], 32'h40200000}; // resend previous 2 instructions to ID
		end else if ((stall == 13'h7) && (pipe_l==`PIPE_EVEN)&&(pipe_h==`PIPE_EVEN) ) begin
			id_pc <= if_pc;
			id_inst <= {inst_echo[32:63], 32'h00200000}; // resend previous 2 instructions to ID
		end else if (stall == 13'h7) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end else if (stall[1] == `NOSTOP) begin
			id_pc <= if_pc;
			id_inst <= if_inst;
			inst_echo <= if_inst; // reserve current 2 instructions
		end
	end 

endmodule
