//**************************************************************************************/
// Module:  	SPE
// File:    	spe.v
// Description: the top level file of SPE
// History: 	Created by Ning Kang, Mar 31, 2018 
//***************************************************************************************/

//test bench indicate the signal of clock and the reset.
`timescale 1ns/1ps

module TB_SPE;

	reg CLOCK_50;
  	reg rst;
       
  	initial begin
    		CLOCK_50 = 1'b0;
    		forever #10 CLOCK_50 = ~CLOCK_50;
  	end
      
  	initial begin
    		rst = 1'b1;
    		#195 rst= 1'b0;
    		#1000 $stop;
  	end
       
  	SPE dut(
		.clk(CLOCK_50),
		.rst(rst)
);

endmodule
