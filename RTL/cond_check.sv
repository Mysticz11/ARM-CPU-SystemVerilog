module cond_check (
	input logic [3:0] flags,
	input logic [3:0] cond,
	output logic pass
);
	
	always_comb begin
		
		pass = 0;
		
		case (cond)
			
			4'b0000: begin
				if(flags[2] == 1) // EQ
					pass = 1;
			end
			
			4'b0001:begin
				if(flags[2] == 0) //NE
					pass = 1;
			end
			
			4'b0010: begin
				if(flags[1] == 1) //CS or HS
					pass = 1;
			end
			
			
			4'b0011: begin
				if(flags[1] == 0) // CC or LO
					pass = 1;
			end
			
			4'b0100: begin
				if(flags[3] == 1) // MI
					pass = 1;
			end
			
			4'b0101: begin
				if(flags[3] == 0) // PL
					pass = 1;
			end
			
			4'b0110: begin
				if(flags[0] == 1) // VS
					pass = 1;
			end
			
			4'b0111: begin
				if(flags[0] == 0) // VC
					pass = 1;
			end
			
			4'b1000: begin
				if((flags[1] == 1) && (flags[2] == 0)) // HI
					pass = 1;
			end
			
			4'b1001: begin
				if((flags[1] == 0) || (flags[2] == 1)) // LS
					pass = 1;
			end
			
			4'b1010: begin
				if(flags[3] == flags[0]) // GE
					pass = 1;
			end
		
			4'b1011: begin
				if(flags[3] != flags[0]) // LT
					pass = 1;
			end
			
			4'b1100: begin
				if((flags[2] == 0) && (flags[3] == flags[0])) // GT
					pass = 1;
			end
			
			4'b1101: begin
				if((flags[2] == 1) || (flags[3] != flags[0])) // LE
					pass = 1;
			end
			
			4'b1110: pass = 1; // AL
			
			4'b1111: pass = 0 ;// NV
			
			default: pass = 0;
		
		endcase
	end
	
endmodule

