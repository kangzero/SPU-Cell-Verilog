//*************************************************************************************/
// Module:  	REGFILE
// File:    	regfile.v
// Description: Register File
//		SPU architecture defines a set of 128 general-purpose registers (GPRs), 
//		each of which contains 128 data bits. 
// History: 	Created by Ning Kang, Mar 25, 2018
//***************************************************************************************/

`include "defines.v"

module REGFILE(

	input wire clk,
	input wire rst,
	
	//Write register: even pipe w_e(rt_e) and odd pipe w_o(rt_o)
	input wire rt_we_e, rt_we_o, // rt: even write enable & odd write enable 
	input wire[`REG_ADDR_BUS7] rt_addr_e, rt_addr_o,// rt address
	input wire[`REG_BUS128] rt_data_e, rt_data_o, // rt data
	
	//Read register: even pipe ra_e, rb_e rt_e and odd pipe ra_o, rb_o, rt_o 
	input wire ra_e_e, rb_e_e, ra_e_o, rb_e_o, // even ra/rb enable & odd ra/rb enable
	input wire[`REG_ADDR_BUS7] ra_addr_e, rb_addr_e, ra_addr_o, rb_addr_o,

	output reg[`REG_BUS128] ra_data_e, rb_data_e, ra_data_o, rb_data_o
	
);
 
	reg[`REG_BUS128] regs[0:`REG_NUM128-1];
	
	//************************************************ Start... only for test
	initial begin
	regs[7'b0000001]<=128'h00010001000100010001000100010001;
	regs[7'b0000010]<=128'h00020002000200020002000200020002;
	/*
	regs[7'b0000000]<=128'h00000000000000000000000000000001;
	regs[7'b0000001]<=128'h00110011001100110011001100110011;
	regs[7'b0000010]<=128'h00000000000000000000000000000022;
	regs[7'b0000011]<=128'h33333333333333333333333333333333;
	regs[7'b0000100]<=128'h44444444444444444444444444444444;
	regs[7'b0000101]<=128'h55005500550055005500550055005500;
	regs[7'b0000110]<=128'h00000066000000660000006600000066;
	regs[7'b0000111]<=128'h55555555555555555555555555555555;
	regs[7'b0001000]<=128'haaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
	regs[7'b0001001]<=128'h00005555000055550000555500005555;
	regs[7'b0001010]<=128'h01550155015501550155015501550155;
	regs[7'b0001011]<=128'h00560056005600560056005600560056;
	regs[7'b0001100]<=128'h00001111000011110000111100001111;
	regs[7'b0001101]<=128'h55550000555500005555000055550000;
	regs[7'b0001110]<=128'h00000000111111110000000011111111;
	regs[7'b0001111]<=128'h55555555000000005555555500000000;
	*/
	end
	//***********************************************  Test end

	//RT write
	always @ (posedge clk) begin
		if (rst == `RST_DISABLE) begin
			if(rt_we_e == `WR_ENABLE) begin
				regs[rt_addr_e] <= rt_data_e;
			end
		end
		if (rst == `RST_DISABLE) begin
			if(rt_we_o == `WR_ENABLE) begin
				regs[rt_addr_o] <= rt_data_o;
			end
		end
	end
	
	//RA read 
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			ra_data_e <= `ZERO_WORD32;
	  	end else if((ra_addr_e == rt_addr_e) && (rt_we_e == `WR_ENABLE) && (ra_e_e == `RD_ENABLE)) begin //avoid RAW between 1st inst and 11th inst
			ra_data_e <= rt_data_e;
	  	end else if(ra_e_e == `RD_ENABLE) begin
	      		ra_data_e <= regs[ra_addr_e];
	  	end else begin
	      		ra_data_e <= `ZERO_WORD32;
	  	end

		if(rst == `RST_ENABLE) begin
			ra_data_o <= `ZERO_WORD32;
	  	end else if((ra_addr_o == rt_addr_o) && (rt_we_o == `WR_ENABLE) && (ra_e_o == `RD_ENABLE)) begin
			ra_data_o <= rt_data_o;
	  	end else if(ra_e_o == `RD_ENABLE) begin
	      		ra_data_o <= regs[ra_addr_o];
	  	end else begin
	      		ra_data_o <= `ZERO_WORD32;
	  	end
	end

	//RB read
	always @ (*) begin
		if(rst == `RST_ENABLE) begin
			rb_data_e <= `ZERO_WORD32;
	  	end else if((rb_addr_e == rt_addr_e) && (rt_we_e == `WR_ENABLE) && (rb_e_e == `RD_ENABLE)) begin
			rb_data_e <= rt_data_e; 
	  	end else if(ra_e_e == `RD_ENABLE) begin
	      		rb_data_e <= regs[rb_addr_e];
	  	end else begin
	      		rb_data_e <= `ZERO_WORD32;
	  	end

		if(rst == `RST_ENABLE) begin
			rb_data_o <= `ZERO_WORD32;
	  	end else if((rb_addr_o == rt_addr_o) && (rt_we_o == `WR_ENABLE) && (rb_e_o == `RD_ENABLE)) begin
			rb_data_o <= rt_data_o;
	  	end else if(rb_e_o == `RD_ENABLE) begin
	      		rb_data_o <= regs[rb_addr_o];
	  	end else begin
	      		rb_data_o <= `ZERO_WORD32;
	  	end
	end

endmodule