module flag_reg(
	input logic [3:0] flags_in,
	output logic [3:0] flags_out,
	
	input logic reset, 
	input logic clk, 
	
	input logic we_nz,
	input logic we_cv
);
	// Use this to make sure the flags arent overriden
	// N Z C V
	always_ff @(posedge clk) begin
		if(reset)
			flags_out <= '0;
		// we_nz and we_cv are given by us when this runs in the head module (connects everything)
		else begin
			if(we_nz) // we_nz to update N and Z flags
				flags_out[3:2] <= flags_in [3:2];
			if(we_cv) // we_cv to update the C and V flags
				flags_out[1:0] <= flags_in[1:0];
		end
	end
	
endmodule