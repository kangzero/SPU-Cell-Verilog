//**************************************************************************************/
// Module:  	ID_EX
// File:    	id_ex.v
// Description: registers foward to ex between ID and EX 
// History: 	Created by Ning Kang, Mar 27, 2018 
//		Modify by Ning Kang, Apr 20, 2018 - added branch variables
//***************************************************************************************/

`include "defines.v"

module ID_EX(
	input wire clk,
	input wire rst,

	//info from ID
	input wire[0:31] id_pc,

	input wire[0:31] id_inst_l,
	input wire[0:31] id_inst_h,

	input wire[0:10] id_opcode_e,
	input wire[0:127] id_ra_e,
	input wire[0:127] id_rb_e,
	input wire[0:6] id_rtaddr_e,
	input wire[0:2] id_uid_e,
	//input wire id_even,
	input wire id_wreg_e,

	input wire[0:10] id_opcode_o,
	input wire[0:127] id_ra_o,
	input wire[0:127] id_rb_o,
	input wire[0:6] id_rtaddr_o,
	input wire[0:2] id_uid_o,
	input wire[0:9] id_imm_o,
	//input wire id_odd,
	input wire id_wreg_o,

	input wire[0:12] stall,

	input wire[0:31] id_link_addr,
	input wire id_is_in_delayslot,
	input wire id_next_inst_in_delayslot,
	input wire[0:31] id_branch_target_addr,
	input wire id_branch_flag,

	//info to EX
	output reg[0:31] ex_pc,
	output reg[0:31] ex_inst_l,
	output reg[0:31] ex_inst_h,

	output reg[0:10] ex_opcode_e,
	output reg[0:127] ex_ra_e,
	output reg[0:127] ex_rb_e,
	output reg[0:6] ex_rtaddr_e,
	output reg ex_wreg_e,
	output reg[0:2] ex_uid_e,
	//output reg ex_even,


	output reg[0:10] ex_opcode_o,
	output reg[0:127] ex_ra_o,
	output reg[0:127] ex_rb_o,
	output reg[0:6] ex_rtaddr_o,
	output reg ex_wreg_o,
	output reg[0:2] ex_uid_o,
	output reg[0:9] ex_imm_o,
	//output reg ex_odd,
	
	output reg[0:31] ex_link_addr,
	output reg ex_is_in_delayslot,
	output reg[0:31] ex_branch_target_addr,
	output reg ex_branch_flag,

	output reg is_in_delayslot_o
);

	always @ (posedge clk) begin
		if (rst == `RST_ENABLE) begin
			ex_opcode_e <= `EXE_NOP;
			ex_ra_e <= `ZERO_WORD32;
			ex_rb_e <= `ZERO_WORD32;
			ex_rtaddr_e <= `NOP_REG_ADDR;
			ex_wreg_e <= `WR_DISABLE;
			ex_opcode_o <= `EXE_NOP;
			ex_ra_o <= `ZERO_WORD32;
			ex_rb_o <= `ZERO_WORD32;
			ex_rtaddr_o <= `NOP_REG_ADDR;
			ex_wreg_o <= `WR_DISABLE;
			ex_link_addr <= `ZERO_WORD32;
			ex_is_in_delayslot <= `NOT_IN_DELAYSLOT;
			is_in_delayslot_o <= `NOT_IN_DELAYSLOT;
			ex_branch_target_addr <= `ZERO_WORD32;
			ex_branch_flag <= `NOTBRANCH;
			ex_pc <= 0;
		end else if(stall[2] == `STOP && stall[3] == `NOSTOP) begin
			ex_opcode_e <= `EXE_NOP;
			ex_ra_e <= `ZERO_WORD32;
			ex_rb_e <= `ZERO_WORD32;
			ex_rtaddr_e <= `NOP_REG_ADDR;
			ex_wreg_e <= `WR_DISABLE;
			ex_opcode_o <= `EXE_NOP;
			ex_ra_o <= `ZERO_WORD32;
			ex_rb_o <= `ZERO_WORD32;
			ex_rtaddr_o <= `NOP_REG_ADDR;
			ex_wreg_o <= `WR_DISABLE;
			ex_wreg_o <= `WR_DISABLE;
			ex_link_addr <= `ZERO_WORD32;
			ex_is_in_delayslot <= `NOT_IN_DELAYSLOT;
			is_in_delayslot_o <= `NOT_IN_DELAYSLOT;
			ex_branch_target_addr <= `ZERO_WORD32;
			ex_branch_flag <= `NOTBRANCH;
			ex_pc <= 0;
		end else if(stall[2] == `NOSTOP)begin		
			ex_opcode_e <= id_opcode_e;
			ex_ra_e <= id_ra_e;
			ex_rb_e <= id_rb_e;
			ex_rtaddr_e <= id_rtaddr_e;
			ex_uid_e <= id_uid_e;
			//ex_even <= id_even;
			ex_wreg_e <= id_wreg_e;	
			ex_opcode_o <= id_opcode_o;
			ex_ra_o <= id_ra_o;
			ex_rb_o <= id_rb_o;
			ex_rtaddr_o <= id_rtaddr_o;
			ex_uid_o <= id_uid_o;
			ex_imm_o <= id_imm_o;
			//ex_odd <= id_odd;
			ex_wreg_o <= id_wreg_o;	
			ex_link_addr <= id_link_addr;
			ex_is_in_delayslot <= id_is_in_delayslot;
			is_in_delayslot_o <= id_next_inst_in_delayslot;
			ex_branch_target_addr <= id_branch_target_addr;
			ex_branch_flag <= id_branch_flag;
			ex_inst_l <= id_inst_l;
			ex_inst_h <= id_inst_h;
			ex_pc <= id_pc;
		end 
	end

endmodule
