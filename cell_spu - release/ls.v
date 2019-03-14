//**************************************************************************************/
// Module:  	LS
// File:    	LS.v
// Description: Local Storage - 265KB
// History: 	Created by Ning Kang, Mar 18, 2018 
//		Modified by Ning Kang, Apr 20, 2018 - only data load/store
//***************************************************************************************/

`include "defines.v"

module LS(

	input wire clk,
	input wire ce,
	input wire we,
	input wire[`LS_ADDR_BUS18] addr, //2^18=256K bytes 
	input wire[`LS_DATA_BUS128] data_i,
	output reg[`LS_DATA_BUS128] data_o
	
);

	reg[`LS_DATA_BUS128] data_mem[0:`LS_NUM_256K-1]; // 256KB=((2^14)*128)/8

	initial $readmemh ( "ls.data", data_mem );

	always @ (posedge clk) begin
		if (ce == `CHIP_DISABLE) begin
			//data_o <= ZERO_QWORD128;
		end else if(we == `WR_ENABLE) begin
			//data_mem[addr|18'b111111111111110000] <= data_i;  
			data_mem[addr|18'h3fff0] <= data_i;	    
		end
	end
	
	always @ (posedge clk) begin
		if (ce == `CHIP_DISABLE) begin
			data_o <= `ZERO_QWORD128;
	  	end else if(we == `WR_DISABLE) begin
		    	//data_o <= data_mem[addr|18'b111111111111110000] ;
			data_o <= data_mem[addr|18'h3fff0] ;
		end else begin
			data_o <= `ZERO_QWORD128;
		end
	end		

endmodule