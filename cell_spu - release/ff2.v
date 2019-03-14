//**************************************************************************************/
// Module:  	FF2
// File:    	FF2.v
// Description: The stage FF2
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF2(

	input wire clk,
	input wire rst,
	
	//from FF1
	input wire[`REG_ADDR_BUS7] iff2_rtaddr_e,
	input wire iff2_wreg_e,
	input wire[`REG_BUS128] iff2_rt_e, 
	input wire[0:2] iff2_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff2_rtaddr_o,
	input wire iff2_wreg_o,
	input wire[`REG_BUS128] iff2_rt_o,
	input wire[0:2] iff2_uid_o,
	//memory address
	input wire[0:31] iff2_memory_addr_o,

	input reg iff2_branch_flag,
	input reg[0:31] iff2_branch_target_addr,
	input reg[0:31] iff2_link_addr,
	input reg iff2_is_in_delayslot,

	//to FF3
	output reg[`REG_ADDR_BUS7] ff2_rtaddr_e,
	output reg ff2_wreg_e,
	output reg[`REG_BUS128] ff2_rt_e,
	output reg[0:2] ff2_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff2_rtaddr_o,
	output reg ff2_wreg_o,
	output reg[`REG_BUS128] ff2_rt_o,
	output reg[0:2] ff2_uid_o,
	//memory address
	output reg[0:31] ff2_memory_addr_o,

	output reg ff2_branch_flag,
	output reg[0:31] ff2_branch_target_addr,
	output reg[0:31] ff2_link_addr,
	output reg ff2_is_in_delayslot

);


	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ff2_rtaddr_e <= 0;
			ff2_rt_e <= 0;
			ff2_wreg_e <= 0;
			ff2_uid_e <= 0;
			ff2_rtaddr_o <= 0;
			ff2_rt_o <= 0;
			ff2_wreg_o <= 0;
			ff2_uid_o <= 0;
			ff2_branch_flag <= 0;
			ff2_branch_target_addr <= 0;
			ff2_link_addr <= 0;
			ff2_is_in_delayslot <= 0;
		end else begin
			ff2_rtaddr_e <= iff2_rtaddr_e;
			ff2_rt_e <= iff2_rt_e;
			ff2_wreg_e <= iff2_wreg_e;
			ff2_uid_e <= iff2_uid_e;
			ff2_rtaddr_o <= iff2_rtaddr_o;
			ff2_rt_o <= iff2_rt_o;
			ff2_wreg_o <= iff2_wreg_o;
			ff2_uid_o <= iff2_uid_o;
			ff2_memory_addr_o<=iff2_memory_addr_o;
			ff2_branch_flag <= iff2_branch_flag;
			ff2_branch_target_addr <= iff2_branch_target_addr;
			ff2_link_addr <= iff2_link_addr;
			ff2_is_in_delayslot <= iff2_is_in_delayslot;
		end
	end

endmodule