//**************************************************************************************/
// Module:  	FF6
// File:    	FF6.v
// Description: The stage FF6
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF6(

	input wire clk,
	input wire rst,
	
	//from FF5
	input wire[`REG_ADDR_BUS7] iff6_rtaddr_e,
	input wire iff6_wreg_e,
	input wire[`REG_BUS128] iff6_rt_e,
	input wire[0:2] iff6_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff6_rtaddr_o,
	input wire iff6_wreg_o,
	input wire[`REG_BUS128] iff6_rt_o,
	input wire[0:2] iff6_uid_o,
	//memory address
	input wire[0:31] iff6_memory_addr_o,

	//to FF7
	output reg[`REG_ADDR_BUS7] ff6_rtaddr_e,
	output reg ff6_wreg_e,
	output reg[`REG_BUS128] ff6_rt_e,
	output reg[0:2] ff6_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff6_rtaddr_o,
	output reg ff6_wreg_o,
	output reg[`REG_BUS128] ff6_rt_o,
	output reg[0:2] ff6_uid_o,
	//memory address
	output reg[0:31] ff6_memory_addr_o
);

	 
	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			ff6_rtaddr_e <= 0;
			ff6_rt_e <= 0;
			ff6_wreg_e <= 0;
			ff6_uid_e <= 0;
			ff6_rtaddr_o <= 0;
			ff6_rt_o <= 0;
			ff6_wreg_o <= 0;
			ff6_uid_o <= 0;
		end else begin
			ff6_rtaddr_e <= iff6_rtaddr_e;
			ff6_rt_e <= iff6_rt_e;
			ff6_wreg_e <= iff6_wreg_e;
			ff6_uid_e <= iff6_uid_e;
			ff6_rtaddr_o <= iff6_rtaddr_o;
			ff6_rt_o <= iff6_rt_o;
			ff6_wreg_o <= iff6_wreg_o;
			ff6_uid_o <= iff6_uid_o;
			ff6_memory_addr_o<=iff6_memory_addr_o;
		end
	end
endmodule