//**************************************************************************************/
// Module:  	FF4
// File:    	FF4.v
// Description: The stage FF4
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF4(

	input wire clk,
	input wire rst,
	
	//from FF3
	input wire[`REG_ADDR_BUS7] iff4_rtaddr_e,
	input wire iff4_wreg_e,
	input wire[`REG_BUS128] iff4_rt_e,
	input wire[0:2] iff4_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff4_rtaddr_o,
	input wire iff4_wreg_o,
	input wire[`REG_BUS128] iff4_rt_o,
	input wire[0:2] iff4_uid_o,
	//memory address
	input wire[0:31] iff4_memory_addr_o,

	input reg iff4_branch_flag,
	input reg[0:31] iff4_branch_target_addr,
	input reg[0:31] iff4_link_addr,
	input reg iff4_is_in_delayslot,

	//to FF5
	output reg[`REG_ADDR_BUS7] ff4_rtaddr_e,
	output reg ff4_wreg_e,
	output reg[`REG_BUS128] ff4_rt_e,
	output reg[0:2] ff4_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff4_rtaddr_o,
	output reg ff4_wreg_o,
	output reg[`REG_BUS128] ff4_rt_o,
	output reg[0:2] ff4_uid_o,
	//memory address
	output reg[0:31] ff4_memory_addr_o,
	//PC_REG
	output reg ff4_branch_flag,
	output reg[0:31] ff4_branch_target_addr,
	output reg ff4_is_in_delayslot
);

	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			ff4_rtaddr_e <= 0;
			ff4_rt_e <= 0;
			ff4_wreg_e <= 0;
			ff4_uid_e <= 0;
			ff4_rtaddr_o <= 0;
			ff4_rt_o <= 0;
			ff4_wreg_o <= 0;
			ff4_uid_o <= 0;
			ff4_branch_flag <= 0;
			ff4_branch_target_addr <= 0;
			ff4_is_in_delayslot <= 0;
		end else begin
			ff4_rtaddr_e <= iff4_rtaddr_e;
			ff4_rt_e <= iff4_rt_e;
			ff4_wreg_e <= iff4_wreg_e;
			ff4_uid_e <= iff4_uid_e;
			ff4_rtaddr_o <= iff4_rtaddr_o;
			ff4_wreg_o <= iff4_wreg_o;
			ff4_uid_o <= iff4_uid_o;
			ff4_branch_flag = iff4_branch_flag;
			ff4_branch_target_addr <= iff4_branch_target_addr;
//ff4_branch_target_addr <= 32'h100;
			ff4_is_in_delayslot <= iff4_is_in_delayslot;
			if (ff4_branch_flag == `BRANCH) begin 
				ff4_rt_o <= iff4_link_addr;
			end else begin
				ff4_rt_o <= iff4_rt_o;
			end
			ff4_memory_addr_o<=iff4_memory_addr_o;			
		end
	end

endmodule