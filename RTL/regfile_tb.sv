module regfile_tb;

	logic rst;
	logic clk;
	logic control_write;
	
	logic [3:0] ra1, ra2, wa;
	logic [31:0] rd1, rd2, wd;

	
    regfile dut (
        .clk(clk),
        .rst(rst),
        .control_write(control_write),
        .ra1(ra1),
        .ra2(ra2),
        .rd1(rd1),
        .rd2(rd2),
        .wa(wa),
        .wd(wd)
    );	
	 
	 // Generating our own clock, chagnes every 5 nanoseconds
	 initial clk = 0;
	 always #5 clk = ~clk;
	 
	task check_read(
		input logic [31:0] expected1,
      input logic [31:0] expected2,
      input string test_name
	 ); 
		 begin
			#1
			if(rd1 === expected1 && rd2 === expected2)
				$display("PASS: %s", test_name);
			else begin
				$display("FAIL: %s | rd1=%h expected=%h | rd2=%h expected=%h",
							test_name, rd1, expected1, rd2, expected2);
				$stop;
			end
		end
	endtask
	
	initial begin

		//For future refernce, this whole thing is just waiting for a positive clock edge
		//Then we change the signals and check the expected outputs and the actual outputs
		rst = 1;
		control_write = 0;
		ra1 = 0;
		ra2 = 0;
		wa = 0;
		wd = 0;

		// Reset all registers
		@(posedge clk);
		#1;
		rst = 0;

		// Gets the register refile to look at registers 3 & 7
		ra1 = 3;
		ra2 = 7;
		
		// Checks if the values at R3 and R7 match with expected values
		// Same pattern for the rest
		check_read(32'b0, 32'b0, "Reset clears registers");

		// Write to R3
		@(negedge clk);
		wa = 3;
		wd = 32'd42;
		control_write = 1;

		@(posedge clk);
		#1;
		control_write = 0;
		ra1 = 3;
		ra2 = 7;
		check_read(32'd42, 32'b0, "Write and read R3");

		// Write to R7
		@(negedge clk);
		wa = 7;
		wd = 32'd99;
		control_write = 1;

		@(posedge clk);
		#1;
		control_write = 0;
		ra1 = 3;
		ra2 = 7;
		check_read(32'd42, 32'd99, "Read two registers");

		// Disabled write must not change R3
		@(negedge clk);
		wa = 3;
		wd = 32'd123;
		control_write = 0;

		@(posedge clk);
		ra1 = 3;
		ra2 = 7;
		check_read(32'd42, 32'd99, "Write disabled");

		// R0 is an ordinary writable register in this design
		@(negedge clk);
		wa = 0;
		wd = 32'd55;
		control_write = 1;

		@(posedge clk);
		#1;
		control_write = 0;
		ra1 = 0;
		ra2 = 3;
		check_read(32'd55, 32'd42, "Write and read R0");

		// Reset again after writing values
		@(negedge clk);
		rst = 1;

		@(posedge clk);
		#1;
		rst = 0;
		ra1 = 0;
		ra2 = 3;
		check_read(32'b0, 32'b0, "Reset clears written values");

		$display("All register file tests passed.");
		$stop;
	end


endmodule
 


