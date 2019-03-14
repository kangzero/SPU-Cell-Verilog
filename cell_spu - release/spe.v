//**************************************************************************************/
// Module:  	SPE
// File:    	spe.v
// Description: the top level file of SPE
// History: 	Created by Ning Kang, Mar 31, 2018 
//		Modified by Ning Kang, Apr 20, 2018 - change ILB to Cache
//***************************************************************************************/

`include "defines.v"

module SPE(

	input wire clk,
	input wire rst
	
);

	//connect to Cache
	wire[`INST_ADDR_BUS32] inst_addr;
	wire[`INST2_BUS64] inst;
	wire rom_ce;
 	wire[`INST_ADDR_BUS32] pass_addr;
	wire[`INST_ADDR_BUS32] inst_from_memory;
	wire[`INST_ADDR_BUS32] addr_from_memory;
	wire  stallreq_fr_cache;
	wire[0:127] rt_data;
	
	wire[0:31] data_addr;
	wire write_memory_enable;
	wire[`REG_BUS128] rt_to_memory;

	SPU spu(
		.clk(clk),
		.rst(rst),
		
		.stallreq_fr_cache(stallreq_fr_cache),
		.rom_addr_o(inst_addr),
		.rom_data_i(inst),
		.rom_ce_o(rom_ce),
		.mem_data_addr(data_addr),
		.rt_from_memory(rt_data),
		.write_memory_enable(write_memory_enable),
		.rt_to_memory(rt_to_memory)
	);
	
	CACHE cache0(
		.clk(clk),
		.ce(rom_ce),
		.pc(inst_addr),
		.inst_from_memory(inst_from_memory),
		.addr_from_memory(addr_from_memory),
		.inst(inst),
		.miss(stallreq_fr_cache),
		.addr_to_memory(pass_addr)
	);
	MEMORY memory0(
		.clk(clk),
		.enable(rom_ce),
		.write_enable(write_memory_enable),
		.inst_addr(pass_addr),
		.inst_out(inst_from_memory),
		.inst_addr_to_cache(addr_from_memory),
		.data_addr(data_addr),
		.data_out(rt_data),
		.data_in(rt_to_memory)
		);


endmodule