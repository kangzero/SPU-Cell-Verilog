//**************************************************************************************/
// Module:  	ID
// File:    	id.v
// Description: instruction decode
//		Issue Control allows to issue up to 2 instrunctions per cycle to nine 
//		execution units organized into 2 execution pipelines
//		1. Even: Simple fixed / Shift / Single Precision / Floating Integer / Byte
//		2. Odd: Permute / Local Store / Channel / Branch
// History: 	Created by Ning Kang, Mar 26, 2018 
//			- implemented dual issue feature
//			- implemented Cell SPU ISA features
//		Modify by Ning Kang, Apr 24, 2018
//			- Implemented all operation
//			- add output of stall request
//		MOdify by Ning Kang, Apr25, 2018
//			- Implemented data forwarding
//***************************************************************************************/

`include "defines.v"

module ID(
	input wire rst,  		// reset 
	input wire clk,			// SPU clock

	input wire[0:31] pc_i,		//pc address in decode stage
	input wire[0:63] inst_i,	//instruction (actually 2) in decode stage

	//Code start...added by Ning, Kang for data forwarding
	input wire ex_wreg_i_e,
	input wire [`REG_BUS128] ex_wdata_i_e,
	input wire [`REG_ADDR_BUS7] ex_waddr_i_e,

	input wire ff1_wreg_i_e,
	input wire [`REG_BUS128] ff1_rt_e,
	input wire [`REG_ADDR_BUS7] ff1_waddr_i_e,
	
	input wire ff2_wreg_i_e,
	input wire [`REG_BUS128] ff2_rt_e,
	input wire [`REG_ADDR_BUS7] ff2_waddr_i_e,

	input wire ff3_wreg_i_e,
	input wire [`REG_BUS128] ff3_rt_e,
	input wire [`REG_ADDR_BUS7] ff3_waddr_i_e,

	input wire ff4_wreg_i_e,
	input wire [`REG_BUS128] ff4_rt_e,
	input wire [`REG_ADDR_BUS7] ff4_waddr_i_e,

	input wire ff5_wreg_i_e,
	input wire [`REG_BUS128] ff5_rt_e,
	input wire [`REG_ADDR_BUS7] ff5_waddr_i_e,

	input wire ff6_wreg_i_e,
	input wire [`REG_BUS128] ff6_rt_e,
	input wire [`REG_ADDR_BUS7] ff6_waddr_i_e,

	input wire ff7_wreg_i_e,
	input wire [`REG_BUS128] ff7_rt_e,
	input wire [`REG_ADDR_BUS7] ff7_waddr_i_e,

	input wire ex_wreg_i_o,
	input wire [`REG_BUS128] ex_wdata_i_o,
	input wire [`REG_ADDR_BUS7] ex_waddr_i_o,

	input wire ff1_wreg_i_o,
	input wire [`REG_BUS128] ff1_rt_o,
	input wire [`REG_ADDR_BUS7] ff1_waddr_i_o,

	input wire ff2_wreg_i_o,
	input wire [`REG_BUS128] ff2_rt_o,
	input wire [`REG_ADDR_BUS7] ff2_waddr_i_o,

	input wire ff3_wreg_i_o,
	input wire [`REG_BUS128] ff3_rt_o,
	input wire [`REG_ADDR_BUS7] ff3_waddr_i_o,

	input wire ff4_wreg_i_o,
	input wire [`REG_BUS128] ff4_rt_o,
	input wire [`REG_ADDR_BUS7] ff4_waddr_i_o,

	input wire ff5_wreg_i_o,
	input wire [`REG_BUS128] ff5_rt_o,
	input wire [`REG_ADDR_BUS7] ff5_waddr_i_o,

	input wire ff6_wreg_i_o,
	input wire [`REG_BUS128] ff6_rt_o,
	input wire [`REG_ADDR_BUS7] ff6_waddr_i_o,

	input wire ff7_wreg_i_o,
	input wire [`REG_BUS128] ff7_rt_o,
	input wire [`REG_ADDR_BUS7] ff7_waddr_i_o,

	input wire mem_wreg_i_e,
	input wire [`REG_BUS128] mem_wdata_i_e,
	input wire [`REG_ADDR_BUS7] mem_waddr_i_e,
	input wire mem_wreg_i_o,
	input wire [`REG_BUS128] mem_wdata_i_o,
	input wire [`REG_ADDR_BUS7] mem_waddr_i_o,
	//Code end

	//from register file: ra / rb
	input wire[0:127] ra_i_e,	
	input wire[0:127] rb_i_e,

	input wire[0:127] ra_i_o,
	input wire[0:127] rb_i_o,

	//If last instruction is branch, then the present instruction decode will set it to 1, else false
	input wire is_in_delayslot_i,

	
	output reg[0:31] link_addr_o,
	output reg is_in_delayslot_o,
	output reg next_inst_in_delayslot_o,
	output reg[0:31] branch_target_addr_o,
	output reg branch_flag_o,

	//pc 
	output wire[0:31] id_pc,
	output wire[0:31] inst_l,
	output wire[0:31] inst_h,

	//info send to exe: ra, rb, rt, wr_en, opcode
	output reg[0:10] op_code_e, 	// even op code
	output reg[0:127] ra_do_e,	// even ra
	output reg[0:127] rb_do_e,	// even rb
	output reg[0:6] rt_addr_e,	// even rt address
	output reg wreg_e, 		// even wr enable
	output reg[0:2] uid_e,

	output reg[0:10] op_code_o,	// odd op code
	output reg[0:127] ra_do_o,	// odd ra
	output reg[0:127] rb_do_o,	// odd rb
	output reg[0:6] rt_addr_o,	// odd rt
	output reg wreg_o,		// odd wr enable
	output reg[0:2] uid_o,
	output reg[0:9] im_o,

	//output pipe_l, pipe_h: 1-odd, 0-even
	output reg pipe_l,
	output reg pipe_h,

	//info send to register file
	output reg[0:6] ra_addr_e,
	output reg[0:6] rb_addr_e,
	output reg ra_rd_e,
	output reg rb_rd_e,

	output reg[0:6] ra_addr_o,
	output reg[0:6] rb_addr_o,
	output reg ra_rd_o, rb_rd_o,

	//output reg[0:31] pc_e, pc_o,
	output reg stallreq,
	output reg stallreq_dh
);

	//split inst_i into even ins and odd ins
	//wire [0:31] inst_l, inst_h;
	assign inst_l = inst_i[0:31];
	assign inst_h = inst_i[32:63];

	assign id_pc = pc_i;

	//initia stallreq as no stop
	//assign stallreq = `NOSTOP;

	//obtian ins opcode
	wire [0:10] op_l = inst_l[0:10];
	wire [0:10] op_h = inst_h[0:10];

	reg[`REG_BUS128] imm_e, imm_o;
	//reg imm_e, imm_o;

	wire[0:63] pc_plus_8;
	wire[0:63] pc_plus_4;

	//assign pc_plus_8 = pc_i + 8;
	//assign pc_plus_4 = pc_i + 4;
	//reg stall_req_for_pipe_split;
	//assign stallreq = stall_req_for_pipe_split;
	//reg [0:9] ttt; // only for debug
	reg [0:7] b;
	reg [0:7] byte_t; 
	reg [0:15] hword_t;
	reg [0:31] word_t;

	always @ (*) begin
		casez (op_l)
			11'b00110100???: begin		//EXE_LQD
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_5;   //latency=6
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_LQD;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				imm_o <= {{22{inst_l[8]}},inst_l[8:17]};
				rt_addr_o <= inst_l[25:31];
			end
			11'b00100100???: begin		//EXE_STQD
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_6;   //latency=6
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_STQD;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_ENABLE;
				ra_addr_o <= inst_l[18:24];
				im_o <= inst_l[8:17];
				rb_addr_o <= inst_l[25:31];
			end
			11'b00011001000: begin		//EXE_AH
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];			
			end
			11'b00011101???: begin		//EXE_AHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; //HalfWord:16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00011000000: begin		//EXE_A
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_A;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00011100???: begin		//EXE_AI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = {{22{inst_l[8]}},inst_l[8:17]};//Word:32b
				imm_e <= {word_t,word_t,word_t,word_t}; 
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001001000: begin		//EXE_SFH
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001101???: begin		//EXE_SFHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]};//HalfWOrd: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t}; 
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001000000: begin		//EXE_SF
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SF;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001100???: begin		//EXE_SFI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = {{22{inst_l[8]}},inst_l[8:17]};
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111000100: begin		//EXE_MPY
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPY;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111001100: begin		//EXE_MPYU
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPYU;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01110100???: begin		//EXE_MPYI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPYI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; //Hword: 16b
				word_t = {16'h0000,hword_t};
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00011000001: begin		//EXE_AND
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AND;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00010110???: begin		//EXE_ANDBI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = (inst_l[8:17]&16'h00ff);
				imm_e <= {word_t,word_t,word_t,word_t}; // 8*4=32b
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00010101???: begin		//EXE_ANDHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; //Hwaord: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00010100???: begin		//EXE_ANDI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = {{22{inst_l[8]}},inst_l[8:17]}; //Word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001000001: begin		//EXE_OR
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_OR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00000110???: begin		//EXE_ORBI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = (inst_l[8:17]&16'h00ff); // 8*4=32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00000101???: begin		//EXE_ORHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; //Hword: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00000100???: begin		//EXE_ORI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = {{22{inst_l[8]}},inst_l[8:17]}; //word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];
			end
			11'b01001000001: begin		//EXE_XOR
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XOR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01000110???: begin		//EXE_XORBI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//imm_e <= {{22{inst_l[8]}},inst_l[8:17]};
				word_t = (inst_l[8:17]&32'h00ff);
				//b = (inst_l[8:17]&16'h00ff);
				imm_e <= {word_t,word_t,word_t,word_t}; // 8*4=32b
				rt_addr_e <= inst_l[25:31];
			end
			11'b01000101???: begin		//EXE_XORHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; //Hword:16b
				imm_e = {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];
			end
			11'b01000100???: begin		//EXE_XORI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t ={{22{inst_l[8]}},inst_l[8:17]}; //Word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];
			end
			11'b00011001001: begin		//EXE_NAND
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_NAND;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00001001001: begin		//EXE_NOR
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_NOR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00111011011: begin		//EXE_SHLQBI
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_SHLQBI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_ENABLE;
				ra_addr_o <= inst_l[18:24];
				rb_addr_o <= inst_l[11:17];
				rt_addr_o <= inst_l[25:31];	
			end
			11'b00111111011: begin		//EXE_SHLQBII
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_SHLQBII;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				//imm_o <= {{25{inst_l[11]}},inst_l[11:17]};
				imm_o <= inst_l[11:17];
				rt_addr_o <= inst_l[25:31];	
			end
			11'b00111011111: begin		//EXE_ROTQBY
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_ROTQBY;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_ENABLE;
				ra_addr_o <= inst_l[18:24];
				rb_addr_o <= inst_l[11:17];
				rt_addr_o <= inst_l[25:31];	
			end
			11'b00111111111: begin		//EXE_ROTQBYI
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_ROTQBYI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				imm_o <= inst_l[11:17];
				rt_addr_o <= inst_l[25:31];	
			end
			11'b00111110100: begin		//EXE_CBD
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_CBD;
				ra_rd_o <= `RD_ENABLE; 
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				imm_o <= inst_l[11:17];
				rt_addr_o <= inst_l[25:31];	
			end
			11'b01111010000: begin		//EXE_CEQB
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111110???: begin		//EXE_CEQBI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//imm_e <= inst_l[8:17];
				byte_t = (inst_l[10:17] & 8'hff); // I10 only need bit 2:9
				imm_e <= {byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111001000: begin		//EXE_CEQH
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111101???: begin		//EXE_CEQHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; // Extended to 16bits by replicating leftmost bit
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111000000: begin		//EXE_CEQ
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQ;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111100???: begin		//EXE_CEQI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				word_t = {{22{inst_l[8]}},inst_l[8:17]}; //Extended to 32bits by replicating leftmost bit
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001010000: begin		//EXE_CGTB
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001110???: begin		//EXE_CGTBI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//imm_e <= inst_l[8:17];
				byte_t = inst_l[10:17]; // I10 only need bit 2:9
				imm_e <= {byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001001000: begin		//EXE_CGTH
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001101???: begin		//EXE_CGTHI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//imm_e <= inst_l[8:17];
				hword_t = {{6{inst_l[8]}},inst_l[8:17]}; // Extended to 16bits by replicating leftmost bit
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001000000: begin		//EXE_CGT
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGT;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01001100???: begin		//EXE_CGTI
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTI;
				ra_rd_e <= `RD_ENABLE; //read imm from ra
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//imm_e <= inst_l[8:17];
				word_t = {{22{inst_l[8]}},inst_l[8:17]}; //Extended to 32bits by replicating leftmost bit
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_l[25:31];	
			end
			11'b001100100??: begin		//EXE_BR
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BR;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; // Extended on the right with 2 0bits
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100000??: begin		//EXE_BRA
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRA;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100110??: begin		//EXE_BRSL
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BRSL;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_l[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100010??: begin		//EXE_BRASL
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BRASL;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_l[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b00110101000: begin		//EXE_BI
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				//branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b00110101001: begin		//EXE_BISL
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BISL;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_l[18:24];
				rt_addr_o <= inst_l[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				//branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000010??: begin		//EXE_BRNZ
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE; //RT only used to READ for BRNZ
				op_code_o <= `EXE_BRNZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_l[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000000??: begin		//EXE_BRZ
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE; //RT only used to READ for BRZ
				op_code_o <= `EXE_BRZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_l[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000110??: begin		//EXE_BRHNZ
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRHNZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000100??: begin		//EXE_BRHZ
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRHZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_l[9]}},inst_l[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b01011000100: begin		//EXE_FA
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FA;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01011000101: begin		//EXE_FS
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FA;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01011000110: begin		//EXE_FM
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FM;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01111000010: begin		//EXE_FCEQ
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FCEQ;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01011000010: begin		//EXE_FCGT
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FCGT;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b01010110100: begin		//EXE_CNTB
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_3;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CNTB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				//rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00011010011: begin		//EXE_AVGB
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_3;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AVGB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_l[18:24];
				rb_addr_e <= inst_l[11:17];
				rt_addr_e <= inst_l[25:31];	
			end
			11'b00000000000: begin		//EXE_STOP
				//??? 
			end
			11'b00000000001: begin		//EXE_LNOP
				pipe_l = `PIPE_ODD;
				uid_o <= `UID_0;
				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_LNOP;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= 0;
			end
			11'b01000000001: begin		//EXE_NOP
				pipe_l = `PIPE_EVEN;
				uid_e <= `UID_0;
				wreg_e = `WR_DISABLE;
				op_code_e <= `EXE_NOP;
				ra_rd_e <= `RD_DISABLE;
				rb_rd_e <= `RD_DISABLE;
				rt_addr_e <= 0;
			end
			default: begin
			end
		endcase
	end

	always @ (*) begin
		casez (op_h)
			11'b00110100???: begin		//EXE_LQD
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_5;   //latency=6
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_LQD;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				imm_o <= {{22{inst_h[8]}},inst_l[8:17]};
				rt_addr_o <= inst_h[25:31];
			end
			11'b00100100???: begin		//EXE_STQD
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_5;   //latency=6
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_STQD;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				imm_o <= {{22{inst_h[8]}},inst_l[8:17]};
				rt_addr_o <= inst_h[25:31];
			end
			11'b00011001000: begin		//EXE_AH
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];			
			end
			11'b00011101???: begin		//EXE_AHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; //HalfWord:16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00011000000: begin		//EXE_A
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_A;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00011100???: begin		//EXE_AI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = {{22{inst_h[8]}},inst_h[8:17]};//Word:32b
				imm_e <= {word_t,word_t,word_t,word_t}; 
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001001000: begin		//EXE_SFH
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001101???: begin		//EXE_SFHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]};//HalfWOrd: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t}; 
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001000000: begin		//EXE_SF
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SF;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001100???: begin		//EXE_SFI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_SFI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = {{22{inst_h[8]}},inst_h[8:17]};
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111000100: begin		//EXE_MPY
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPY;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111001100: begin		//EXE_MPYU
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPYU;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01110100???: begin		//EXE_MPYI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_4;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_MPYI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; //Hword: 16b
				word_t = {16'h0000,hword_t};
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00011000001: begin		//EXE_AND
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AND;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00010110???: begin		//EXE_ANDBI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = (inst_h[8:17]&16'h00ff);
				imm_e <= {word_t,word_t,word_t,word_t}; // 8*4=32b
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00010101???: begin		//EXE_ANDHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; //Hwaord: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00010100???: begin		//EXE_ANDI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ANDI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = {{22{inst_h[8]}},inst_h[8:17]}; //Word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001000001: begin		//EXE_OR
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_OR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00000110???: begin		//EXE_ORBI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = (inst_h[8:17]&16'h00ff); // 8*4=32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00000101???: begin		//EXE_ORHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; //Hword: 16b
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00000100???: begin		//EXE_ORI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_ORI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = {{22{inst_h[8]}},inst_h[8:17]}; //word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];
			end
			11'b01001000001: begin		//EXE_XOR
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XOR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01000110???: begin		//EXE_XORBI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//imm_e <= {{22{inst_h[8]}},inst_h[8:17]};
				word_t = (inst_h[8:17]&32'h00ff);
				//b = (inst_h[8:17]&16'h00ff);
				imm_e <= {word_t,word_t,word_t,word_t}; // 8*4=32b
				rt_addr_e <= inst_h[25:31];
			end
			11'b01000101???: begin		//EXE_XORHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; //Hword:16b
				imm_e = {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];
			end
			11'b01000100???: begin		//EXE_XORI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_XORI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t ={{22{inst_h[8]}},inst_h[8:17]}; //Word: 32b
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];
			end
			11'b00011001001: begin		//EXE_NAND
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_NAND;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00001001001: begin		//EXE_NOR
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_NOR;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00111011011: begin		//EXE_SHLQBI
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_SHLQBI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_ENABLE;
				ra_addr_o <= inst_h[18:24];
				rb_addr_o <= inst_h[11:17];
				rt_addr_o <= inst_h[25:31];	
			end
			11'b00111111011: begin		//EXE_SHLQBII
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_SHLQBII;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				//imm_o <= {{25{inst_h[11]}},inst_h[11:17]};
				imm_o <= inst_h[11:17];
				rt_addr_o <= inst_h[25:31];	
			end
			11'b00111011111: begin		//EXE_ROTQBY
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_ROTQBY;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_ENABLE;
				ra_addr_o <= inst_h[18:24];
				rb_addr_o <= inst_h[11:17];
				rt_addr_o <= inst_h[25:31];	
			end
			11'b00111111111: begin		//EXE_ROTQBYI
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_ROTQBYI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				imm_o <= inst_h[11:17];
				rt_addr_o <= inst_h[25:31];	
			end
			11'b00111110100: begin		//EXE_CBD
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_4;   
				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_CBD;
				ra_rd_o <= `RD_ENABLE; 
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				imm_o <= inst_h[11:17];
				rt_addr_o <= inst_h[25:31];	
			end
			11'b01111010000: begin		//EXE_CEQB
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111110???: begin		//EXE_CEQBI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//imm_e <= inst_h[8:17];
				byte_t = (inst_h[10:17] & 8'hff); // I10 only need bit 2:9
				imm_e <= {byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111001000: begin		//EXE_CEQH
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111101???: begin		//EXE_CEQHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; // Extended to 16bits by replicating leftmost bit
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111000000: begin		//EXE_CEQ
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQ;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111100???: begin		//EXE_CEQI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CEQI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				word_t = {{22{inst_h[8]}},inst_h[8:17]}; //Extended to 32bits by replicating leftmost bit
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001010000: begin		//EXE_CGTB
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001110???: begin		//EXE_CGTBI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTBI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//imm_e <= inst_h[8:17];
				byte_t = inst_h[10:17]; // I10 only need bit 2:9
				imm_e <= {byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t,byte_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001001000: begin		//EXE_CGTH
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTH;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001101???: begin		//EXE_CGTHI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTHI;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//imm_e <= inst_h[8:17];
				hword_t = {{6{inst_h[8]}},inst_h[8:17]}; // Extended to 16bits by replicating leftmost bit
				imm_e <= {hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t,hword_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001000000: begin		//EXE_CGT
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGT;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01001100???: begin		//EXE_CGTI
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_1;   
				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CGTI;
				ra_rd_e <= `RD_ENABLE; //read imm from ra
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//imm_e <= inst_h[8:17];
				word_t = {{22{inst_h[8]}},inst_h[8:17]}; //Extended to 32bits by replicating leftmost bit
				imm_e <= {word_t,word_t,word_t,word_t};
				rt_addr_e <= inst_h[25:31];	
			end
			11'b001100100??: begin		//EXE_BR
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BR;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; // Extended on the right with 2 0bits
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100000??: begin		//EXE_BRA
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRA;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100110??: begin		//EXE_BRSL
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BRSL;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_h[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001100010??: begin		//EXE_BRASL
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BRASL;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_h[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b00110101000: begin		//EXE_BI
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BI;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				//branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b00110101001: begin		//EXE_BISL
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_ENABLE;
				op_code_o <= `EXE_BISL;
				ra_rd_o <= `RD_ENABLE;
				rb_rd_o <= `RD_DISABLE;
				ra_addr_o <= inst_h[18:24];
				rt_addr_o <= inst_h[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				//branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000010??: begin		//EXE_BRNZ
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE; //RT only used to READ for BRNZ
				op_code_o <= `EXE_BRNZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_h[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000000??: begin		//EXE_BRZ
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE; //RT only used to READ for BRZ
				op_code_o <= `EXE_BRZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= inst_h[25:31];
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000110??: begin		//EXE_BRHNZ
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRHNZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b001000100??: begin		//EXE_BRHZ
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_7;   
 				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_BRHZ;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				next_inst_in_delayslot_o <= `IN_DELAYSLOT;
				branch_flag_o <= `BRANCH;
				branch_target_addr_o <= {{14{inst_h[9]}},inst_h[9:24],2'b00}; 
				link_addr_o <= `ZERO_WORD32;
			end
			11'b01011000100: begin		//EXE_FA
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FA;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01011000101: begin		//EXE_FS
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FA;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01011000110: begin		//EXE_FM
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FM;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01111000010: begin		//EXE_FCEQ
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FCEQ;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01011000010: begin		//EXE_FCGT
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_2;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_FCGT;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_ENABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b01010110100: begin		//EXE_CNTB
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_3;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_CNTB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				//rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00011010011: begin		//EXE_AVGB
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_3;   
 				wreg_e = `WR_ENABLE;
				op_code_e <= `EXE_AVGB;
				ra_rd_e <= `RD_ENABLE;
				rb_rd_e <= `RD_DISABLE;
				ra_addr_e <= inst_h[18:24];
				rb_addr_e <= inst_h[11:17];
				rt_addr_e <= inst_h[25:31];	
			end
			11'b00000000000: begin		//EXE_STOP
				//??? 
			end
			11'b00000000001: begin		//EXE_LNOP
				pipe_h = `PIPE_ODD;
				uid_o <= `UID_0;
				wreg_o = `WR_DISABLE;
				op_code_o <= `EXE_LNOP;
				ra_rd_o <= `RD_DISABLE;
				rb_rd_o <= `RD_DISABLE;
				rt_addr_o <= 0;
			end
			11'b01000000001: begin		//EXE_NOP
				pipe_h = `PIPE_EVEN;
				uid_e <= `UID_0;
				wreg_e = `WR_DISABLE;
				op_code_e <= `EXE_NOP;
				ra_rd_e <= `RD_DISABLE;
				rb_rd_e <= `RD_DISABLE;
				rt_addr_e <= 0;
			end
			default: begin
			end
		endcase
	end

	always @ (*) begin
		// Do not need to consider these 2 conditions because EVEN and odd pipe variables already split in Decode module
		//if ((pipe_h==`PIPE_EVEN)&&(pipe_h==`PIPE_ODD))begin end
		//if ((pipe_l==`PIPE_ODD)&&(pipe_h==`PIPE_EVEN)) begin end

		if ((pipe_l==`PIPE_ODD)&&(pipe_h==`PIPE_ODD)) begin
			stallreq <= 1; //stall == 7
		end else if ((pipe_l==`PIPE_EVEN)&&(pipe_h==`PIPE_EVEN)) begin
			stallreq <= 1; //stall == 7
		end else begin
			stallreq <= 0;
		end 
	end 

	// is_in_delayslot_o: is the present instruction in ID a delayslot instruction
	always @ (*) begin
		if (rst == `RST_ENABLE) begin
			is_in_delayslot_o <= `NOT_IN_DELAYSLOT;
		end else begin
			is_in_delayslot_o <= `IN_DELAYSLOT;
		end 
	end

	// Obtain even pipe operand ra & rb
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ra_do_e <= `ZERO_QWORD128;
		end else if ((ra_rd_e==`RD_ENABLE)&&(uid_e==`UID_1)&&(ff2_wreg_i_e==`WR_ENABLE)&&(ff2_waddr_i_e==ra_addr_e)) begin //fowarding data from FF network
			ra_do_e <= ff2_rt_e; 
			stallreq_dh <= 0;
		end else if (((ra_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==ra_addr_e))) begin
			ra_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((ra_rd_e==`RD_ENABLE)&&(uid_e==`UID_3)&&(ff4_wreg_i_e==`WR_ENABLE)&&(ff4_waddr_i_e==ra_addr_e)) begin 
			ra_do_e <= ff4_rt_e;
			stallreq_dh <= 0;
		end else if (((ra_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==ra_addr_e))) begin
			ra_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((ra_rd_e==`RD_ENABLE)&&(uid_e==`UID_2)&&(ff6_wreg_i_e==`WR_ENABLE)&&(ff6_waddr_i_e==ra_addr_e)) begin
			ra_do_e <= ff6_rt_e;
			stallreq_dh <= 0;
		end else if (((ra_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==ra_addr_e))||
				((ra_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==ra_addr_e))) begin
			ra_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((ra_rd_e==`RD_ENABLE)&&(uid_e==`UID_4)&&(ff7_wreg_i_e==`WR_ENABLE)&&(ff7_waddr_i_e==ra_addr_e)) begin
			ra_do_e <= ff7_rt_e;
			stallreq_dh <= 0;
		end else if (((ra_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==ra_addr_e))||
				((ra_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff6_waddr_i_e==ra_addr_e))) begin
			ra_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((ra_rd_e==`RD_ENABLE)&&(mem_wreg_i_e==`WR_ENABLE)&&(mem_waddr_i_e==ra_addr_e)) begin //fowarding data from mem
			ra_do_e <= mem_wdata_i_e;
			stallreq_dh <= 0;
		end else if (((ra_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==ra_addr_e))||
				((ra_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==ra_addr_e))||((ra_rd_e==`RD_ENABLE)&&(ff6_waddr_i_e==ra_addr_e))||
				((ra_rd_e==`RD_ENABLE)&&(ff7_waddr_i_e==ra_addr_e))) begin
			ra_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
	  	end else if(ra_rd_e==1'b1) begin
	  		ra_do_e <= ra_i_e;
	  	end else if(ra_rd_e==1'b0) begin
			ra_do_e <= imm_e;

	 	end
	end
	
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			rb_do_e <= `ZERO_QWORD128;
		end else if ((rb_rd_e==`RD_ENABLE)&&(uid_e==`UID_1)&&(ff2_wreg_i_e==`WR_ENABLE)&&(ff2_waddr_i_e==rb_addr_e)) begin //fowarding data from FF network
			rb_do_e <= ff2_rt_e; 
			stallreq_dh <= 0;
		end else if (((rb_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==rb_addr_e))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((rb_rd_e==`RD_ENABLE)&&(uid_e==`UID_3)&&(ff4_wreg_i_e==`WR_ENABLE)&&(ff4_waddr_i_e==rb_addr_e)) begin 
			rb_do_e <= ff4_rt_e;
			stallreq_dh <= 0;
		end else if (((rb_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==rb_addr_e))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((rb_rd_e==`RD_ENABLE)&&(uid_e==`UID_2)&&(ff6_wreg_i_e==`WR_ENABLE)&&(ff6_waddr_i_e==rb_addr_e)) begin
			rb_do_e <= ff6_rt_e;
			stallreq_dh <= 0;
		end else if (((rb_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==rb_addr_e))||
				((rb_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==rb_addr_e))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((rb_rd_e==`RD_ENABLE)&&(uid_e==`UID_4)&&(ff7_wreg_i_e==`WR_ENABLE)&&(ff7_waddr_i_e==rb_addr_e)) begin
			rb_do_e <= ff7_rt_e;
			stallreq_dh <= 0;
		end else if (((rb_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==rb_addr_e))||
				((rb_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff6_waddr_i_e==rb_addr_e))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((rb_rd_e==`RD_ENABLE)&&(mem_wreg_i_e==`WR_ENABLE)&&(mem_waddr_i_e==rb_addr_e)) begin //fowarding data from mem
			rb_do_e <= mem_wdata_i_e;
			stallreq_dh <= 0;
		end else if (((rb_rd_e==`RD_ENABLE)&&(ex_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff1_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&
				(ff2_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff3_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff4_waddr_i_e==rb_addr_e))||
				((rb_rd_e==`RD_ENABLE)&&(ff5_waddr_i_e==rb_addr_e))||((rb_rd_e==`RD_ENABLE)&&(ff6_waddr_i_e==rb_addr_e))||
				((rb_rd_e==`RD_ENABLE)&&(ff7_waddr_i_e==rb_addr_e))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
	  	end else if(rb_rd_e==1'b1) begin
	  		rb_do_e <= rb_i_e;
	  	end else if(rb_rd_e==1'b0) begin
			rb_do_e <= imm_e;
	 	end
	end

	always @ (*) begin
		if (rst ==`RST_ENABLE) begin
			is_in_delayslot_o <= `NOT_IN_DELAYSLOT;
		end else begin
			is_in_delayslot_o <= is_in_delayslot_i;
		end
	end 

	// Obtain odd pipe operand ra & rb
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ra_do_o <= `ZERO_QWORD128;
		end else if (((ra_rd_o==`RD_ENABLE)&&(uid_o==`UID_4)&&(ff4_wreg_i_o==`WR_ENABLE)&&(ff4_waddr_i_o==ra_addr_o)) || 
				((ra_rd_o==`RD_ENABLE)&&(uid_o==`UID_7)&&(ff4_wreg_i_o==`WR_ENABLE)&&(ff4_waddr_i_o==ra_addr_o))) begin //fowarding data from FF network
			ra_do_o <= ff4_rt_o; 
			stallreq_dh <= 0;
		end else if (((ra_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==ra_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==ra_addr_o))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if (((ra_rd_o==`RD_ENABLE)&&(uid_o==`UID_5)&&(ff6_wreg_i_o==`WR_ENABLE)&&(ff6_waddr_i_o==ra_addr_o)) || 
				((ra_rd_o==`RD_ENABLE)&&(uid_o==`UID_6)&&(ff6_wreg_i_o==`WR_ENABLE)&&(ff6_waddr_i_o==ra_addr_o)))begin 
			ra_do_o <= ff6_rt_o; 
			stallreq_dh <= 0;
		end else if (((ra_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==ra_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff4_waddr_i_o==ra_addr_o))||
				((ra_rd_o==`RD_ENABLE)&&(ff5_waddr_i_o==ra_addr_o))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((ra_rd_o==`RD_ENABLE)&&(mem_wreg_i_o==`WR_ENABLE)&&(mem_waddr_i_o==ra_addr_o)) begin //fowarding data from mem
			ra_do_o <= mem_wdata_i_o;
			stallreq_dh <= 0;
		end else if (((ra_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==ra_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff4_waddr_i_o==ra_addr_o))||
				((ra_rd_o==`RD_ENABLE)&&(ff5_waddr_i_o==ra_addr_o))||((ra_rd_o==`RD_ENABLE)&&(ff6_waddr_i_o==ra_addr_o))||
				((ra_rd_o==`RD_ENABLE)&&(ff7_waddr_i_o==ra_addr_o))) begin
			rb_do_e <= `ZERO_QWORD128;
			stallreq_dh <= 1;
	  	end else if(ra_rd_o==1'b1) begin
	  		ra_do_o <= ra_i_o;
	  	end else if(ra_rd_o==1'b0) begin
			ra_do_o <= imm_o;
	 	end
	end
	
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			rb_do_o <= `ZERO_QWORD128;
		end else if (((rb_rd_o==`RD_ENABLE)&&(uid_o==`UID_4)&&(ff4_wreg_i_o==`WR_ENABLE)&&(ff4_waddr_i_o==rb_addr_o)) ||
				((rb_rd_o==`RD_ENABLE)&&(uid_o==`UID_7)&&(ff4_wreg_i_o==`WR_ENABLE)&&(ff4_waddr_i_o==rb_addr_o)))begin //fowarding data from FF network
			rb_do_o <= ff4_rt_o; 
			stallreq_dh <= 0;
		end else if (((rb_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==rb_addr_o))) begin
			rb_do_o <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if (((rb_rd_o==`RD_ENABLE)&&(uid_o==`UID_5)&&(ff6_wreg_i_o==`WR_ENABLE)&&(ff6_waddr_i_o==rb_addr_o))||
				((rb_rd_o==`RD_ENABLE)&&(uid_o==`UID_6)&&(ff6_wreg_i_o==`WR_ENABLE)&&(ff6_waddr_i_o==rb_addr_o))) begin 
			rb_do_o <= ff6_rt_o; 
			stallreq_dh <= 0;
		end else if (((rb_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff4_waddr_i_o==rb_addr_o))||
				((rb_rd_o==`RD_ENABLE)&&(ff5_waddr_i_o==rb_addr_o))) begin
			rb_do_o <= `ZERO_QWORD128;
			stallreq_dh <= 1;
		end else if ((rb_rd_o==`RD_ENABLE)&&(mem_wreg_i_o==`WR_ENABLE)&&(mem_waddr_i_o==rb_addr_o)) begin //fowarding data from mem
			rb_do_o <= mem_wdata_i_o;
			stallreq_dh <= 0;
		end else if (((rb_rd_o==`RD_ENABLE)&&(ex_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff1_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&
				(ff2_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff3_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff4_waddr_i_o==rb_addr_o))||
				((rb_rd_o==`RD_ENABLE)&&(ff5_waddr_i_o==rb_addr_o))||((rb_rd_o==`RD_ENABLE)&&(ff6_waddr_i_o==rb_addr_o))||
				((rb_rd_o==`RD_ENABLE)&&(ff7_waddr_i_o==rb_addr_o))) begin
			rb_do_o <= `ZERO_QWORD128;
			stallreq_dh <= 1;
	  	end else if(rb_rd_o==1'b1) begin
	  		rb_do_o <= rb_i_o;
	  	end else if(rb_rd_o==1'b0) begin
			rb_do_o <= imm_o;
		end else begin
	    		rb_do_o <= `ZERO_QWORD128;
	 	end
	end

	

endmodule
