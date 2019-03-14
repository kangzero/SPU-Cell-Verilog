//**************************************************************************************/
// Module:  	EX
// File:    	ex.v
// Description: instruction execution stage
// History: 	Created by Weilun Cheng, Mar 15,2018
//		Modify by Ning Kang, Mar 27, 2018 
//			- implement even/odd pipe
//		Modify by Ning Kang, Apr 20, 2018
//			- split even/odd pipe
//			- add clk cycle signal to simulate operation latency
//***************************************************************************************/

`include "defines.v"

//Even pipe
module EX_EVEN(

	input wire clk,
	input wire rst,

	input wire[0:10] i_opcode_e,
	input wire[0:127] i_ra_e,
	input wire[0:127] i_rb_e,
	input wire[0:6] i_rtaddr_e,
	input wire i_wreg_e,
	input wire[0:2] i_uid_e,
	//input wire i_even,

	output reg[0:127] o_rt_e,
	output reg[0:6] o_rtaddr_e,
	output reg o_wreg_e,
	output reg[0:2] o_uid_e
	//output reg o_even

);

					
	reg [0:7] ra_temp_byte [0:15];
	reg [0:7] rb_temp_byte [0:15];
	reg [0:7] rt_temp_byte [0:15];
	reg [0:15] ra_temp_hword [0:7];
	reg [0:15] rb_temp_hword [0:7];
	reg [0:15] rt_temp_hword [0:7];
	reg [0:31] ra_temp_word [0:3];
	reg [0:31] rb_temp_word [0:3];
	reg [0:31] rt_temp_word [0:3];
	reg [0:63] rt_temp_qword [0:3];
	reg [0:7] float_diff;
	reg[0:31] max,min;

	integer i;
	integer c;
	integer b;
	integer m;

	reg [0:31] s;

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			o_rt_e <= `ZERO_QWORD128;
		end else begin
			case (i_opcode_e)
				`EXE_AH: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= i_ra_e[`HALFWORD0] + i_rb_e[`HALFWORD0];
					o_rt_e[`HALFWORD1] <= i_ra_e[`HALFWORD1] + i_rb_e[`HALFWORD1];
					o_rt_e[`HALFWORD2] <= i_ra_e[`HALFWORD2] + i_rb_e[`HALFWORD2];
					o_rt_e[`HALFWORD3] <= i_ra_e[`HALFWORD3] + i_rb_e[`HALFWORD3];
					o_rt_e[`HALFWORD4] <= i_ra_e[`HALFWORD4] + i_rb_e[`HALFWORD4];
					o_rt_e[`HALFWORD5] <= i_ra_e[`HALFWORD5] + i_rb_e[`HALFWORD5];
					o_rt_e[`HALFWORD6] <= i_ra_e[`HALFWORD6] + i_rb_e[`HALFWORD6];
					o_rt_e[`HALFWORD7] <= i_ra_e[`HALFWORD7] + i_rb_e[`HALFWORD7];
				end
				`EXE_AHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= i_ra_e[`HALFWORD0] + i_rb_e[`HALFWORD0];
					o_rt_e[`HALFWORD1] <= i_ra_e[`HALFWORD1] + i_rb_e[`HALFWORD1];
					o_rt_e[`HALFWORD2] <= i_ra_e[`HALFWORD2] + i_rb_e[`HALFWORD2];
					o_rt_e[`HALFWORD3] <= i_ra_e[`HALFWORD3] + i_rb_e[`HALFWORD3];
					o_rt_e[`HALFWORD4] <= i_ra_e[`HALFWORD4] + i_rb_e[`HALFWORD4];
					o_rt_e[`HALFWORD5] <= i_ra_e[`HALFWORD5] + i_rb_e[`HALFWORD5];
					o_rt_e[`HALFWORD6] <= i_ra_e[`HALFWORD6] + i_rb_e[`HALFWORD6];
					o_rt_e[`HALFWORD7] <= i_ra_e[`HALFWORD7] + i_rb_e[`HALFWORD7];
				end
				`EXE_A: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] + i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] + i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] + i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] + i_rb_e[`WORD3];
				end
				`EXE_AI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] + i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] + i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] + i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] + i_rb_e[`WORD3];
				end
				`EXE_SFH: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= (~i_ra_e[`HALFWORD0]) + i_rb_e[`HALFWORD0] + 1;
					o_rt_e[`HALFWORD1] <= (~i_ra_e[`HALFWORD1]) + i_rb_e[`HALFWORD1] + 1;
					o_rt_e[`HALFWORD2] <= (~i_ra_e[`HALFWORD2]) + i_rb_e[`HALFWORD2] + 1;
					o_rt_e[`HALFWORD3] <= (~i_ra_e[`HALFWORD3]) + i_rb_e[`HALFWORD3] + 1;
					o_rt_e[`HALFWORD4] <= (~i_ra_e[`HALFWORD4]) + i_rb_e[`HALFWORD4] + 1;
					o_rt_e[`HALFWORD5] <= (~i_ra_e[`HALFWORD5]) + i_rb_e[`HALFWORD5] + 1;
					o_rt_e[`HALFWORD6] <= (~i_ra_e[`HALFWORD6]) + i_rb_e[`HALFWORD6] + 1;
					o_rt_e[`HALFWORD7] <= (~i_ra_e[`HALFWORD7]) + i_rb_e[`HALFWORD7] + 1;
				end
				`EXE_SFHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= (~i_ra_e[`HALFWORD0]) + i_rb_e[`HALFWORD0] + 1;
					o_rt_e[`HALFWORD1] <= (~i_ra_e[`HALFWORD1]) + i_rb_e[`HALFWORD1] + 1;
					o_rt_e[`HALFWORD2] <= (~i_ra_e[`HALFWORD2]) + i_rb_e[`HALFWORD2] + 1;
					o_rt_e[`HALFWORD3] <= (~i_ra_e[`HALFWORD3]) + i_rb_e[`HALFWORD3] + 1;
					o_rt_e[`HALFWORD4] <= (~i_ra_e[`HALFWORD4]) + i_rb_e[`HALFWORD4] + 1;
					o_rt_e[`HALFWORD5] <= (~i_ra_e[`HALFWORD5]) + i_rb_e[`HALFWORD5] + 1;
					o_rt_e[`HALFWORD6] <= (~i_ra_e[`HALFWORD6]) + i_rb_e[`HALFWORD6] + 1;
					o_rt_e[`HALFWORD7] <= (~i_ra_e[`HALFWORD7]) + i_rb_e[`HALFWORD7] + 1;
  				end				
				`EXE_SF: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= (~i_ra_e[`WORD0]) + i_rb_e[`WORD0] + 1;
					o_rt_e[`WORD1] <= (~i_ra_e[`WORD1]) + i_rb_e[`WORD1] + 1;
					o_rt_e[`WORD2] <= (~i_ra_e[`WORD2]) + i_rb_e[`WORD2] + 1;
					o_rt_e[`WORD3] <= (~i_ra_e[`WORD3]) + i_rb_e[`WORD3] + 1;
				end
				`EXE_SFI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= (~i_ra_e[`WORD0]) + i_rb_e[`WORD0] + 1;
					o_rt_e[`WORD1] <= (~i_ra_e[`WORD1]) + i_rb_e[`WORD1] + 1;
					o_rt_e[`WORD2] <= (~i_ra_e[`WORD2]) + i_rb_e[`WORD2] + 1;
					o_rt_e[`WORD3] <= (~i_ra_e[`WORD3]) + i_rb_e[`WORD3] + 1;
				end
				`EXE_MPY: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`HWORD_R16B0] * i_rb_e[`HWORD_R16B0];
					o_rt_e[`WORD1] <= i_ra_e[`HWORD_R16B1] * i_rb_e[`HWORD_R16B1];
					o_rt_e[`WORD2] <= i_ra_e[`HWORD_R16B2] * i_rb_e[`HWORD_R16B2];
					o_rt_e[`WORD3] <= i_ra_e[`HWORD_R16B3] * i_rb_e[`HWORD_R16B3];
				end
				`EXE_MPYU: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`HWORD_R16B0] * i_rb_e[`HWORD_R16B0];
					o_rt_e[`WORD1] <= i_ra_e[`HWORD_R16B1] * i_rb_e[`HWORD_R16B1];
					o_rt_e[`WORD2] <= i_ra_e[`HWORD_R16B2] * i_rb_e[`HWORD_R16B2];
					o_rt_e[`WORD3] <= i_ra_e[`HWORD_R16B3] * i_rb_e[`HWORD_R16B3];
				end
				`EXE_MPYI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`HWORD_R16B0] * i_rb_e[`HWORD_R16B0];
					o_rt_e[`WORD1] <= i_ra_e[`HWORD_R16B1] * i_rb_e[`HWORD_R16B1];
					o_rt_e[`WORD2] <= i_ra_e[`HWORD_R16B2] * i_rb_e[`HWORD_R16B2];
					o_rt_e[`WORD3] <= i_ra_e[`HWORD_R16B3] * i_rb_e[`HWORD_R16B3];
				end
				`EXE_AND: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] & i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] & i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] & i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] & i_rb_e[`WORD3];
				end
				`EXE_ANDBI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] & i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] & i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] & i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] & i_rb_e[`WORD3];
				end				
				`EXE_ANDHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= i_ra_e[`HALFWORD0] & i_rb_e[`HALFWORD0];
					o_rt_e[`HALFWORD1] <= i_ra_e[`HALFWORD1] & i_rb_e[`HALFWORD1];
					o_rt_e[`HALFWORD2] <= i_ra_e[`HALFWORD2] & i_rb_e[`HALFWORD2];
					o_rt_e[`HALFWORD3] <= i_ra_e[`HALFWORD3] & i_rb_e[`HALFWORD3];
					o_rt_e[`HALFWORD4] <= i_ra_e[`HALFWORD4] & i_rb_e[`HALFWORD4];
					o_rt_e[`HALFWORD5] <= i_ra_e[`HALFWORD5] & i_rb_e[`HALFWORD5];
					o_rt_e[`HALFWORD6] <= i_ra_e[`HALFWORD6] & i_rb_e[`HALFWORD6];
					o_rt_e[`HALFWORD7] <= i_ra_e[`HALFWORD7] & i_rb_e[`HALFWORD7];
				end
				`EXE_ANDI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] & i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] & i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] & i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] & i_rb_e[`WORD3];
				end
				`EXE_OR: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] | i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] | i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] | i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] | i_rb_e[`WORD3];
				end
				`EXE_ORBI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] | i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] | i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] | i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] | i_rb_e[`WORD3];
				end
				`EXE_ORHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= i_ra_e[`HALFWORD0] | i_rb_e[`HALFWORD0];
					o_rt_e[`HALFWORD1] <= i_ra_e[`HALFWORD1] | i_rb_e[`HALFWORD1];
					o_rt_e[`HALFWORD2] <= i_ra_e[`HALFWORD2] | i_rb_e[`HALFWORD2];
					o_rt_e[`HALFWORD3] <= i_ra_e[`HALFWORD3] | i_rb_e[`HALFWORD3];
					o_rt_e[`HALFWORD4] <= i_ra_e[`HALFWORD4] | i_rb_e[`HALFWORD4];
					o_rt_e[`HALFWORD5] <= i_ra_e[`HALFWORD5] | i_rb_e[`HALFWORD5];
					o_rt_e[`HALFWORD6] <= i_ra_e[`HALFWORD6] | i_rb_e[`HALFWORD6];
					o_rt_e[`HALFWORD7] <= i_ra_e[`HALFWORD7] | i_rb_e[`HALFWORD7];
				end
				`EXE_ORI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] | i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] | i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] | i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] | i_rb_e[`WORD3];
				end
				`EXE_XOR: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] ^ i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] ^ i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] ^ i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] ^ i_rb_e[`WORD3];
				end				
				`EXE_XORBI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] ^ i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] ^ i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] ^ i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] ^ i_rb_e[`WORD3];
				end
				`EXE_XORHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`HALFWORD0] <= i_ra_e[`HALFWORD0] ^ i_rb_e[`HALFWORD0];
					o_rt_e[`HALFWORD1] <= i_ra_e[`HALFWORD1] ^ i_rb_e[`HALFWORD1];
					o_rt_e[`HALFWORD2] <= i_ra_e[`HALFWORD2] ^ i_rb_e[`HALFWORD2];
					o_rt_e[`HALFWORD3] <= i_ra_e[`HALFWORD3] ^ i_rb_e[`HALFWORD3];
					o_rt_e[`HALFWORD4] <= i_ra_e[`HALFWORD4] ^ i_rb_e[`HALFWORD4];
					o_rt_e[`HALFWORD5] <= i_ra_e[`HALFWORD5] ^ i_rb_e[`HALFWORD5];
					o_rt_e[`HALFWORD6] <= i_ra_e[`HALFWORD6] ^ i_rb_e[`HALFWORD6];
					o_rt_e[`HALFWORD7] <= i_ra_e[`HALFWORD7] ^ i_rb_e[`HALFWORD7];
				end
				`EXE_XORI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;
					o_rt_e[`WORD0] <= i_ra_e[`WORD0] ^ i_rb_e[`WORD0];
					o_rt_e[`WORD1] <= i_ra_e[`WORD1] ^ i_rb_e[`WORD1];
					o_rt_e[`WORD2] <= i_ra_e[`WORD2] ^ i_rb_e[`WORD2];
					o_rt_e[`WORD3] <= i_ra_e[`WORD3] ^ i_rb_e[`WORD3];
				end
				`EXE_NAND: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= ~(i_ra_e[`WORD0] & i_rb_e[`WORD0]);
					o_rt_e[`WORD1] <= ~(i_ra_e[`WORD1] & i_rb_e[`WORD1]);
					o_rt_e[`WORD2] <= ~(i_ra_e[`WORD2] & i_rb_e[`WORD2]);
					o_rt_e[`WORD3] <= ~(i_ra_e[`WORD3] & i_rb_e[`WORD3]);
				end
				`EXE_NOR: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= ~(i_ra_e[`WORD0] | i_rb_e[`WORD0]);
					o_rt_e[`WORD1] <= ~(i_ra_e[`WORD1] | i_rb_e[`WORD1]);
					o_rt_e[`WORD2] <= ~(i_ra_e[`WORD2] | i_rb_e[`WORD2]);
					o_rt_e[`WORD3] <= ~(i_ra_e[`WORD3] | i_rb_e[`WORD3]);
				end
				`EXE_CEQB: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

					rb_temp_byte[0] <= i_rb_e[`BYTE0];
					rb_temp_byte[1] <= i_rb_e[`BYTE1];
					rb_temp_byte[2] <= i_rb_e[`BYTE2];
					rb_temp_byte[3] <= i_rb_e[`BYTE3];
					rb_temp_byte[4] <= i_rb_e[`BYTE4];
					rb_temp_byte[5] <= i_rb_e[`BYTE5];
					rb_temp_byte[6] <= i_rb_e[`BYTE6];
					rb_temp_byte[7] <= i_rb_e[`BYTE7];
					rb_temp_byte[8] <= i_rb_e[`BYTE8];
					rb_temp_byte[9] <= i_rb_e[`BYTE9];
					rb_temp_byte[10] <= i_rb_e[`BYTE10];
					rb_temp_byte[11] <= i_rb_e[`BYTE11];
					rb_temp_byte[12] <= i_rb_e[`BYTE12];
					rb_temp_byte[13] <= i_rb_e[`BYTE13];
					rb_temp_byte[14] <= i_rb_e[`BYTE14];
					rb_temp_byte[15] <= i_rb_e[`BYTE15];

					for (i=0; i<16; i=i+1) begin 
						if (ra_temp_byte[i] == rb_temp_byte[i]) begin
							rt_temp_byte[i] = 8'hff;
						end else begin
							rt_temp_byte[i] = 8'h00;
						end
					end

 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];	
				end
				`EXE_CEQBI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

					rb_temp_byte[0] <= i_ra_e[`BYTE0]; //rb=I10[2:9]

					for (i=0; i<16; i=i+1) begin 
						if (ra_temp_byte[i] == rb_temp_byte[0]) begin
							rt_temp_byte[i] = 8'hff;
						end else begin
							rt_temp_byte[i] = 8'h00;
						end
					end

 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];	
				end				
				`EXE_CEQH: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_hword[0] <= i_ra_e[`HALFWORD0];
					ra_temp_hword[1] <= i_ra_e[`HALFWORD1];
					ra_temp_hword[2] <= i_ra_e[`HALFWORD2];
					ra_temp_hword[3] <= i_ra_e[`HALFWORD3];
					ra_temp_hword[4] <= i_ra_e[`HALFWORD4];
					ra_temp_hword[5] <= i_ra_e[`HALFWORD5];
					ra_temp_hword[6] <= i_ra_e[`HALFWORD6];
					ra_temp_hword[7] <= i_ra_e[`HALFWORD7];

					rb_temp_hword[0] <= i_rb_e[`HALFWORD0];
					rb_temp_hword[1] <= i_rb_e[`HALFWORD1];
					rb_temp_hword[2] <= i_rb_e[`HALFWORD2];
					rb_temp_hword[3] <= i_rb_e[`HALFWORD3];
					rb_temp_hword[4] <= i_rb_e[`HALFWORD4];
					rb_temp_hword[5] <= i_rb_e[`HALFWORD5];
					rb_temp_hword[6] <= i_rb_e[`HALFWORD6];
					rb_temp_hword[7] <= i_rb_e[`HALFWORD7];

					for (i=0; i<8; i=i+1) begin 
						if (ra_temp_hword[i] == rb_temp_hword[i]) begin
							rt_temp_hword[i] = 16'hffff;
						end else begin
							rt_temp_hword[i] = 16'h0000;
						end
					end

 					o_rt_e[`HALFWORD0] <= rt_temp_hword[0];
					o_rt_e[`HALFWORD1] <= rt_temp_hword[1];
					o_rt_e[`HALFWORD2] <= rt_temp_hword[2];
					o_rt_e[`HALFWORD3] <= rt_temp_hword[3];
					o_rt_e[`HALFWORD4] <= rt_temp_hword[4];
					o_rt_e[`HALFWORD5] <= rt_temp_hword[5];
					o_rt_e[`HALFWORD6] <= rt_temp_hword[6];
					o_rt_e[`HALFWORD7] <= rt_temp_hword[7];
				end
				`EXE_CEQHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_hword[0] <= i_ra_e[`HALFWORD0];
					ra_temp_hword[1] <= i_ra_e[`HALFWORD1];
					ra_temp_hword[2] <= i_ra_e[`HALFWORD2];
					ra_temp_hword[3] <= i_ra_e[`HALFWORD3];
					ra_temp_hword[4] <= i_ra_e[`HALFWORD4];
					ra_temp_hword[5] <= i_ra_e[`HALFWORD5];
					ra_temp_hword[6] <= i_ra_e[`HALFWORD6];
					ra_temp_hword[7] <= i_ra_e[`HALFWORD7];

					rb_temp_hword[0] <= i_rb_e[`HALFWORD0]; //the 16bit Imm #

					for (i=0; i<8; i=i+1) begin 
						if (ra_temp_hword[i] == rb_temp_hword[0]) begin
							rt_temp_hword[i] = 16'hffff;
						end else begin
							rt_temp_hword[i] = 16'h0000;
						end
					end

 					o_rt_e[`HALFWORD0] <= rt_temp_hword[0];
					o_rt_e[`HALFWORD1] <= rt_temp_hword[1];
					o_rt_e[`HALFWORD2] <= rt_temp_hword[2];
					o_rt_e[`HALFWORD3] <= rt_temp_hword[3];
					o_rt_e[`HALFWORD4] <= rt_temp_hword[4];
					o_rt_e[`HALFWORD5] <= rt_temp_hword[5];
					o_rt_e[`HALFWORD6] <= rt_temp_hword[6];
					o_rt_e[`HALFWORD7] <= rt_temp_hword[7];
				end
				`EXE_CEQ: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] == rb_temp_word[i]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_CEQI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] == rb_temp_word[0]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_CGTB: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

					rb_temp_byte[0] <= i_rb_e[`BYTE0];
					rb_temp_byte[1] <= i_rb_e[`BYTE1];
					rb_temp_byte[2] <= i_rb_e[`BYTE2];
					rb_temp_byte[3] <= i_rb_e[`BYTE3];
					rb_temp_byte[4] <= i_rb_e[`BYTE4];
					rb_temp_byte[5] <= i_rb_e[`BYTE5];
					rb_temp_byte[6] <= i_rb_e[`BYTE6];
					rb_temp_byte[7] <= i_rb_e[`BYTE7];
					rb_temp_byte[8] <= i_rb_e[`BYTE8];
					rb_temp_byte[9] <= i_rb_e[`BYTE9];
					rb_temp_byte[10] <= i_rb_e[`BYTE10];
					rb_temp_byte[11] <= i_rb_e[`BYTE11];
					rb_temp_byte[12] <= i_rb_e[`BYTE12];
					rb_temp_byte[13] <= i_rb_e[`BYTE13];
					rb_temp_byte[14] <= i_rb_e[`BYTE14];
					rb_temp_byte[15] <= i_rb_e[`BYTE15];

					for (i=0; i<16; i=i+1) begin 
						if (ra_temp_byte[i] > rb_temp_byte[i]) begin
							rt_temp_byte[i] = 8'hff;
						end else begin
							rt_temp_byte[i] = 8'h00;
						end
					end

 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];	
				end
				`EXE_CGTBI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

					rb_temp_byte[0] <= i_ra_e[`BYTE0]; //rb=I10[2:9]

					for (i=0; i<16; i=i+1) begin 
						if (ra_temp_byte[i] > rb_temp_byte[0]) begin
							rt_temp_byte[i] = 8'hff;
						end else begin
							rt_temp_byte[i] = 8'h00;
						end
					end

 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];	
				end
				`EXE_CGTH: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_hword[0] <= i_ra_e[`HALFWORD0];
					ra_temp_hword[1] <= i_ra_e[`HALFWORD1];
					ra_temp_hword[2] <= i_ra_e[`HALFWORD2];
					ra_temp_hword[3] <= i_ra_e[`HALFWORD3];
					ra_temp_hword[4] <= i_ra_e[`HALFWORD4];
					ra_temp_hword[5] <= i_ra_e[`HALFWORD5];
					ra_temp_hword[6] <= i_ra_e[`HALFWORD6];
					ra_temp_hword[7] <= i_ra_e[`HALFWORD7];

					rb_temp_hword[0] <= i_rb_e[`HALFWORD0];
					rb_temp_hword[1] <= i_rb_e[`HALFWORD1];
					rb_temp_hword[2] <= i_rb_e[`HALFWORD2];
					rb_temp_hword[3] <= i_rb_e[`HALFWORD3];
					rb_temp_hword[4] <= i_rb_e[`HALFWORD4];
					rb_temp_hword[5] <= i_rb_e[`HALFWORD5];
					rb_temp_hword[6] <= i_rb_e[`HALFWORD6];
					rb_temp_hword[7] <= i_rb_e[`HALFWORD7];

					for (i=0; i<8; i=i+1) begin 
						if (ra_temp_hword[i] > rb_temp_hword[i]) begin
							rt_temp_hword[i] = 16'hffff;
						end else begin
							rt_temp_hword[i] = 16'h0000;
						end
					end

 					o_rt_e[`HALFWORD0] <= rt_temp_hword[0];
					o_rt_e[`HALFWORD1] <= rt_temp_hword[1];
					o_rt_e[`HALFWORD2] <= rt_temp_hword[2];
					o_rt_e[`HALFWORD3] <= rt_temp_hword[3];
					o_rt_e[`HALFWORD4] <= rt_temp_hword[4];
					o_rt_e[`HALFWORD5] <= rt_temp_hword[5];
					o_rt_e[`HALFWORD6] <= rt_temp_hword[6];
					o_rt_e[`HALFWORD7] <= rt_temp_hword[7];
				end				
				`EXE_CGTHI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_hword[0] <= i_ra_e[`HALFWORD0];
					ra_temp_hword[1] <= i_ra_e[`HALFWORD1];
					ra_temp_hword[2] <= i_ra_e[`HALFWORD2];
					ra_temp_hword[3] <= i_ra_e[`HALFWORD3];
					ra_temp_hword[4] <= i_ra_e[`HALFWORD4];
					ra_temp_hword[5] <= i_ra_e[`HALFWORD5];
					ra_temp_hword[6] <= i_ra_e[`HALFWORD6];
					ra_temp_hword[7] <= i_ra_e[`HALFWORD7];

					rb_temp_hword[0] <= i_rb_e[`HALFWORD0]; //the 16bit Imm #

					for (i=0; i<8; i=i+1) begin 
						if (ra_temp_hword[i] > rb_temp_hword[0]) begin
							rt_temp_hword[i] = 16'hffff;
						end else begin
							rt_temp_hword[i] = 16'h0000;
						end
					end

 					o_rt_e[`HALFWORD0] <= rt_temp_hword[0];
					o_rt_e[`HALFWORD1] <= rt_temp_hword[1];
					o_rt_e[`HALFWORD2] <= rt_temp_hword[2];
					o_rt_e[`HALFWORD3] <= rt_temp_hword[3];
					o_rt_e[`HALFWORD4] <= rt_temp_hword[4];
					o_rt_e[`HALFWORD5] <= rt_temp_hword[5];
					o_rt_e[`HALFWORD6] <= rt_temp_hword[6];
					o_rt_e[`HALFWORD7] <= rt_temp_hword[7];
				end
				`EXE_CGT: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] > rb_temp_word[i]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_CGTI: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] > rb_temp_word[0]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_FA: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
//					o_rt_e[`WORD0] <= i_ra_e[`WORD0] + i_rb_e[`WORD0];
//					o_rt_e[`WORD1] <= i_ra_e[`WORD1] + i_rb_e[`WORD1];
//					o_rt_e[`WORD2] <= i_ra_e[`WORD2] + i_rb_e[`WORD2];
//					o_rt_e[`WORD3] <= i_ra_e[`WORD3] + i_rb_e[`WORD3];
					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];
					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];
					for (i=0;i<4;i=i+1) begin
						if (ra_temp_word[i][0]==rb_temp_word[i][0])
							begin
							//judge tha max and min of two operands
							if (ra_temp_word[i][1:9]>rb_temp_word[i][1:9]) begin
								max=ra_temp_word[i];
								min=rb_temp_word[i];
							end
							else begin
								min=ra_temp_word[i];
								max=rb_temp_word[i];
							end
							//the exponoents diff
							float_diff=max[1:9]-min[1:9];
							//resize the min operand
							min[9:31]=min[9:31]>>float_diff;
							rt_temp_word[i][9:31]=max[9:31]+min[9:31];
							rt_temp_word[i][0:8]=max[0:8];
							end
						else begin
							if (ra_temp_word[i][1:9]>rb_temp_word[i][1:9]) begin
								max=ra_temp_word[i];
								min=rb_temp_word[i];
							end
							else begin
								min=ra_temp_word[i];
								max=rb_temp_word[i];
							end
							float_diff=max[1:9]-min[1:9];
							min[9:31]=min[9:31]>>float_diff;
							rt_temp_word[i][9:31]=max[9:31]-min[9:31];
							rt_temp_word[i][0:8]=max[0:8];
							end
						end
					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_FS: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;					
					o_rt_e[`WORD0] <= (~i_ra_e[`WORD0]) + i_rb_e[`WORD0] + 1;
					o_rt_e[`WORD1] <= (~i_ra_e[`WORD1]) + i_rb_e[`WORD1] + 1;
					o_rt_e[`WORD2] <= (~i_ra_e[`WORD2]) + i_rb_e[`WORD2] + 1;
					o_rt_e[`WORD3] <= (~i_ra_e[`WORD3]) + i_rb_e[`WORD3] + 1;
				end
				`EXE_FM: begin
					o_wreg_e<=i_wreg_e;
					o_rtaddr_e<=i_rtaddr_e;
					o_uid_e<=i_uid_e;
					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];
					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];
					for (i=0;i<4;i=i+1) begin
						rt_temp_word[i][0]<=ra_temp_word[i][0]~^rb_temp_word[0];
						rt_temp_word[i][1:8]<=ra_temp_word[i][1:8]+rb_temp_word[i][1:8];
						rt_temp_word[i][9:31]<=ra_temp_word[i][9:31]*rb_temp_word[i][9:31];
					end
					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
					
				end
				`EXE_FCEQ: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] == rb_temp_word[i]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end				
				`EXE_FCGT: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_word[0] <= i_ra_e[`WORD0];
					ra_temp_word[1] <= i_ra_e[`WORD1];
					ra_temp_word[2] <= i_ra_e[`WORD2];
					ra_temp_word[3] <= i_ra_e[`WORD3];

					rb_temp_word[0] <= i_rb_e[`WORD0];
					rb_temp_word[1] <= i_rb_e[`WORD1];
					rb_temp_word[2] <= i_rb_e[`WORD2];
					rb_temp_word[3] <= i_rb_e[`WORD3];

					for (i=0; i<4; i=i+1) begin 
						if (ra_temp_word[i] > rb_temp_word[i]) begin
							rt_temp_word[i] = 32'hffffffff;
						end else begin
							rt_temp_word[i] = 32'h00000000;
						end
					end

 					o_rt_e[`WORD0] <= rt_temp_word[0];
					o_rt_e[`WORD1] <= rt_temp_word[1];
					o_rt_e[`WORD2] <= rt_temp_word[2];
					o_rt_e[`WORD3] <= rt_temp_word[3];
				end
				`EXE_CNTB: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

    					for (i=0; i<16; i=i+1) begin 
      						c = 0; 
      						b = ra_temp_byte[i];
      						for (m=0; m<8; m=m+1) begin
          						if (b[m] == 1) begin
            							c = c + 1;
							end
        					end
      						rt_temp_byte[i] = c;
      					end
 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];							
				end
				`EXE_AVGB: begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_uid_e <= i_uid_e;
					//o_even <= `PIPE_EVEN;	

					ra_temp_byte[0] <= i_ra_e[`BYTE0];
					ra_temp_byte[1] <= i_ra_e[`BYTE1];
					ra_temp_byte[2] <= i_ra_e[`BYTE2];
					ra_temp_byte[3] <= i_ra_e[`BYTE3];
					ra_temp_byte[4] <= i_ra_e[`BYTE4];
					ra_temp_byte[5] <= i_ra_e[`BYTE5];
					ra_temp_byte[6] <= i_ra_e[`BYTE6];
					ra_temp_byte[7] <= i_ra_e[`BYTE7];
					ra_temp_byte[8] <= i_ra_e[`BYTE8];
					ra_temp_byte[9] <= i_ra_e[`BYTE9];
					ra_temp_byte[10] <= i_ra_e[`BYTE10];
					ra_temp_byte[11] <= i_ra_e[`BYTE11];
					ra_temp_byte[12] <= i_ra_e[`BYTE12];
					ra_temp_byte[13] <= i_ra_e[`BYTE13];
					ra_temp_byte[14] <= i_ra_e[`BYTE14];
					ra_temp_byte[15] <= i_ra_e[`BYTE15];

					rb_temp_byte[0] <= i_rb_e[`BYTE0];
					rb_temp_byte[1] <= i_rb_e[`BYTE1];
					rb_temp_byte[2] <= i_rb_e[`BYTE2];
					rb_temp_byte[3] <= i_rb_e[`BYTE3];
					rb_temp_byte[4] <= i_rb_e[`BYTE4];
					rb_temp_byte[5] <= i_rb_e[`BYTE5];
					rb_temp_byte[6] <= i_rb_e[`BYTE6];
					rb_temp_byte[7] <= i_rb_e[`BYTE7];
					rb_temp_byte[8] <= i_rb_e[`BYTE8];
					rb_temp_byte[9] <= i_rb_e[`BYTE9];
					rb_temp_byte[10] <= i_rb_e[`BYTE10];
					rb_temp_byte[11] <= i_rb_e[`BYTE11];
					rb_temp_byte[12] <= i_rb_e[`BYTE12];
					rb_temp_byte[13] <= i_rb_e[`BYTE13];
					rb_temp_byte[14] <= i_rb_e[`BYTE14];
					rb_temp_byte[15] <= i_rb_e[`BYTE15];

    					for (i=0; i<16; i=i+1) begin 
        					s = ({8'h00,ra_temp_byte[i]} + {8'h00,rb_temp_byte[i]}) + 1;
        					rt_temp_byte[i] = s[7:14];
      					end 
 					o_rt_e[`BYTE0] <= rt_temp_byte[0];
					o_rt_e[`BYTE1] <= rt_temp_byte[1];
					o_rt_e[`BYTE2] <= rt_temp_byte[2];
					o_rt_e[`BYTE3] <= rt_temp_byte[3];
					o_rt_e[`BYTE4] <= rt_temp_byte[4];
					o_rt_e[`BYTE5] <= rt_temp_byte[5];
					o_rt_e[`BYTE6] <= rt_temp_byte[6];
					o_rt_e[`BYTE7] <= rt_temp_byte[7];
 					o_rt_e[`BYTE8] <= rt_temp_byte[8];
					o_rt_e[`BYTE9] <= rt_temp_byte[9];
					o_rt_e[`BYTE10] <= rt_temp_byte[10];
					o_rt_e[`BYTE11] <= rt_temp_byte[11];
					o_rt_e[`BYTE12] <= rt_temp_byte[12];
					o_rt_e[`BYTE13] <= rt_temp_byte[13];
					o_rt_e[`BYTE14] <= rt_temp_byte[14];
					o_rt_e[`BYTE15] <= rt_temp_byte[15];		
				end
				`EXE_NOP: begin
					o_rt_e <= 0;
					o_rtaddr_e <= 0;
					o_wreg_e <= 0;
					o_uid_e <= 0;
				end 
				default:begin
					o_rt_e <= `ZERO_QWORD128;
				end
			endcase
		end   
	end 
