//**************************************************************************************/
// Module:  	FF1
// File:    	FF1.v
// Description: The stage FF1
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF1(

	input wire clk,
	input wire rst,
	
	//info from ex/ff
	input wire[`REG_ADDR_BUS7] iff_rtaddr_e,
	input wire iff_wreg_e,
	input wire[`REG_BUS128] iff_rt_e,
	input wire[0:2] iff_uid_e,
	
	input wire[`REG_ADDR_BUS7]	iff_rtaddr_o,
	input wire iff_wreg_o,
	input wire[`REG_BUS128] iff_rt_o,
	input wire[0:2] iff_uid_o,
	//memory address
	input wire[0:31] iff_memory_addr_o,

	input reg iff_branch_flag,
	input reg[0:31] iff_branch_target_addr,
	input reg[0:31] iff_link_addr,
	input reg iff_is_in_delayslot,

	//info to ff2 stage
	output reg[`REG_ADDR_BUS7] ff1_rtaddr_e,
	output reg ff1_wreg_e,
	output reg[`REG_BUS128] ff1_rt_e,
	output reg[0:2] ff1_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff1_rtaddr_o,
	output reg ff1_wreg_o,
	output reg[`REG_BUS128] ff1_rt_o,
	output reg[0:2] ff1_uid_o,
	//memory address
	output reg[0:31] ff1_memory_addr_o,

	output reg ff1_branch_flag,
	output reg[0:31] ff1_branch_target_addr,
	output reg[0:31] ff1_link_addr,
	output reg ff1_is_in_delayslot

);

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ff1_rtaddr_e <= 0;
			ff1_rt_e <= 0;
			ff1_wreg_e <= 0;
			ff1_uid_e <= 0;
			ff1_rtaddr_o <= 0;
			ff1_rt_o <= 0;
			ff1_wreg_o <= 0;
			ff1_uid_o <= 0;
			ff1_branch_flag <= 0;
			ff1_branch_target_addr <= 0;
			ff1_link_addr <= 0;
			ff1_is_in_delayslot <= 0;
		end else begin
			ff1_rtaddr_e <= iff_rtaddr_e;
			ff1_rt_e <= iff_rt_e;
			ff1_wreg_e <= iff_wreg_e;
			ff1_uid_e <= iff_uid_e;
			ff1_rtaddr_o <= iff_rtaddr_o;
			ff1_rt_o <= iff_rt_o;
			ff1_wreg_o <= iff_wreg_o;
			ff1_uid_o <= iff_uid_o;
			ff1_memory_addr_o<=iff_memory_addr_o;
			ff1_branch_flag <= iff_branch_flag;
			ff1_branch_target_addr <= iff_branch_target_addr;
			ff1_link_addr <= iff_link_addr;
			ff1_is_in_delayslot <= iff_is_in_delayslot;
		end
	end

endmodule