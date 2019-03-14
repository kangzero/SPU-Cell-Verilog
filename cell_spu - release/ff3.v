//**************************************************************************************/
// Module:  	FF3
// File:    	FF3.v
// Description: The stage FF3
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF3(

	input wire clk,
	input wire rst,
	
	//from FF2
	input wire[`REG_ADDR_BUS7] iff3_rtaddr_e,
	input wire iff3_wreg_e,
	input wire[`REG_BUS128] iff3_rt_e, 	
	input wire[0:2] iff3_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff3_rtaddr_o,
	input wire iff3_wreg_o,
	input wire[`REG_BUS128] iff3_rt_o,
	input wire[0:2] iff3_uid_o,
	//memory address
	input wire[0:31] iff3_memory_addr_o,

	input reg iff3_branch_flag,
	input reg[0:31] iff3_branch_target_addr,
	input reg[0:31] iff3_link_addr,
	input reg iff3_is_in_delayslot,

	//to FF4
	output reg[`REG_ADDR_BUS7] ff3_rtaddr_e,
	output reg ff3_wreg_e,
	output reg[`REG_BUS128] ff3_rt_e,
	output reg[0:2] ff3_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff3_rtaddr_o,
	output reg ff3_wreg_o,
	output reg[`REG_BUS128] ff3_rt_o,
	output reg[0:2] ff3_uid_o,
	//memory address
	output reg[0:31] ff3_memory_addr_o,

	output reg ff3_branch_flag,
	output reg[0:31] ff3_branch_target_addr,
	output reg[0:31] ff3_link_addr,
	output reg ff3_is_in_delayslot
);


	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			ff3_rtaddr_e <= 0;
			ff3_rt_e <= 0;
			ff3_wreg_e <= 0;
			ff3_uid_e <= 0;
			ff3_rtaddr_o <= 0;
			ff3_rt_o <= 0;
			ff3_wreg_o <= 0;
			ff3_uid_o <= 0;
			ff3_branch_flag <= 0;
			ff3_branch_target_addr <= 0;
			ff3_link_addr <= 0;
			ff3_is_in_delayslot <= 0;
		end else begin
			ff3_rtaddr_e <= iff3_rtaddr_e;
			ff3_rt_e <= iff3_rt_e;
			ff3_wreg_e <= iff3_wreg_e;
			ff3_uid_e <= iff3_uid_e;
			ff3_rtaddr_o <= iff3_rtaddr_o;
			ff3_rt_o <= iff3_rt_o;
			ff3_wreg_o <= iff3_wreg_o;
			ff3_uid_o <= iff3_uid_o;
			ff3_memory_addr_o<=iff3_memory_addr_o;
			ff3_branch_flag <= iff3_branch_flag;
			ff3_branch_target_addr <= iff3_branch_target_addr;
			ff3_link_addr <= iff3_link_addr;
			ff3_is_in_delayslot <= iff3_is_in_delayslot;
		end
	end

endmodule