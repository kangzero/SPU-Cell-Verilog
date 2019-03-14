//**************************************************************************************/
// Module:  	EX_FF
// File:    	ex_FF.v
// Description: The stage between Execution and FF
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module EX_FF(

	input wire clk,
	input wire rst,
	
	//info from execution stage
	input wire[`REG_BUS128] ex_rt_e, 	
	input wire[`REG_ADDR_BUS7] ex_rtaddr_e,
	input wire ex_wreg_e,
	input wire[0:2] ex_uid_e,
	
	input wire[`REG_BUS128] ex_rt_o,
	input wire[`REG_ADDR_BUS7] ex_rtaddr_o,
	input wire ex_wreg_o,
	input wire[0:2] ex_uid_o,
	//memory address
	input wire[0:31] ex_memory_addr_o,

	input reg[0:31] ex_link_addr,
	input reg ex_is_in_delayslot,
	input reg[0:31] ex_branch_target_addr,
	input reg ex_branch_flag,

	//info to ff stage
	output reg[`REG_ADDR_BUS7] ff_rtaddr_e,
	output reg ff_wreg_e,
	output reg[`REG_BUS128] ff_rt_e,
	output reg[0:2] ff_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff_rtaddr_o,
	output reg ff_wreg_o,
	output reg[`REG_BUS128] ff_rt_o,
	output reg[0:2] ff_uid_o,
	//memory address
	output reg[0:31] ff_memory_addr_o,

	output reg ff_branch_flag,
	output reg[0:31] ff_branch_target_addr,
	output reg[0:31] ff_link_addr,
	output reg ff_is_in_delayslot
);


	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ff_rtaddr_e <= 0;
			ff_rt_e <= 0;
			ff_wreg_e <= 0;
			ff_uid_e <= 0;
			ff_rtaddr_o <= 0;
			ff_rt_o <= 0;
			ff_wreg_o <= 0;
			ff_uid_o <= 0;
			ff_branch_flag <= 0;
			ff_branch_target_addr <= 0;
			ff_link_addr <= 0;
			ff_is_in_delayslot <= 0;
		end else begin
			ff_rtaddr_e <= ex_rtaddr_e;
			ff_rt_e <= ex_rt_e;
			ff_wreg_e <= ex_wreg_e;
			ff_uid_e <= ex_uid_e;
			ff_rtaddr_o <= ex_rtaddr_o;
			ff_rt_o <= ex_rt_o;
			ff_wreg_o <= ex_wreg_o;
			ff_uid_o <= ex_uid_o;	
			ff_branch_flag <= ex_branch_flag;
			ff_branch_target_addr <= ex_branch_target_addr;
			ff_link_addr <= ff_link_addr;
			ff_is_in_delayslot <= ff_is_in_delayslot;
			ff_memory_addr_o<=ex_memory_addr_o;
		end
	end

endmodule