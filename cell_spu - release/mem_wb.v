//**************************************************************************************/
// Module:  	MEM_WB
// File:    	mem_wb.v
// Description: The stage of memory access
// History: 	Created by Ning Kang, Mar 28, 2018 
//***************************************************************************************/

`include "defines.v"

module MEM_WB(

	input wire clk,
	input wire rst,
	
	//info from memory
	input wire[`REG_ADDR_BUS7] mem_rtaddr_e,
	input wire mem_wreg_e,
	input wire[`REG_BUS128] mem_rt_e, 	
	
	input wire[`REG_ADDR_BUS7] mem_rtaddr_o,
	input wire mem_wreg_o,
	input wire[`REG_BUS128] mem_rt_o,

	input wire[0:12] stall, 

	//info for write back 
	output reg[`REG_ADDR_BUS7] wb_rtaddr_e,
	output reg wb_wreg_e,
	output reg[`REG_BUS128] wb_rt_e,
	
	output reg[`REG_ADDR_BUS7] wb_rtaddr_o,
	output reg wb_wreg_o,
	output reg[`REG_BUS128] wb_rt_o       
	
);

	always @ (posedge clk) begin
		if(rst == `RST_ENABLE) begin
			wb_rtaddr_e = `NOP_REG_ADDR;
			wb_rt_e = `ZERO_QWORD128;
			wb_wreg_e = `WR_DISABLE;
			wb_rtaddr_o = `NOP_REG_ADDR;
			wb_rt_o = `ZERO_QWORD128;
			wb_wreg_o = `WR_DISABLE;
		end else if(stall[11] == `STOP && stall[12] == `NOSTOP) begin
			wb_rtaddr_e = `NOP_REG_ADDR;
			wb_rt_e = `ZERO_QWORD128;
			wb_wreg_e = `WR_DISABLE;
			wb_rtaddr_o = `NOP_REG_ADDR;
			wb_rt_o = `ZERO_QWORD128;
			wb_wreg_o = `WR_DISABLE;		
		end else if(stall[12] == `NOSTOP) begin
			wb_rtaddr_e = mem_rtaddr_e;
			wb_rt_e = mem_rt_e;
			wb_wreg_e = mem_wreg_e;
			wb_rtaddr_o = mem_rtaddr_o;
			wb_rt_o = mem_rt_o;
			wb_wreg_o = mem_wreg_o;	
		end
	end
			

endmodule