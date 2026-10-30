module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  opcode,

    output logic [31:0] result,
	 output logic [3:0] flags
);

	logic [32:0] raw_result;
	
	always_comb begin
		result = '0;
		raw_result = '0;
		flags = '0;
		
		case (opcode) 
			4'b0100: begin 
			raw_result = {1'b0, a} + {1'b0, b};  // ADD
			result = raw_result[31:0];
			end 
			4'b0010: begin
				raw_result = {1'b0, a} - {1'b0, b};  // SUB
				result = raw_result[31:0];
			end
			4'b0000: begin
				result = a & b;  // AND
				raw_result = {1'b0, result};
			end
			4'b1100: begin
				result = a | b;  // OR (ORR)
				raw_result = {1'b0, result}; // Padding for raw_result (its 33 bits)
			end
			4'b0001: begin
				result = a ^ b;  // XOR (EOR)
				raw_result = {1'b0, result};
			end
			4'b1101: begin
			raw_result = b;      // MOV
			result = raw_result[31:0];
			end
			
			4'b1010: begin // CMP
				raw_result = {1'b0, a} - {1'b0, b};  // SUB
				result = raw_result[31:0];
			end
			

			default: result = '0;
		endcase
		
		flags = update_flags(result, raw_result, a, b, opcode);
		
	end
	
	// Flags order is N Z C V
	function automatic logic [3:0] update_flags(
		input logic [31:0] results, 
		input logic [32:0] raw_results,
		
		input logic [31:0] a,
		input logic [31:0] b,
		input logic [3:0] opcode
		); 
			
		logic [3:0] flags_results;
		flags_results = '0;
		
		// Zero
		if(results == 0)
			flags_results[2] = 1;
			
		// Negative
		if (results[31] == 1)
			flags_results[3] = 1;
			
		// Carry		
		// Sub carry is weird, need fancy stuff (this accounts for CMP as well)
		if ((opcode == 4'b0010) || (opcode == 4'b1010))
			 flags_results[1] = (a >= b); // Subtraction needs no borrow, so C = 1
		else
			 flags_results[1] = raw_results[32]; // Otherwise it borrows, so C = 0
		
		// Overflow	ADD	
		if((opcode == 4'b0100) && (~(a[31] ^ b[31]) & (results[31] ^ a[31])))
			flags_results[0] = 1;
			
		// Overflow SUB
		if(((opcode == 4'b0010) || (opcode == 4'b1010)) && ((a[31] ^ b[31]) & (results[31] ^ a[31])))
			flags_results[0] = 1;
		
				
		return flags_results;
	endfunction
endmodule
