`include "defines.v"
module MEMORY(
	input wire clk,
	input wire enable,
	input wire[`INST_ADDR_BUS32]inst_addr,
	input wire[`INST_ADDR_BUS32]data_addr,
	input wire write_enable,
	input wire[`MEMORY_WIDTH128] data_in,
	output reg[`MEMORY_WIDTH128] data_out,
	output reg[`MEMORY_WIDTH32] inst_out,
	output reg[`MEMORY_WIDTH32] inst_addr_to_cache
);
	//memory is  128bits*1628
	//total memory size is 256k
	reg[`MEMORY_WIDTH128] memory_data[0:`MEMORY_256K-1];
	reg[`MEMORY_WIDTH128] temp;
	reg[0:1] offset;

	initial $readmemh ( "memory.data", memory_data );
	
	always @(*) begin
		if (~enable)	begin
			//data_out<=`ZERO_QWORD128;
			//inst_out<=`ZERO_WORD32;
		end
		else begin
			// store data to memory
			if (write_enable) begin
					//decode the data adddress to sovle structure hazard
					if (data_addr[13]==1'b1)
						//if the 13th bit of address is 1 
						//means the address is in the data memory parition
						memory_data[data_addr[14:27]]<=data_in;
					end
	
			else begin
				//fetch data to register
				data_out<=memory_data[data_addr[14:27]];
				
				//send instruction data to cache				
				temp<=memory_data[inst_addr[14:27]];
				offset<=inst_addr[28:29];
				if (offset==2'b00)
				inst_out<=temp[0:31];
				else if (offset==2'b01)
				inst_out<=temp[32:63];
				else if (offset==2'b10)
				inst_out<=temp[64:95];
				else if (offset==2'b11)
				inst_out<=temp[96:127];
			inst_addr_to_cache<=inst_addr;
			end
		end
	end
endmodule
