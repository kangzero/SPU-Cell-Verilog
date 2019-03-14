//**************************************************************************************/
// Module:  	Control
// File:    	CTRL.v
// Description: CTRL module for pipeline stall 
// History: 	Created by Ning Kang, Apr 20, 2018 
//***************************************************************************************/

`include "defines.v"

/*
stall <= 13'b0000000001  //PC holds
stall <= 13'b0000000011  //IF stall
stall <= 13'b0000000111	 //ID stall	
stall <= 13'b0000001111  //EX stall
stall <= 13'b0000011111	 //MEM stall
stall <= 13'b0000111111  //WR stall
*/
module CTRL(
	input rst,
	input wire stallreq_fr_id,
	input wire stallreq_dh,
	input wire stallreq_fr_ex,
	input wire stallreq_fr_cache,
	output reg [0:12] stall
);

	always @ (*) begin
		if (rst == `RST_ENABLE) begin
			stall <= 13'b0000000000;
		end else if (stallreq_fr_ex == `STOP) begin
			stall <= 13'b0000001111;
		end else if (stallreq_fr_id == `STOP) begin
			stall <= 13'b0000000111;
		end else if (stallreq_fr_cache == `STOP) begin
			stall <= 13'b0000000011;
		end else if (stallreq_dh == `STOP) begin
			stall <= 13'b0000001000;
		end else begin
			stall <= 13'b0000000000;
		end
	end
endmodule
