module flag_reg_tb;
	
	logic clk;
	logic reset;
	
	logic [3:0] flags_in;
	logic [3:0] flags_out;
	
	logic we_nz;
	logic we_cv;
	
	
	integer passed = 0;
   integer failed = 0;

	
	
	flag_reg inst1(
		.flags_in(flags_in),
		.flags_out(flags_out),
		.reset(reset),
		.clk(clk),
		.we_nz(we_nz),
		.we_cv(we_cv)
	);
	
	// Generating our own clock, chagnes every 5 nanoseconds
	initial clk = 0;
	always #5 clk = ~clk;
	
	task flag_check(
		input logic [3:0] expected_flags,
		input string test_name
	);
		begin
		#1;
			if(flags_out === expected_flags) begin
				$display("PASS: %s", test_name);
				passed = passed + 1;
			end
			else begin
				$display("FAIL: %s | flags_out=%h expected_flags=%h",
							test_name, flags_out, expected_flags);
				failed = failed + 1;
				$stop;
			end
		end
	endtask
	
	
	// Puts the inputs on the falling edge, thehn waits for the rising edge to capture them
	task write_flags(
		input logic [3:0] new_flags,
		input logic new_nz,
		input logic new_cv
	);
		begin 
			@(negedge clk);
			reset = 0;
			flags_in = new_flags;
			we_nz = new_nz;
			we_cv = new_cv;
			@(posedge clk);
		end
	endtask	
		
	// Keeps the reset across a rising edge, checks if the flags are 0000, then releases the reset
	task reset_and_check(input string test_name);
		begin
			reset = 1;
			we_nz = 0;
			we_cv = 0;
			
			@(posedge clk);
				flag_check(4'b0000, test_name);
			@(negedge clk);
				reset = 0;
		end
	endtask
	
	// Gives a starting value, then writes a new one with given enables 
	// Compares them against the expected value (Made by me)
	task test_write(
		input logic [3:0] starting_flags,
		input logic [3:0] new_flags,
		input logic       enable_nz,
		input logic       enable_cv,
		input logic [3:0] expected_flags,
		input string      test_name
	);
		begin
			write_flags(starting_flags, 1, 1); // the before state
			write_flags(new_flags, enable_nz, enable_cv);
			flag_check(expected_flags, test_name);
		end
	endtask
		
	// Computes what the flags should be
	function automatic logic [3:0] compute_expected_flags(
		input logic [3:0] starting_flags,
		input logic [3:0] new_flags,
		input logic       enable_nz,
		input logic       enable_cv
	);
		logic [1:0] expected_nz;
		logic [1:0] expected_cv;
		begin
			expected_nz = enable_nz ? new_flags[3:2]: starting_flags[3:2];
			expected_cv = enable_cv ? new_flags[1:0]: starting_flags[1:0];
			compute_expected_flags = {expected_nz, expected_cv};
		end
	endfunction
	
	logic [3:0] combo_starting_flags;
	logic [3:0] combo_new_flags;
	logic [1:0] combo_enables;
	
	initial begin
		// Testing sequence
		// We know the values at T = 0, so nothing starts as X
		reset = 0;
		flags_in = 4'b0000;
		we_nz = 0;
		we_cv = 0;
		
		
		// Check reset
		reset_and_check("Reset from boot");

		write_flags(4'b1111, 1, 1);
		flag_check(4'b1111, "Loading 1111");
		reset_and_check("Reset clears 1111"); 
		
		// Directed cases, crossed or swapped bits
		test_write(4'b0101, 4'b1010, 1, 1, 4'b1010, "0101->1010 both");
		test_write(4'b0101, 4'b1010, 1, 0, 4'b1001, "0101->1010 nz only");
		test_write(4'b0101, 4'b1010, 0, 1, 4'b0110, "0101->1010 cv only");
		test_write(4'b0101, 4'b1010, 0, 0, 4'b0101, "0101->1010 none");
		test_write(4'b1010, 4'b0101, 1, 0, 4'b0110, "1010->0101 nz only");

		// Directed cases, all zeroes & all ones opposites
		test_write(4'b0000, 4'b1111, 1, 1, 4'b1111, "0000->1111 both");
		test_write(4'b0000, 4'b1111, 1, 0, 4'b1100, "0000->1111 nz only");
		test_write(4'b0000, 4'b1111, 0, 1, 4'b0011, "0000->1111 cv only");
		test_write(4'b0000, 4'b1111, 0, 0, 4'b0000, "0000->1111 none");
		test_write(4'b1111, 4'b0000, 1, 1, 4'b0000, "1111->0000 both");
		test_write(4'b1111, 4'b0000, 1, 0, 4'b0011, "1111->0000 nz only");
		test_write(4'b1111, 4'b0000, 0, 1, 4'b1100, "1111->0000 cv only");
		test_write(4'b1111, 4'b0000, 0, 0, 4'b1111, "1111->0000 none");
		
		// Holds flags & stays put with both the enables off while flags-in changes
		write_flags(4'b1010, 1, 1);
		flag_check(4'b1010, "Hold, load 1010");
		repeat (4) begin
			write_flags($urandom_range(0, 15), 0, 0);
			flag_check(4'b1010, "Hold, enables off");
		end
		
		// Gets a bunch of combos, 16 starting values x 16 new values x 4 enable combos
		for (int start_index = 0; start_index < 16; start_index++) begin
			combo_starting_flags = start_index;
			for(int new_index = 0; new_index < 16; new_index++) begin
			combo_new_flags = new_index;
				for(int combo_enable = 0; combo_enable <4; combo_enable++) begin
					combo_enables = combo_enable;
					write_flags(combo_starting_flags, 1, 1);
					write_flags(combo_new_flags, combo_enables[1], combo_enables[0]);
					flag_check(
					compute_expected_flags(combo_starting_flags, 
					combo_new_flags, combo_enables[1], combo_enables[0]), 
					$sformatf("combo start=%b new=%b nz=%b cv=%b",
										 combo_starting_flags, combo_new_flags,
										 combo_enables[1], combo_enables[0]));
									
				end
			end	
		end
		
		// Total summary
		$display("--------------------------------");
		$display("flag_reg_tb done: %0d passed, %0d failed", passed, failed);
		if (failed == 0) $display("ALL TESTS PASSED");
		else                   $display("SOME TESTS FAILED");
		$finish;
	end
	
endmodule
