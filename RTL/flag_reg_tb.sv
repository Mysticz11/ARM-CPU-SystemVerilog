module flag_reg_tb;
	
	logic clk;
	logic reset;
	
	logic flags_in;
	logic flags_out;
	
	logic we_nz;
	logic we_cv;
	
	
	// Generating our own clock, chagnes every 5 nanoseconds
	initial clk = 0;
	always #5 clk = ~clk;



endmodule
