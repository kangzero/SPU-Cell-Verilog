//**************************************************************************************/
// Module:  	FF_MEM
// File:    	FF_MEM.v
// Description: The stage between FF and MEM
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF_MEM(

	input wire clk,
	input wire rst,
	
	//info from ff stage
	input wire[`REG_ADDR_BUS7] ff7_rtaddr_e,
	input wire ff7_wreg_e,
	input wire[`REG_BUS128] ff7_rt_e,
	input wire[0:2] ff7_uid_e,
	
	input wire[`REG_ADDR_BUS7] ff7_rtaddr_o,
	input wire ff7_wreg_o,
	input wire[`REG_BUS128] ff7_rt_o,
	input wire[0:2] ff7_uid_o,
	//memory address
	input wire[0:31] ff7_memory_addr_o,

	input wire[0:12] stall, 

	//info to MEM stage
	output reg[`REG_ADDR_BUS7] mem_rtaddr_e,
	output reg mem_wreg_e,
	output reg[`REG_BUS128] mem_rt_e,
	
	output reg[`REG_ADDR_BUS7] mem_rtaddr_o,
	output reg mem_wreg_o,
	output reg[`REG_BUS128] mem_rt_o,
	//memory address
	output reg[0:31] mem_memory_addr_o,
	output reg[0:2] mem_uid_o
);

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			mem_rtaddr_e = `NOP_REG_ADDR;
			mem_rt_e = `ZERO_QWORD128;
			mem_wreg_e = `WR_DISABLE;
			mem_rtaddr_o = `NOP_REG_ADDR;
			mem_rt_o = `ZERO_QWORD128;
			mem_wreg_o = `WR_DISABLE;
		end else if (stall[3] == `STOP && stall[11]) begin
			mem_rtaddr_e = `NOP_REG_ADDR;
			mem_rt_e = `ZERO_QWORD128;
			mem_wreg_e = `WR_DISABLE;
			mem_rtaddr_o = `NOP_REG_ADDR;
			mem_rt_o = `ZERO_QWORD128;
			mem_wreg_o = `WR_DISABLE;
		end else begin
			mem_rtaddr_e = ff7_rtaddr_e;
			mem_rt_e = ff7_rt_e;
			mem_wreg_e = ff7_wreg_e;
			mem_rtaddr_o = ff7_rtaddr_o;
			mem_rt_o = ff7_rt_o;
			mem_wreg_o = ff7_wreg_o;
			mem_uid_o = ff7_uid_o;
			mem_memory_addr_o=ff7_memory_addr_o;
		end
	end

endmodule