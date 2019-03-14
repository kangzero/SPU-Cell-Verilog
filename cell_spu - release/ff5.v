//**************************************************************************************/
// Module:  	FF5
// File:    	FF5.v
// Description: The stage FF5
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module FF5(

	input wire clk,
	input wire rst,
	
	//from FF4
	input wire[`REG_ADDR_BUS7] iff5_rtaddr_e,
	input wire iff5_wreg_e,
	input wire[`REG_BUS128] iff5_rt_e,
	input wire[0:2] iff5_uid_e,
	
	input wire[`REG_ADDR_BUS7] iff5_rtaddr_o,
	input wire iff5_wreg_o,
	input wire[`REG_BUS128] iff5_rt_o,
	input wire[0:2] iff5_uid_o,
	//memory address
	input wire[0:31] iff5_memory_addr_o,
	
	//to FF6
	output reg[`REG_ADDR_BUS7] ff5_rtaddr_e,
	output reg ff5_wreg_e,
	output reg[`REG_BUS128] ff5_rt_e,
	output reg[0:2] ff5_uid_e,
	
	output reg[`REG_ADDR_BUS7] ff5_rtaddr_o,
	output reg ff5_wreg_o,
	output reg[`REG_BUS128] ff5_rt_o,
	output reg[0:2] ff5_uid_o,
	//memory address
	output reg[0:31] ff5_memory_addr_o
);


	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			ff5_rtaddr_e <= 0;
			ff5_rt_e <= 0;
			ff5_wreg_e <= 0;
			ff5_uid_e <= 0;
			ff5_rtaddr_o <= 0;
			ff5_rt_o <= 0;
			ff5_wreg_o <= 0;
			ff5_uid_o <= 0;
		end else begin
			ff5_rtaddr_e <= iff5_rtaddr_e;
			ff5_rt_e <= iff5_rt_e;
			ff5_wreg_e <= iff5_wreg_e;
			ff5_uid_e <= iff5_uid_e;
			ff5_rtaddr_o <= iff5_rtaddr_o;
			ff5_rt_o <= iff5_rt_o;
			ff5_wreg_o <= iff5_wreg_o;
			ff5_uid_o <= iff5_uid_o;
			ff5_memory_addr_o<=iff5_memory_addr_o;
		end
	end

endmodule