endmodule

//Odd pipe
module EX_ODD(

	input wire clk,
	input wire rst,

	input wire[0:10] i_opcode_o,
	input wire[0:127] i_ra_o,
	input wire[0:127] i_rb_o,
	input wire[0:6] i_rtaddr_o,
	input wire i_wreg_o,
	input wire[0:2] i_uid_o,
	input wire[0:9] i_imm_o,
 	//input wire i_odd,

	input reg[0:31] i_pc,
	input reg[0:31] i_ex_link_addr,
	input reg i_ex_id_is_in_delayslot,
	input reg[0:31] i_ex_branch_target_addr,
	input reg i_ex_branch_flag,

	output reg[0:127] o_rt_o,
	output reg[0:6] o_rtaddr_o,
	output reg o_wreg_o,
	output reg[0:2] o_uid_o,
	//memory address
	output reg[0:31] o_memory_addr_o,
	//output reg o_odd,

	output reg[0:31] ex_pc,
	output reg[0:31] o_ex_link_addr,
	output reg o_ex_is_in_delayslot,
	output reg[0:31] o_ex_branch_target_addr,
	output reg o_ex_branch_flag

);

	reg [0:127] rt_temp_b;
	reg [0:1] sh;
	reg [0:7] imm_8b;
	reg [0:31] imm_32b;
	reg [0:31] t;
	reg [0:3] s;
	integer b;

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			o_rt_o <= `ZERO_QWORD128;
		end else begin
			case (i_opcode_o)
 				`EXE_LQD: begin
					o_rtaddr_o<=i_rtaddr_o;
					o_wreg_o<=i_wreg_o;
					o_uid_o<=i_uid_o;
					o_memory_addr_o<=i_ra_o+i_rb_o;
				end
				`EXE_STQD: begin
					o_wreg_o<=i_wreg_o;
					o_uid_o<=i_uid_o;
					o_rt_o<=i_rb_o;
					o_memory_addr_o<=i_imm_o+i_ra_o;
				end
				`EXE_SHLQBI: begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;	
 					sh = i_rb_o[29:31];
					for (b=0; b<128; b=b+1) begin 
						if ((b+sh) < 128) begin
							o_rt_o[b] = i_ra_o[b+sh];
						end else begin
							o_rt_o[b] = 0;
						end 
					end 
				end
				`EXE_SHLQBII: begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;	
 					imm_8b = i_rb_o[0:7] & 8'h07;
					
					for (b=0; b<128; b=b+1) begin 
						if ((b+imm_8b) < 128) begin
							o_rt_o[b] = i_ra_o[b+imm_8b];
						end else begin
							o_rt_o[b] = 0;
						end 
					end 
				end
				`EXE_ROTQBY: begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;	
					s = i_rb_o[28:31];
					for (b=0; b<128; b=b+1) begin
						if ((b+s) < 16) begin
							o_rt_o[b] = i_ra_o[b+s];
						end else begin
							o_rt_o[b] = i_ra_o[b+s-4'hf];	
						end 
					end 
				end
				`EXE_ROTQBYI: begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;	
					//s = i_rb_o[28:31];
					s = i_rb_o[14:17]; //only mask the I7[14:17]
					for (b=0; b<128; b=b+1) begin
						if ((b+s) < 16) begin
							o_rt_o[b] = i_ra_o[b+s];
						end else begin
							o_rt_o[b] = i_ra_o[b+s-4'hf];	
						end 
					end 
				end
				`EXE_CBD: begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;	
					imm_32b = {{22{i_rb_o[0]}},i_rb_o[0:7]};
					t = (i_ra_o[0:31] + imm_32b) & 32'h0000000F;
					case (t)
						32'h00000000: o_rt_o = 128'h101112131415161718191a1b1c1d1e03;
						32'h00000001: o_rt_o = 128'h101112131415161718191a1b1c1d031f;
						32'h00000002: o_rt_o = 128'h101112131415161718191a1b1c031e1f;
						32'h00000003: o_rt_o = 128'h101112131415161718191a1b031d1e1f;
						32'h00000004: o_rt_o = 128'h101112131415161718191a031c1d1e1f;
						32'h00000005: o_rt_o = 128'h10111213141516171819031b1c1d1e1f;
						32'h00000006: o_rt_o = 128'h101112131415161718031a1b1c1d1e1f;
						32'h00000007: o_rt_o = 128'h101112131415161703191a1b1c1d1e1f;
						32'h00000008: o_rt_o = 128'h101112131415160318191a1b1c1d1e1f;
						32'h00000009: o_rt_o = 128'h101112131415031718191a1b1c1d1e1f;
						32'h0000000a: o_rt_o = 128'h101112131403161718191a1b1c1d1e1f;
						32'h0000000b: o_rt_o = 128'h101112130315161718191a1b1c1d1e1f;
						32'h0000000c: o_rt_o = 128'h101112031415161718191a1b1c1d1e1f;
						32'h0000000d: o_rt_o = 128'h101103131415161718191a1b1c1d1e1f;
						32'h0000000e: o_rt_o = 128'h100312131415161718191a1b1c1d1e1f;
						32'h0000000f: o_rt_o = 128'h031112131415161718191a1b1c1d1e1f;
						default: o_rt_o = 128'h101112131415161718191a1b1c1d1e1f;
					endcase 	
				end
				`EXE_BR:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= i_ex_branch_target_addr;
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;
				end
				`EXE_BRA:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= i_ex_branch_target_addr;
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;				
				end
				`EXE_BRSL:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_rt_o <= ((ex_pc + 4) & 128'h000000000000000000000000ffffffff); //RT0:3 = pc+4; RT4:15=0
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= i_ex_branch_target_addr;
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BRASL:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_rt_o <= ((ex_pc + 4) & 128'h000000000000000000000000ffffffff); //RT0:3 = pc+4; RT4:15=0
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= ex_pc + i_ex_branch_target_addr;
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BI:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= (i_ra_o[0:31] & 32'hfffffffc);
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BISL:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_rt_o <= ((ex_pc + 4) & 128'h000000000000000000000000ffffffff); //RT0:3 = pc+4; RT4:15=0
					o_ex_branch_flag <= i_ex_branch_flag;
					o_ex_branch_target_addr <= (i_ra_o[0:31] & 32'hfffffffc);
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BRNZ:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					if (o_rt_o[0:31] != 0) begin
						o_ex_branch_target_addr <= ((ex_pc + i_ex_branch_target_addr) & 32'hfffffffc);
					end else begin
						o_ex_branch_target_addr <= ex_pc + 4;
					end 
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BRZ:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					if (o_rt_o[0:31] == 0) begin
						o_ex_branch_target_addr <= ((ex_pc + i_ex_branch_target_addr) & 32'hfffffffc);
					end else begin
						o_ex_branch_target_addr <= ex_pc +4;
					end 
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BRHNZ:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					if (o_rt_o[16:31] != 0) begin
						o_ex_branch_target_addr <= ((ex_pc + i_ex_branch_target_addr) & 32'hfffffffc);
					end else begin
						o_ex_branch_target_addr <= ex_pc +4;
					end 
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_BRHZ:begin
					o_uid_o <= i_uid_o;
					//o_odd <= `PIPE_ODD;
					o_ex_branch_flag <= i_ex_branch_flag;
					if (o_rt_o[16:31] == 0) begin
						o_ex_branch_target_addr <= ((ex_pc + i_ex_branch_target_addr) & 32'hfffffffc);
					end else begin
						o_ex_branch_target_addr <= ex_pc +4;
					end 
					o_ex_link_addr <= i_ex_link_addr;
					o_ex_is_in_delayslot <= i_ex_id_is_in_delayslot;	
				end
				`EXE_LNOP: begin
					o_rt_o <= 0;
					o_rtaddr_o <= 0;
					o_wreg_o <= 0;
					o_uid_o <= 0;
					//ex_pc <= 0;
					//o_ex_link_addr <= 0;
					//o_ex_is_in_delayslot <= 0;
					//o_ex_branch_target_addr <= 0;
					//o_ex_branch_flag <= 0;
				end 
				default:begin
					o_rt_o <= `ZERO_WORD32;
				end
			endcase
		end   
	end
endmodule


//*****************************************************************************//
//*****************************************************************************//
//******************* Only back-up: ORI test code *****************************//
//*****************************************************************************//
//*****************************************************************************//
/*
module EX(

	input wire clk,
	input wire rst,

	input wire[0:10] i_opcode_e,
	input wire[0:127] i_ra_e,
	input wire[0:127] i_rb_e,
	input wire[0:6] i_rtaddr_e,
	input wire i_wreg_e,
	input wire[0:2] i_uid_e,
	input wire i_even,

	input wire[0:10] i_opcode_o,
	input wire[0:127] i_ra_o,
	input wire[0:127] i_rb_o,
	input wire[0:6] i_rtaddr_o,
	input wire i_wreg_o,
	input wire[0:2] i_uid_o,
	input wire i_odd,
	
	output reg[0:127] o_rt_e,
	output reg[0:6] o_rtaddr_e,
	output reg o_wreg_e,
	output reg[0:2] o_uid_e,
	output reg o_even,

	output reg[0:127] o_rt_o,
	output reg[0:6] o_rtaddr_o,
	output reg o_wreg_o,
	output reg[0:2] o_uid_o,
	output reg o_odd
);

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			o_rt_e <= `ZERO_WORD32;
		end else begin
			case (i_opcode_e)
				`EXE_ORI:begin
					o_wreg_e <= i_wreg_e;	 	 	
					o_rtaddr_e <= i_rtaddr_e;
					o_rt_e <= i_ra_e | i_rb_e;
					o_uid_e <= i_uid_e;
					o_even <= i_even;
				end
				default:begin
					o_rt_e <= `ZERO_WORD32;
				end
			endcase
		end   
	end

	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			o_rt_o <= `ZERO_WORD32;
		end else begin
			case (i_opcode_o)
				`EXE_ORI:begin
					o_wreg_o <= i_wreg_o;	 	 	
					o_rtaddr_o <= i_rtaddr_o;
					o_rt_o <= i_ra_o | i_rb_o;
					o_uid_o <= i_uid_o;
					o_odd <= i_odd;
				end
				default:begin
					o_rt_o <= `ZERO_WORD32;
				end
			endcase
		end   
	end

endmodule
*/