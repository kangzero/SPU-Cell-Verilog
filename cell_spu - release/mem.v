//**************************************************************************************/
// Module:  	MEM
// File:    	mem.v
// Description: The stage of memory access
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module MEM(

	input wire rst,
	
	//the info from ff
	input wire[`REG_ADDR_BUS7] i_rtaddr_e,
	input wire i_wreg_e,
	input wire[`REG_BUS128] i_rt_e, 	
	
	input wire[`REG_ADDR_BUS7] i_rtaddr_o,
	input wire i_wreg_o,
	input wire[`REG_BUS128] i_rt_o,
	//memory address
	input wire[`MEMORY_WIDTH32] i_memory_addr_o,
	input wire[`REG_BUS128] rt_from_memory,
	input wire[0:2] i_uid_o,
	
	//the info to mem
	output reg[`REG_ADDR_BUS7] o_rtaddr_e,
	output reg o_wreg_e,
	output reg[`REG_BUS128] o_rt_e,
	
	output reg[`REG_ADDR_BUS7] o_rtaddr_o,
	output reg o_wreg_o,
	output reg[`REG_BUS128] o_rt_o,
	//imformation for memory
	output reg[`MEMORY_WIDTH32] mem_data_addr,
	output reg write_memory_enable,
	output reg[`REG_BUS128] rt_to_memory
	
);

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			o_rtaddr_e = 0;
			o_rt_e = 0;
			o_wreg_e = 0;
			o_rtaddr_o = 0;
			o_rt_o = 0;
			o_wreg_o = 0;
		end else begin
			if (i_uid_o==`UID_5)
				begin
				mem_data_addr=i_memory_addr_o;
				o_rtaddr_o = i_rtaddr_o;
				o_wreg_o = i_wreg_o;
				o_rt_o=rt_from_memory;
				write_memory_enable=1'b0;
				end
			else if (i_uid_o==`UID_6)
				begin
				write_memory_enable=1'b1;
				mem_data_addr=i_memory_addr_o;
				rt_to_memory=i_rt_o;		
				end
			else
				begin
				o_rtaddr_e = i_rtaddr_e;
				o_rt_e = i_rt_e;
				o_wreg_e = i_wreg_e;
				o_rtaddr_o = i_rtaddr_o;
				o_rt_o = i_rt_o;
				o_wreg_o = i_wreg_o;
				end
		end
	end
			
endmodule