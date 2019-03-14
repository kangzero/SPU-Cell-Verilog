//**************************************************************************************/
// File:    	defines.v
// Description: macro defines
// History: 	Created by Ning Kang, Mar 18,2018
//***************************************************************************************/

`define RST_ENABLE 1'b1
`define RST_DISABLE 1'b0

`define ZERO_WORD32 32'h00000000
`define ZERO_DWORD64 64'h0000000000000000
`define ZERO_QWORD128 128'h00000000000000000000000000000000
`define WR_ENABLE 1'b1
`define WR_DISABLE 1'b0
`define RD_ENABLE 1'b1
`define RD_DISABLE 1'b0
`define CHIP_ENABLE 1'b1
`define CHIP_DISABLE 1'b0
`define OPCODE_BUS_11 0:10

`define STOP 1'b1
`define NOSTOP 1'b0
`define PIPE_EVEN 1'b0
`define PIPE_ODD 1'b1

`define UID_0 3'b000
`define UID_1 3'b001
`define UID_2 3'b010
`define UID_3 3'b011
`define UID_4 3'b100
`define UID_5 3'b101
`define UID_6 3'b110
`define UID_7 3'b111

`define BRANCH 		4'h1

`define NOTBRANCH 1'b0
`define IN_DELAYSLOT 1'b1
`define NOT_IN_DELAYSLOT 1'b0

/*
`define InstValid 1'b0
`define InstInvalid 1'b1
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
*/

`define lqd             2'b01
`define stqd            2'b10
//Instructions
`define EXE_LQD		8'b00110100
`define EXE_STQD	8'b00100100
`define EXE_AH		11'b00011001000
`define EXE_AHI		8'b00011101
`define EXE_A		11'b00011000000
`define EXE_AI		8'b00011100
`define EXE_SFH		11'b00001001000
`define EXE_SFHI	8'b00001101
`define EXE_SF		11'b00001000000
`define EXE_SFI		8'b00001100
`define EXE_MPY		11'b01111000100
`define EXE_MPYU	11'b01111001100
`define EXE_MPYI	8'b01110100
`define EXE_AND		11'b00011000001
`define EXE_ANDBI	8'b00010110
`define EXE_ANDHI	8'b00010101
`define EXE_ANDI	8'b00010100
`define EXE_OR		11'b00001000001
`define EXE_ORBI	8'b00000110
`define EXE_ORHI	8'b00000101
`define EXE_ORI 	8'b00000100
`define EXE_XOR		11'b01001000001
`define EXE_XORBI	8'b01000110
`define EXE_XORHI	8'b01000101
`define EXE_XORI	8'b01000100
`define EXE_NAND	11'b00011001001
`define EXE_NOR		11'b00001001001
`define EXE_SHLQBI	11'b00111011011
`define EXE_SHLQBII	11'b00111111011
`define EXE_ROTQBY	11'b00111011111
`define EXE_ROTQBYI	11'b00111111111
`define EXE_CBD		11'b00111110100
`define EXE_CEQB	11'b01111010000
`define EXE_CEQBI	8'b01111110
`define EXE_CEQH	11'b01111001000
`define EXE_CEQHI	8'b01111101
`define EXE_CEQ		11'b01111000000
`define EXE_CEQI	8'b01111100
`define EXE_CGTB	11'b01001010000
`define EXE_CGTBI	8'b01001110
`define EXE_CGTH	11'b01001001000
`define EXE_CGTHI	8'b01001101
`define EXE_CGT		11'b01001000000
`define EXE_CGTI	8'b01001100
`define EXE_BR		9'b001100100
`define EXE_BRA		9'b001100000
`define EXE_BRSL	9'b001100110
`define EXE_BRASL	9'b001100010
`define EXE_BI		11'b00110101000
`define EXE_BISL	11'b00110101001
`define EXE_BRNZ	9'b001000010
`define EXE_BRZ		9'b001000000
`define EXE_BRHNZ	9'b001000110
`define EXE_BRHZ	9'b001000100
`define EXE_FA		11'b01011000100
`define EXE_FS		11'b01011000101
`define EXE_FM		11'b01011000110
`define EXE_FCEQ	11'b01111000010
`define EXE_FCGT	11'b01011000010
`define EXE_CNTB	11'b01010110100
`define EXE_AVGB	11'b00011010011
`define EXE_STOP	11'b00000000000
`define EXE_LNOP	11'b00000000001
`define EXE_NOP		11'b01000000001

//Local storage
`define LS_ADDR_BUS14 0:13
`define LS_ADDR_BUS18 0:17
`define LS_DATA_BUS128 0:127
`define LS_NUM_256K 16384 //256K=(16384*128)/8bit

//Cache
//`define CACHE_BUS4 0:3
`define INST_ADDR_BUS32 0:31
`define INST2_BUS64 0:63
`define INST_BUS32 0:31
//`define INST_ILB_SIZE32 32
`define CACHE_NUM_4K 1024  
`define MISS1 0:0
`define CACHE_INDEX10 0:9
`define CACHE_WIDTH53 0:52
`define CACHE_TAG20 0:19

//MEMEORY
`define MEMORY_WIDTH32 0:31
`define MEMORY_WIDTH128 0:127
`define MEMORY_256K 16384

//Register File
/*
//`define DoubleRegWidth 64
//`define DoubleRegBus 63:0
//`define RegNumLog2 7
*/

`define REG_ADDR_BUS7 0:6
`define REG_BUS128 0:127
`define REG_WIDTH128 128
`define REG_NUM128 128
`define NOP_REG_ADDR 7'b0000000

//OPERATION BYTES
`define HALFWORD0 0:15
`define HALFWORD1 16:31
`define HALFWORD2 32:47
`define HALFWORD3 48:63
`define HALFWORD4 64:79
`define HALFWORD5 80:95
`define HALFWORD6 96:111
`define HALFWORD7 112:127

`define WORD0 0:31
`define WORD1 32:63
`define WORD2 64:95
`define WORD3 96:127

`define HWORD_R16B0 16:31
`define HWORD_R16B1 48:63
`define HWORD_R16B2 80:95
`define HWORD_R16B3 112:127

`define BYTE0 0:7
`define BYTE1 8:15
`define BYTE2 16:23
`define BYTE3 24:31
`define BYTE4 32:39
`define BYTE5 40:47
`define BYTE6 48:55
`define BYTE7 56:63
`define BYTE8 64:71
`define BYTE9 72:79
`define BYTE10 80:87
`define BYTE11 88:95
`define BYTE12 95:111
`define BYTE13 80:95
`define BYTE14 96:111
`define BYTE15 112:127


