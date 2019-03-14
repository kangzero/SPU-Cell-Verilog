//**************************************************************************************/
// Module:  	SPU
// File:    	spu.v
// Description: the top file of SPU
// History: 	Created by Ning Kang, Mar 30, 2018 
//		Modify by Ning Kang, Apr 25, 2018 - correct the connection between ID/EX
//***************************************************************************************/

`include "defines.v"

module SPU(

	input wire clk,
	input wire rst,
 
	//stall request from cache
	input wire  stallreq_fr_cache,   
	//input wire[`REG_BUS128] rom_data_i,
	input wire[`INST2_BUS64] rom_data_i,
	//output wire[`REG_BUS128] rom_addr_o,
	output wire[`INST_ADDR_BUS32] rom_addr_o,
	input wire[`MEMORY_WIDTH32] i_memory_addr_o,
	input wire[`REG_BUS128] rt_from_memory,
	output wire[0:31] mem_data_addr,
	output wire write_memory_enable,
	output wire[`REG_BUS128] rt_to_memory,
	output wire rom_ce_o
	
);

	wire[`INST_ADDR_BUS32] pc;
	wire[`INST_ADDR_BUS32] id_pc_i;
	wire[`INST2_BUS64] id_inst_i;
	
	//connection between the output of ID and the input of ID/EX
	wire[10:0] id_opcode_e;
	wire[`REG_BUS128] id_ra_e;
	wire[`REG_BUS128] id_rb_e;
	wire[`REG_ADDR_BUS7] id_rtaddr_e;
	wire id_wreg_e;
	//wire id_even;
	wire[0:2] id_uid_e;

	wire[0:10] id_opcode_o;
	wire[`REG_BUS128] id_ra_o;
	wire[`REG_BUS128] id_rb_o;
	wire[`REG_ADDR_BUS7] id_rtaddr_o;
	wire id_wreg_o;
	wire[0:9] id_imm_o;
	//wire id_odd;
	wire[0:2] id_uid_o;

	wire is_in_delayslot;

	wire[0:31] id_link_addr_o;
	wire id_is_in_delayslot_o;
	wire id_next_inst_in_delayslot_o;
	wire[0:31] id_branch_target_addr_o;
	wire id_branch_flag_o;

	wire[0:31] id_pc;
	wire[0:31] inst_l;
	wire[0:31] inst_h;

	wire pipe_l;
	wire pipe_h;

	//connection between the output of ID/EX and the input of EX(ODD&EVEN)
	wire[0:10] iex_opcode_e;
	wire[`REG_BUS128] iex_ra_e;
	wire[`REG_BUS128] iex_rb_e;
	wire[`REG_ADDR_BUS7] iex_rtaddr_e;
	wire[0:2] iex_uid_e;
	wire iex_wreg_e;

	wire[0:10] iex_opcode_o;
	wire[`REG_BUS128] iex_ra_o;
	wire[`REG_BUS128] iex_rb_o;
	wire[`REG_ADDR_BUS7] iex_rtaddr_o;
	wire[0:2] iex_uid_o;
	wire[0:9] iex_imm_o;
	wire iex_wreg_o;

	wire[0:31] ex_pc;
	wire[0:31] ex_inst_l;
	wire[0:31] ex_inst_h;

	wire[0:31] ex_link_addr;
	wire ex_is_in_delayslot;
	wire[0:31] ex_branch_target_addr;
	wire ex_branch_flag;

	//connection between ID/EX and ID
	wire is_in_delayslot_o;

	//connection between the output of EX and the input of EX/FF
	wire[`REG_BUS128] oex_rt_e;
	wire[`REG_ADDR_BUS7] oex_rtaddr_e;
	wire oex_wreg_e;
	wire[0:2] oex_uid_e;

	wire[`REG_BUS128] oex_rt_o;
	wire[`REG_ADDR_BUS7] oex_rtaddr_o;
	wire oex_wreg_o;
	wire[0:2] oex_uid_o;
	wire[0:31]oex_memory_addr_o;	

	wire[0:31] o_ex_pc;
	wire[0:31] o_ex_link_addr;
	wire o_ex_is_in_delayslot;
	wire[0:31] o_ex_branch_target_addr;
	wire o_ex_branch_flag;

	//connection between the output of EX/FF and the input of FF1
	wire iff1_wreg_e;
	wire[`REG_ADDR_BUS7] iff1_rtaddr_e;
	wire[`REG_BUS128] iff1_rt_e;
	wire[0:2] iff1_uid_e;

	wire iff1_wreg_o;
	wire[`REG_ADDR_BUS7] iff1_rtaddr_o;
	wire[`REG_BUS128] iff1_rt_o;
	wire[0:2] iff1_uid_o;
	wire[0:31] iff1_memory_addr_o;

	wire iff1_branch_flag;
	wire[0:31] iff1_branch_target_addr;
	wire[0:31] iff1_link_addr;
	wire iff1_is_in_delayslot;

	//connection between the output of FF1 and the input of FF2
	wire iff2_wreg_e;
	wire[`REG_ADDR_BUS7] iff2_rtaddr_e;
	wire[`REG_BUS128] iff2_rt_e;
	wire[0:2] iff2_uid_e;
	wire[0:31] iff2_memory_addr_o;

	wire iff2_wreg_o;
	wire[`REG_ADDR_BUS7] iff2_rtaddr_o;
	wire[`REG_BUS128] iff2_rt_o;
	wire[0:2] iff2_uid_o;

	wire iff2_branch_flag;
	wire[0:31] iff2_branch_target_addr;
	wire[0:31] iff2_link_addr;
	wire iff2_is_in_delayslot;

	//connection between the output of FF2 and the input of FF3
	wire iff3_wreg_e;
	wire[`REG_ADDR_BUS7] iff3_rtaddr_e;
	wire[`REG_BUS128] iff3_rt_e;
	wire[0:2] iff3_uid_e;

	wire iff3_wreg_o;
	wire[`REG_ADDR_BUS7] iff3_rtaddr_o;
	wire[`REG_BUS128] iff3_rt_o;
	wire[0:2] iff3_uid_o;
	wire[0:31] iff3_memory_addr_o;

	wire iff3_branch_flag;
	wire[0:31] iff3_branch_target_addr;
	wire[0:31] iff3_link_addr;
	wire iff3_is_in_delayslot;

	//connection between the output of FF3 and the input of FF4
	wire iff4_wreg_e;
	wire[`REG_ADDR_BUS7] iff4_rtaddr_e;
	wire[`REG_BUS128] iff4_rt_e;
	wire[0:2] iff4_uid_e;

	wire iff4_wreg_o;
	wire[`REG_ADDR_BUS7] iff4_rtaddr_o;
	wire[`REG_BUS128] iff4_rt_o;
	wire[0:2] iff4_uid_o;
	wire[0:31]iff4_memory_addr_o;

	wire iff4_branch_flag;
	wire[0:31] iff4_branch_target_addr;
	wire[0:31] iff4_link_addr;
	wire iff4_is_in_delayslot;

	//connection between the output of FF4 and the input of FF5
	wire iff5_wreg_e;
	wire[`REG_ADDR_BUS7] iff5_rtaddr_e;
	wire[`REG_BUS128] iff5_rt_e;

	wire iff5_wreg_o;
	wire[`REG_ADDR_BUS7] iff5_rtaddr_o;
	wire[`REG_BUS128] iff5_rt_o;
	wire[0:2] iff5_uid_o;
	wire[0:31] iff5_memory_addr_o;

	//connection between the output of FF5 and the input of FF6
	wire iff6_wreg_e;
	wire[`REG_ADDR_BUS7] iff6_rtaddr_e;
	wire[`REG_BUS128] iff6_rt_e;

	wire iff6_wreg_o;
	wire[`REG_ADDR_BUS7] iff6_rtaddr_o;
	wire[`REG_BUS128] iff6_rt_o;
	wire[0:2] iff6_uid_o;
	wire[0:31]iff6_memory_addr_o;

	//connection between the output of FF6 and the input of FF7
	wire iff7_wreg_e;
	wire[`REG_ADDR_BUS7] iff7_rtaddr_e;
	wire[`REG_BUS128] iff7_rt_e;

	wire iff7_wreg_o;
	wire[`REG_ADDR_BUS7] iff7_rtaddr_o;
	wire[`REG_BUS128] iff7_rt_o;
	wire[0:2] iff7_uid_o;
	wire[0:31]iff7_memory_addr_o;

	//connection between the output of FF7 and the input of FF/MEM
	wire off7_wreg_e;
	wire[`REG_ADDR_BUS7] off7_rtaddr_e;
	wire[`REG_BUS128] off7_rt_e;

	wire off7_wreg_o;
	wire[`REG_ADDR_BUS7] off7_rtaddr_o;
	wire[`REG_BUS128] off7_rt_o;
	wire[0:31]off7_memory_addr_o;
	wire[0:2] off7_uid_o;
	//connection between the output of FF/MEM and the input of MEM
	wire imem_wreg_e;
	wire[`REG_ADDR_BUS7] imem_rtaddr_e;
	wire[`REG_BUS128] imem_rt_e;

	wire imem_wreg_o;
	wire[`REG_ADDR_BUS7] imem_rtaddr_o;
	wire[`REG_BUS128] imem_rt_o;
	wire[0:31]imem_memory_addr_o;
	wire[0:2] imem_uid_o;
	//connection between the output of MEM and the input of MEM/WB
	wire omem_wreg_e;
	wire[`REG_ADDR_BUS7] omem_rtaddr_e;
	wire[`REG_BUS128] omem_rt_e;

	wire omem_wreg_o;
	wire[`REG_ADDR_BUS7] omem_rtaddr_o;
	wire[`REG_BUS128] omem_rt_o;

	//connection between the output of MEM/WB and the input of WB
	wire iwb_wreg_e;
	wire[`REG_ADDR_BUS7] iwb_rtaddr_e;
	wire[`REG_BUS128] iwb_rt_e;
	
	wire iwb_wreg_o;
	wire[`REG_ADDR_BUS7] iwb_rtaddr_o;
	wire[`REG_BUS128] iwb_rt_o;

	//connection between I/O of ID and I/O of Regfile
 	wire ira_rd_e;
  	wire irb_rd_e;
  	wire[`REG_BUS128] ora_data_e;
  	wire[`REG_BUS128] orb_data_e;
  	wire[`REG_ADDR_BUS7] ira_addr_e;
 	wire[`REG_ADDR_BUS7] irb_addr_e;

  	wire ira_rd_o;
  	wire irb_rd_o;
  	wire[`REG_BUS128] ora_data_o;
  	wire[`REG_BUS128] orb_data_o;
  	wire[`REG_ADDR_BUS7] ira_addr_o;
 	wire[`REG_ADDR_BUS7] irb_addr_o;

	//connection between CTRL and multiple modules
	wire [0:12] stall;
	wire stallreq_fr_id;
	wire stallreq_fr_ex;
	wire stallreq_dh;

	//connection between FF4 and PC_REG
	wire branch_flag;
	wire[0:31] branch_target_addr;

	//pc_reg
	PC_REG pc_reg(
		.clk(clk),
		.rst(rst),
		.stall(stall),
		.id_pc(id_pc),
		.branch_flag_i(branch_flag),
		//.branch_clr(branch_clr),
		.branch_target_addr_i(branch_target_addr), 
		//.branch_target_addr_i(iff4_branch_target_addr),
		.pc(pc),
		.ce(rom_ce_o)	
			
	);

	assign rom_addr_o = pc;

  	//IF/ID
	IF_ID if_id(
		.clk(clk),
		.rst(rst),
		.if_pc(pc),
		.if_inst(rom_data_i),
		.stall(stall),
		.pipe_l(pipe_l),
		.pipe_h(pipe_h),
		.id_pc(id_pc_i),
		.id_inst(id_inst_i)      	
	);

	//ID
	ID id(
		.rst(rst),
		.clk(clk),
		.pc_i(id_pc_i),
		.inst_i(id_inst_i),
		
		//from FF network
		.ex_wreg_i_e(oex_wreg_e),
		.ex_wdata_i_e(oex_rt_e),
		.ex_waddr_i_e(oex_rtaddr_e),

		.ff1_wreg_i_e(iff2_wreg_i_e),
		.ff1_rt_e(iff2_rt_e),
		.ff1_waddr_i_e(iff2_waddr_i_e),

		.ff2_wreg_i_e(iff3_wreg_i_e),
		.ff2_rt_e(iff3_rt_e),
		.ff2_waddr_i_e(iff3_waddr_i_e),

		.ff3_wreg_i_e(iff4_wreg_i_e),
		.ff3_rt_e(iff4_rt_e),
		.ff3_waddr_i_e(iff4_waddr_i_e),

		.ff4_wreg_i_e(iff5_wreg_i_e),
		.ff4_rt_e(iff5_rt_e),
		.ff4_waddr_i_e(iff5_waddr_i_e),

		.ff6_wreg_i_e(iff7_wreg_i_e),
		.ff6_rt_e(iff7_rt_e),
		.ff6_waddr_i_e(iff7_waddr_i_e),

		.ff7_wreg_i_e(off7_wreg_i_e),
		.ff7_rt_e(off7_rt_e),
		.ff7_waddr_i_e(off7_waddr_i_e),

		.ex_wreg_i_o(oex_wreg_o),
		.ex_wdata_i_o(oex_rt_o),
		.ex_waddr_i_o(oex_rtaddr_o),

		.ff1_wreg_i_o(iff2_wreg_i_o),
		.ff1_rt_o(iff2_rt_o),
		.ff1_waddr_i_o(iff2_waddr_i_o),

		.ff2_wreg_i_o(iff3_wreg_i_o),
		.ff2_rt_o(iff3_rt_o),
		.ff2_waddr_i_o(iff3_waddr_i_o),

		.ff3_wreg_i_o(iff4_wreg_i_o),
		.ff3_rt_o(iff4_rt_o),
		.ff3_waddr_i_o(iff4_waddr_i_o),

		.ff4_wreg_i_o(iff5_wreg_i_o),
		.ff4_rt_o(iff5_rt_o),
		.ff4_waddr_i_o(iff5_waddr_i_o),

		.ff6_wreg_i_o(iff7_wreg_i_o),
		.ff6_rt_o(iff7_rt_o),
		.ff6_waddr_i_o(iff7_waddr_i_o),

		.ff7_wreg_i_o(off7_wreg_i_o),
		.ff7_rt_o(off7_rt_o),
		.ff7_waddr_i_o(off7_waddr_i_o),

		//from mem
		.mem_wreg_i_e(omem_wreg_e),
		.mem_wdata_i_e(omem_rt_e),
		.mem_waddr_i_e(omem_rtaddr_e),
		.mem_wreg_i_o(omem_wreg_o),
		.mem_wdata_i_o(omem_rt_o),
		.mem_waddr_i_o(omem_rtaddr_o),


		//from register file
		.ra_i_e(ora_data_e),
		.rb_i_e(orb_data_e), 	  

		.ra_i_o(ora_data_o),
		.rb_i_o(orb_data_o), 

		//from ID_EX
		.is_in_delayslot_i(is_in_delayslot),
		
		//to ID_EX
		.link_addr_o(id_link_addr_o),
		.is_in_delayslot_o(id_is_in_delayslot_o),
		.next_inst_in_delayslot_o(id_next_inst_in_delayslot_o),
		.branch_target_addr_o(id_branch_target_addr_o),
		.branch_flag_o(id_branch_flag_o),

		//to ID_EX
		.id_pc(id_pc),
		.inst_l(inst_l),
		.inst_h(inst_h),
		

		//to register file
		.ra_rd_e(ira_rd_e),
		.rb_rd_e(irb_rd_e),
		.ra_addr_e(ira_addr_e),
		.rb_addr_e(irb_addr_e),

		.ra_rd_o(ira_rd_o),
		.rb_rd_o(irb_rd_o),
		.ra_addr_o(ira_addr_o),
		.rb_addr_o(irb_addr_o),

		//info send to id/exe
		.op_code_e(id_opcode_e),
		.ra_do_e(id_ra_e),
		.rb_do_e(id_rb_e),
		.rt_addr_e(id_rtaddr_e),
		.wreg_e(id_wreg_e),
		//.even(id_even),
		.uid_e(id_uid_e),

		.op_code_o(id_opcode_o),
		.ra_do_o(id_ra_o),
		.rb_do_o(id_rb_o),
		.rt_addr_o(id_rtaddr_o),
		.wreg_o(id_wreg_o),
		//.odd(id_odd),
		.uid_o(id_uid_o),
		.im_o(id_imm_o),
		.pipe_l(pipe_l),
		.pipe_h(pipe_h),
		.stallreq(stallreq_fr_id),
		.stallreq_dh(stallreq_dh)
	);

 	//Regfile
	REGFILE regfile(
		.clk (clk),
		.rst (rst),
		.rt_we_e(iwb_wreg_e),
		.rt_addr_e (iwb_rtaddr_e),
		.rt_data_e (iwb_rt_e),
		.ra_e_e (ira_rd_e),
		.ra_addr_e (ira_addr_e),
		.ra_data_e (ora_data_e),
		.rb_e_e (irb_rd_e),
		.rb_addr_e (irb_addr_e),
		.rb_data_e (orb_data_e),

		.rt_we_o(iwb_wreg_o),
		.rt_addr_o (iwb_rtaddr_o),
		.rt_data_o (iwb_rt_o),
		.ra_e_o (ira_rd_o),
		.ra_addr_o (ira_addr_o),
		.ra_data_o (ora_data_o),
		.rb_e_o (irb_rd_o),
		.rb_addr_o (irb_addr_o),
		.rb_data_o (orb_data_o)
	);

	//ID/EX
	ID_EX id_ex(
		.clk(clk),
		.rst(rst),
		
		//from ID
		.id_pc(id_pc),
		.id_inst_l(inst_l),
		.id_inst_h(inst_h),

		.id_opcode_e(id_opcode_e),
		.id_ra_e(id_ra_e),
		.id_rb_e(id_rb_e),
		.id_rtaddr_e(id_rtaddr_e),
		.id_uid_e(id_uid_e),
		.id_wreg_e(id_wreg_e),

		.id_opcode_o(id_opcode_o),
		.id_ra_o(id_ra_o),
		.id_rb_o(id_rb_o),
		.id_rtaddr_o(id_rtaddr_o),
		.id_uid_o(id_uid_o),
		.id_wreg_o(id_wreg_o),
		.id_imm_o(id_imm_o),
		
		.id_link_addr(id_link_addr_o),
		.id_is_in_delayslot(id_is_in_delayslot_o),
		.id_next_inst_in_delayslot(id_next_inst_in_delayslot_o),
		.id_branch_target_addr(id_branch_target_addr_o),
		.id_branch_flag(id_branch_flag_o),

		//from CTRL
		.stall(stall),

		//to EX
		.ex_pc(ex_pc),
		.ex_inst_l(ex_inst_l),
		.ex_inst_h(ex_inst_h),

		.ex_opcode_e(iex_opcode_e),
		.ex_ra_e(iex_ra_e),
		.ex_rb_e(iex_rb_e),
		.ex_rtaddr_e(iex_rtaddr_e),
		.ex_wreg_e(iex_wreg_e),
		.ex_uid_e(iex_uid_e),

		.ex_opcode_o(iex_opcode_o),
		.ex_ra_o(iex_ra_o),
		.ex_rb_o(iex_rb_o),
		.ex_rtaddr_o(iex_rtaddr_o),
		.ex_wreg_o(iex_wreg_o),
		.ex_uid_o(iex_uid_o),
		.ex_imm_o(iex_imm_o),

		.ex_link_addr(ex_link_addr),
		.ex_is_in_delayslot(ex_is_in_delayslot),
		.ex_branch_target_addr(ex_branch_target_addr),
		.ex_branch_flag(ex_branch_flag),
		
		// to ID
		.is_in_delayslot_o(is_in_delayslot)
	);		

	//EX
	EX_EVEN ex_even(
		.rst(rst),
		.clk(clk),

		//from ID_EX
		.i_opcode_e(iex_opcode_e),
		.i_ra_e(iex_ra_e),
		.i_rb_e(iex_rb_e),
		.i_rtaddr_e(iex_rtaddr_e),
		.i_wreg_e(iex_wreg_e),
		.i_uid_e(iex_uid_e),

		//to EX_FF
		.o_rtaddr_e(oex_rtaddr_e),
		.o_wreg_e(oex_wreg_e),
		.o_rt_e(oex_rt_e),
		.o_uid_e(oex_uid_e)
	);

	EX_ODD ex_odd(
		.rst(rst),
		.clk(clk),

		//from ID_EX
		.i_opcode_o(iex_opcode_o),
		.i_ra_o(iex_ra_o),
		.i_rb_o(iex_rb_o),
		.i_rtaddr_o(iex_rtaddr_o),
		.i_wreg_o(iex_wreg_o),
		.i_uid_o(iex_uid_o),
		.i_imm_o(iex_imm_o),

		.i_pc(ex_pc),
		.i_ex_link_addr(ex_link_addr),
		.i_ex_id_is_in_delayslot(ex_is_in_delayslot),
		.i_ex_branch_target_addr(ex_branch_target_addr),
		.i_ex_branch_flag(ex_branch_flag),

	 	//EX to EX/FF
		.o_rtaddr_o(oex_rtaddr_o),
		.o_wreg_o(oex_wreg_o),
		.o_rt_o(oex_rt_o),
		.o_uid_o(oex_uid_o),
		.o_memory_addr_o(oex_memory_addr_o),


		.ex_pc(o_ex_pc),
		.o_ex_link_addr(o_ex_link_addr),
		.o_ex_is_in_delayslot(o_ex_is_in_delayslot),
		.o_ex_branch_target_addr(o_ex_branch_target_addr),
		.o_ex_branch_flag(o_ex_branch_flag)
	);

  	//EX_FF
  	EX_FF ex_ff(
		.clk(clk),
		.rst(rst),
	  
		//from EX
		.ex_rtaddr_e(oex_rtaddr_e),
		.ex_wreg_e(oex_wreg_e),
		.ex_rt_e(oex_rt_e),
		.ex_uid_e(oex_uid_e),
	
		.ex_rtaddr_o(oex_rtaddr_o),
		.ex_wreg_o(oex_wreg_o),
		.ex_rt_o(oex_rt_o),
		.ex_uid_o(oex_uid_o),
		.ex_memory_addr_o(oex_memory_addr_o),

		.ex_link_addr(o_ex_link_addr),
		.ex_is_in_delayslot(o_ex_is_in_delayslot),
		.ex_branch_target_addr(o_ex_branch_target_addr),
		.ex_branch_flag(o_ex_branch_flag),

		//to FF1
		.ff_rtaddr_e(iff1_rtaddr_e),
		.ff_wreg_e(iff1_wreg_e),
		.ff_rt_e(iff1_rt_e),
		.ff_uid_e(iff1_uid_e),

		.ff_rtaddr_o(iff1_rtaddr_o),
		.ff_wreg_o(iff1_wreg_o),
		.ff_rt_o(iff1_rt_o),
		.ff_uid_o(iff1_uid_o),
		.ff_memory_addr_o(iff1_memory_addr_o),
		
		.ff_branch_flag(iff1_branch_flag),
		.ff_branch_target_addr(iff1_branch_target_addr),
		.ff_link_addr(iff1_link_addr),
		.ff_is_in_delayslot(iff1_is_in_delayslot)
	);

  	//FF1
  	FF1 ff1(
		.clk(clk),
		.rst(rst),
	  
		//from EX_FF
		.iff_rtaddr_e(iff1_rtaddr_e),
		.iff_wreg_e(iff1_wreg_e),
		.iff_rt_e(iff1_rt_e),
		.iff_uid_e(iff1_uid_e),
	
		.iff_rtaddr_o(iff1_rtaddr_o),
		.iff_wreg_o(iff1_wreg_o),
		.iff_rt_o(iff1_rt_o),
		.iff_uid_o(iff1_uid_o),
		.iff_memory_addr_o(iff1_memory_addr_o),
		
		.iff_branch_flag(iff1_branch_flag),
		.iff_branch_target_addr(iff1_branch_target_addr),
		.iff_link_addr(iff1_link_addr),
		.iff_is_in_delayslot(iff1_is_in_delayslot),

		//to FF2
		.ff1_rtaddr_e(iff2_rtaddr_e),
		.ff1_wreg_e(iff2_wreg_e),
		.ff1_rt_e(iff2_rt_e),
		.ff1_uid_e(iff2_uid_e),

		.ff1_rtaddr_o(iff2_rtaddr_o),
		.ff1_wreg_o(iff2_wreg_o),
		.ff1_rt_o(iff2_rt_o),
		.ff1_uid_o(iff2_uid_o),
		.ff1_memory_addr_o(iff2_memory_addr_o),
		
		.ff1_branch_flag(iff2_branch_flag),
		.ff1_branch_target_addr(iff2_branch_target_addr),
		.ff1_link_addr(iff2_link_addr),
		.ff1_is_in_delayslot(iff2_is_in_delayslot) 	
	);

  	//FF2
  	FF2 ff2(
		.clk(clk),
		.rst(rst),
	  
		//from FF1
		.iff2_rtaddr_e(iff2_rtaddr_e),
		.iff2_wreg_e(iff2_wreg_e),
		.iff2_rt_e(iff2_rt_e),
		.iff2_uid_e(iff2_uid_e),
	
		.iff2_rtaddr_o(iff2_rtaddr_o),
		.iff2_wreg_o(iff2_wreg_o),
		.iff2_rt_o(iff2_rt_o),
		.iff2_uid_o(iff2_uid_o),
		.iff2_memory_addr_o(iff2_memory_addr_o),
		
		.iff2_branch_flag(iff2_branch_flag),
		.iff2_branch_target_addr(iff2_branch_target_addr),
		.iff2_link_addr(iff2_link_addr),
		.iff2_is_in_delayslot(iff2_is_in_delayslot),

		//to FF3
		.ff2_rtaddr_e(iff3_rtaddr_e),
		.ff2_wreg_e(iff3_wreg_e),
		.ff2_rt_e(iff3_rt_e),
		.ff2_uid_e(iff3_uid_e),

		.ff2_rtaddr_o(iff3_rtaddr_o),
		.ff2_wreg_o(iff3_wreg_o),
		.ff2_rt_o(iff3_rt_o),   
		.ff2_uid_o(iff3_uid_o),	
		.ff2_memory_addr_o(iff3_memory_addr_o),
		
		.ff2_branch_flag(iff3_branch_flag),
		.ff2_branch_target_addr(iff3_branch_target_addr),
		.ff2_link_addr(iff3_link_addr),
		.ff2_is_in_delayslot(iff3_is_in_delayslot) 	
	);

  	//FF3
  	FF3 ff3(
		.clk(clk),
		.rst(rst),
	  
		//from FF2
		.iff3_rtaddr_e(iff3_rtaddr_e),
		.iff3_wreg_e(iff3_wreg_e),
		.iff3_rt_e(iff3_rt_e),
		.iff3_uid_e(iff3_uid_e),
	
		.iff3_rtaddr_o(iff3_rtaddr_o),
		.iff3_wreg_o(iff3_wreg_o),
		.iff3_rt_o(iff3_rt_o),
		.iff3_uid_o(iff3_uid_o),
		.iff3_memory_addr_o(iff3_memory_addr_o),
		
		.iff3_branch_flag(iff3_branch_flag),
		.iff3_branch_target_addr(iff3_branch_target_addr),
		.iff3_link_addr(iff3_link_addr),
		.iff3_is_in_delayslot(iff3_is_in_delayslot),

		//to FF4
		.ff3_rtaddr_e(iff4_rtaddr_e),
		.ff3_wreg_e(iff4_wreg_e),
		.ff3_rt_e(iff4_rt_e),
		.ff3_uid_e(iff4_uid_e),

		.ff3_rtaddr_o(iff4_rtaddr_o),
		.ff3_wreg_o(iff4_wreg_o),
		.ff3_rt_o(iff4_rt_o),
		.ff3_uid_o(iff4_uid_o),
		.ff3_memory_addr_o(iff4_memory_addr_o),

		.ff3_branch_flag(iff4_branch_flag),
		.ff3_branch_target_addr(iff4_branch_target_addr),
		.ff3_link_addr(iff4_link_addr),
		.ff3_is_in_delayslot(iff4_is_in_delayslot) 	
	);

  	//FF4
  	FF4 ff4(
		.clk(clk),
		.rst(rst),
	  
		//from FF3
		.iff4_rtaddr_e(iff4_rtaddr_e),
		.iff4_wreg_e(iff4_wreg_e),
		.iff4_rt_e(iff4_rt_e),
		.iff4_uid_e(iff4_uid_e),
	
		.iff4_rtaddr_o(iff4_rtaddr_o),
		.iff4_wreg_o(iff4_wreg_o),
		.iff4_rt_o(iff4_rt_o),
		.iff4_uid_o(iff4_uid_o),
		.iff4_memory_addr_o(iff4_memory_addr_o),
		
		.iff4_branch_flag(iff4_branch_flag),
		.iff4_branch_target_addr(iff4_branch_target_addr),
		.iff4_link_addr(iff4_link_addr),
		.iff4_is_in_delayslot(iff4_is_in_delayslot),

		//to FF5
		.ff4_rtaddr_e(iff5_rtaddr_e),
		.ff4_wreg_e(iff5_wreg_e),
		.ff4_rt_e(iff5_rt_e),
		.ff4_uid_e(iff5_uid_e),

		.ff4_rtaddr_o(iff5_rtaddr_o),
		.ff4_wreg_o(iff5_wreg_o),
		.ff4_rt_o(iff5_rt_o),
		.ff4_uid_o(iff5_uid_o),
		.ff4_memory_addr_o(iff5_memory_addr_o),
		
		.ff4_branch_flag(branch_flag),
		.ff4_branch_target_addr(branch_target_addr),
		.ff4_is_in_delayslot(iff4_is_in_delayslot)
	);

  	//FF5
  	FF5 ff5(
		.clk(clk),
		.rst(rst),
	  
		//from FF4
		.iff5_rtaddr_e(iff5_rtaddr_e),
		.iff5_wreg_e(iff5_wreg_e),
		.iff5_rt_e(iff5_rt_e),
		.iff5_uid_e(iff5_uid_e),
	
		.iff5_rtaddr_o(iff5_rtaddr_o),
		.iff5_wreg_o(iff5_wreg_o),
		.iff5_rt_o(iff5_rt_o),
		.iff5_uid_o(iff5_uid_o),
		.iff5_memory_addr_o(iff5_memory_addr_o),

		//to FF6
		.ff5_rtaddr_e(iff6_rtaddr_e),
		.ff5_wreg_e(iff6_wreg_e),
		.ff5_rt_e(iff6_rt_e),
		.ff5_uid_e(iff6_uid_e),

		.ff5_rtaddr_o(iff6_rtaddr_o),
		.ff5_wreg_o(iff6_wreg_o),
		.ff5_rt_o(iff6_rt_o),
		.ff5_uid_o(iff6_uid_o),
		.ff5_memory_addr_o(iff6_memory_addr_o)
	);

  	//FF6
  	FF6 ff6(
		.clk(clk),
		.rst(rst),
	  
		//from FF4
		.iff6_rtaddr_e(iff6_rtaddr_e),
		.iff6_wreg_e(iff6_wreg_e),
		.iff6_rt_e(iff6_rt_e),
		.iff6_uid_e(iff6_uid_e),

		.iff6_rtaddr_o(iff6_rtaddr_o),
		.iff6_wreg_o(iff6_wreg_o),
		.iff6_rt_o(iff6_rt_o),
		.iff6_uid_o(iff6_uid_o),
		.iff6_memory_addr_o(iff6_memory_addr_o),
		
		//to FF6
		.ff6_rtaddr_e(iff7_rtaddr_e),
		.ff6_wreg_e(iff7_wreg_e),
		.ff6_rt_e(iff7_rt_e),
		.ff6_uid_e(iff7_uid_e),

		.ff6_rtaddr_o(iff7_rtaddr_o),
		.ff6_wreg_o(iff7_wreg_o),
		.ff6_rt_o(iff7_rt_o),
		.ff6_uid_o(iff7_uid_o),
		.ff6_memory_addr_o(iff7_memory_addr_o) 	
	);

  	//FF7
  	FF7 ff7(
		.clk(clk),
		.rst(rst),
	  
		//from FF6
		.iff7_rtaddr_e(iff7_rtaddr_e),
		.iff7_wreg_e(iff7_wreg_e),
		.iff7_rt_e(iff7_rt_e),
		.iff7_uid_e(iff7_uid_e),
	
		.iff7_rtaddr_o(iff7_rtaddr_o),
		.iff7_wreg_o(iff7_wreg_o),
		.iff7_rt_o(iff7_rt_o),
		.iff7_uid_o(iff7_uid_o),
		.iff7_memory_addr_o(iff7_memory_addr_o),
		
		//to FF/MEM
		.ff7_rtaddr_e(off7_rtaddr_e),
		.ff7_wreg_e(off7_wreg_e),
		.ff7_rt_e(off7_rt_e),
		.ff7_uid_e(off7_uid_e),

		.ff7_rtaddr_o(off7_rtaddr_o),
		.ff7_wreg_o(off7_wreg_o),
		.ff7_rt_o(off7_rt_o),
		.ff7_uid_o(off7_uid_o),
		.ff7_memory_addr_o(off7_memory_addr_o)    	
	);

	//FF_MEM
  	FF_MEM ff_mem(
		.clk(clk),
		.rst(rst),
	  
		//from FF
		.ff7_rtaddr_e(off7_rtaddr_e),
		.ff7_wreg_e(off7_wreg_e),
		.ff7_rt_e(off7_rt_e),
		.ff7_uid_e(off7_uid_e),

		.ff7_rtaddr_o(off7_rtaddr_o),
		.ff7_wreg_o(off7_wreg_o),
		.ff7_rt_o(off7_rt_o),
		.ff7_uid_o(off7_uid_o),
		.ff7_memory_addr_o(off7_memory_addr_o),

		//from CTRL
		.stall(stall),

		//to MEM
		.mem_rtaddr_e(imem_rtaddr_e),
		.mem_wreg_e(imem_wreg_e),
		.mem_rt_e(imem_rt_e),

		.mem_rtaddr_o(imem_rtaddr_o),
		.mem_wreg_o(imem_wreg_o),
		.mem_rt_o(imem_rt_o),
		.mem_uid_o(imem_uid_o),
		.mem_memory_addr_o(imem_memory_addr_o)			       	
	);

  	//MEM
	MEM mem(
		.rst(rst),
	
		//from FF/MEM
		.i_rtaddr_e(imem_rtaddr_e),
		.i_wreg_e(imem_wreg_e),
		.i_rt_e(imem_rt_e),
	
		.i_rtaddr_o(imem_rtaddr_o),
		.i_wreg_o(imem_wreg_o),
		.i_rt_o(imem_rt_o),
		.i_memory_addr_o(imem_memory_addr_o),
		.rt_from_memory(rt_from_memory),
		.i_uid_o(imem_uid_o),
		//to MEM/WB
		.o_rtaddr_e(omem_rtaddr_e),
		.o_wreg_e(omem_wreg_e),
		.o_rt_e(omem_rt_e),

		.o_rtaddr_o(omem_rtaddr_o),
		.o_wreg_o(omem_wreg_o),
		.o_rt_o(omem_rt_o),
		.write_memory_enable(write_memory_enable),
		.rt_to_memory(rt_to_memory),
		.mem_data_addr(mem_data_addr)
	);

  	//MEM/WB
	MEM_WB mem_wb(
		.clk(clk),
		.rst(rst),
 
		//from MEM
		.mem_rtaddr_e(omem_rtaddr_e),
		.mem_wreg_e(omem_wreg_e),
		.mem_rt_e(omem_rt_e),
  
		.mem_rtaddr_o(omem_rtaddr_o),
		.mem_wreg_o(omem_wreg_o),
		.mem_rt_o(omem_rt_o),

		//from CTRL
		.stall(stall),
	
		//to Write back
		.wb_rtaddr_e(iwb_rtaddr_e),
		.wb_wreg_e(iwb_wreg_e),
		.wb_rt_e(iwb_rt_e),

		.wb_rtaddr_o(iwb_rtaddr_o),
		.wb_wreg_o(iwb_wreg_o),
		.wb_rt_o(iwb_rt_o)
	);

	CTRL ctrl(
		.rst(rst),
		.stallreq_fr_id(stallreq_fr_id),
		.stallreq_fr_ex(stallreq_fr_ex),
		.stallreq_fr_cache(stallreq_fr_cache),
		.stallreq_dh(stallreq_dh),
		.stall(stall)
	);

endmodule