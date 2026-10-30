module regfile (
	input logic clk,
	input logic rst,
	input logic control_write,
	
	input logic [3:0] ra1,
	input logic [3:0] ra2,
	output logic [31:0] rd1,
	output logic [31:0] rd2,
	
	input logic [3:0] wa,
	input logic [31:0] wd
);

	logic [31:0] registers [0:15];
	
	always_comb begin
		rd1 = registers[ra1];
		rd2 = registers[ra2];
	end
	
	always_ff @(posedge clk) begin
		if(rst) begin
			for(int i = 0; i < 16; i = i + 1) begin
				registers[i] <= '0; 
			end
		end
		
		else if(control_write)
			registers[wa] <= wd;
		
	end
	

endmodule

