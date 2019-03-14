//**************************************************************************************/
// Module:  	CACHE
// File:    	Cache.v
// Description: Cache instance - 4KB
// History: 	Created by Ning Kang, Apr 20, 2018 
//***************************************************************************************/

`include "defines.v"

module CACHE(

	input wire clk,
	input wire ce,
	input wire[`INST_ADDR_BUS32] pc, //32bits
	input wire[`INST_BUS32] inst_from_memory,
	input wire[`INST_BUS32] addr_from_memory,
	output reg[`INST2_BUS64] inst, //64bits for 2 inst
	output reg[`MISS1] miss,
	output reg[`INST_ADDR_BUS32] addr_to_memory
	
);

	reg[`CACHE_WIDTH53] ins_cc[0:`CACHE_NUM_4K-1]; //fetch instruction from 4K Cache
	reg[`INST_ADDR_BUS32] addr2;//addr2 is the addr for inst2 addr2=addr+4
	reg[`INST_BUS32] inst1;
	reg[`INST_BUS32] inst2;
	reg[`CACHE_INDEX10] index1;
	reg[`CACHE_TAG20] tag1;
	reg[`CACHE_INDEX10] index2; //index for inst2
	reg[`CACHE_TAG20] tag2;//tag for inst2
	reg[`MISS1] miss1;
	reg[`MISS1] miss2;

	initial $readmemb ( "cache.data", ins_cc );

	always @ (posedge clk) 
	begin  
		if (ce == `CHIP_DISABLE) 
			begin 
				inst <= `ZERO_DWORD64;
	  		end 
		else 
			begin
			//decode the address get the cache_index and tag
			index1=pc[20:29];
			tag1=pc[0:19];
			addr2=pc+32'h4;	
			index2=addr2[20:29];
			tag2=addr2[0:19];
			
			//check the valid bit and tag 
			if (ins_cc[index1][0:0] && (ins_cc[index1][1:20])==tag1) 
				begin
				// fetch instrutions from Cache!!!
				inst1= ins_cc[index1]; 
				miss1=1'b0;
				end
			else
				//miss condition
				begin
				miss1=1'b1;
				addr_to_memory=pc;
				end

			//check the instrucation2
			if (ins_cc[index2][0:0] && (ins_cc[index2][1:20])==tag2) 
				begin
				// fetch instrutions from Cache!!!
				inst2= ins_cc[index2]; 
				miss2=1'b0;
				end
			else
				//miss condition
				begin
				miss2=1'b1;
				addr_to_memory=addr2;
				end
				
			//send the miss flag to contrl unit
			miss=(miss1 || miss2);
			
			//join inst1 and inst2 together
			if (miss==0)
				inst={inst1,inst2};
			end
	end

	
	//miss condition, fetch data from memory to cache
	always@(*)
	begin
		ins_cc[addr_from_memory[20:29]]<={1'b1,addr_from_memory[0:19],inst_from_memory};
	end
endmodule