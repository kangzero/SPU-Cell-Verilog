//**************************************************************************************/
// Module:  	FF7
// File:    	FF7.v
// Description: The stage FF7
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF7(

	input wire clk,
	input wire rst,
	
	//from FF6
	input wire[`REG_ADDR_BUS7] iff7_rtaddr_e,
	input wire iff7_wreg_e,
	input wire[`REG_BUS128] iff7_rt_e, 
	input wire[0:2] iff7_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff7_rtaddr_o,
	input wire iff7_wreg_o,
	input wire[`REG_BUS128] iff7_rt_o,
	input wire[0:2] iff7_uid_o,
	//memory address
	input wire[0:31] iff7_memory_addr_o,

	//to FF/MEM
	output reg[`REG_ADDR_BUS7] ff7_rtaddr_e,
	output reg ff7_wreg_e,
	output reg[`REG_BUS128] ff7_rt_e,
	output reg[0:2] ff7_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff7_rtaddr_o,
	output reg ff7_wreg_o,
	output reg[`REG_BUS128] ff7_rt_o,
	output reg[0:2] ff7_uid_o,
	//memory address
	output reg[0:31] ff7_memory_addr_o
);

	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			ff7_rtaddr_e <= 0;
			ff7_rt_e <= 0;
			ff7_wreg_e <= 0;
			ff7_uid_e <= 0;
			ff7_rtaddr_o <= 0;
			ff7_rt_o <= 0;
			ff7_wreg_o <= 0;
			ff7_uid_o <= 0;
		end else begin
			ff7_rtaddr_e <= iff7_rtaddr_e;
			ff7_rt_e <= iff7_rt_e;
			ff7_wreg_e <= iff7_wreg_e;
			ff7_uid_e <= iff7_uid_e;
			ff7_rtaddr_o <= iff7_rtaddr_o;
			ff7_rt_o <= iff7_rt_o;
			ff7_wreg_o <= iff7_wreg_o;
			ff7_uid_o <= iff7_uid_o;
			ff7_memory_addr_o<=iff7_memory_addr_o;
		end
	end
endmodule