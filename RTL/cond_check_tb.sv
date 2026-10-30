module cond_check_tb;


	// Used for real flags set by the ALU (we're testing that too)
	// Only testing using CMP
	logic [31:0] a, b;
	logic [31:0] alu_result;
	logic [3:0]  alu_flags;      // {N, Z, C, V}
	logic [3:0]  cond_cmp;
	logic        pass_cmp;



	// Used for flags we set manually in the test bench
	logic [3:0] flags_dir;
	logic [3:0] cond_dir;
	logic       pass_dir;

	integer passed = 0;
	integer failed = 0;
	integer i, f;
	logic [31:0] x;


	alu arithmetic_check(
		.a(a),
		.b(b),
		.opcode(4'b1010),
		.result(alu_result),
		.flags(alu_flags)
	);

	// cond_check fed by flags we drive manually
	cond_check cc_direct (
		.flags(flags_dir),
		.cond(cond_dir),
		.pass(pass_dir)
	);

	// cond_check fed by the ALU's real flags
	cond_check cc_from_alu (
		.flags(alu_flags),
		.cond(cond_cmp),
		.pass(pass_cmp)
	);


	task automatic check_bit(
		input string test_name,
		input logic result,
		input logic expected_result,
		input logic [3:0] fl
	);
		begin
			if(result === expected_result)
				passed = passed + 1;
			else begin
				failed = failed + 1;
				$display("FAIL: %s | result=%b expected_result=%b | a=%h b=%h flags(NZCV)=%b",
							test_name, result, expected_result, a, b, fl);
			end
		end
	endtask

	// For one (a, b) pair: the ALU's CMP flags go into cond_check, and every
	// condition that has a natural SystemVerilog operator is checked against it
	task automatic test_pair(input logic [31:0] p, input logic [31:0] q);
	begin
		a = p;
		b = q;
		#1;

		cond_cmp = 4'b0000;
		#1;
		check_bit("EQ", pass_cmp, (a == b), alu_flags);

		cond_cmp = 4'b0001;
		#1;
		check_bit("NE", pass_cmp, (a != b), alu_flags);

		// unsigned
		cond_cmp = 4'b0010;
		#1;
		check_bit("HS", pass_cmp, (a >= b), alu_flags);

		cond_cmp = 4'b0011;
		#1;
		check_bit("LO", pass_cmp, (a <  b), alu_flags);

		cond_cmp = 4'b1000;
		#1;
		check_bit("HI", pass_cmp, (a >  b), alu_flags);

		cond_cmp = 4'b1001;
		#1;
		check_bit("LS", pass_cmp, (a <= b), alu_flags);

		// signed
		cond_cmp = 4'b1010;
		#1;
		check_bit("GE", pass_cmp, ($signed(a) >= $signed(b)), alu_flags);

		cond_cmp = 4'b1011;
		#1;
		check_bit("LT", pass_cmp, ($signed(a) <  $signed(b)), alu_flags);

		cond_cmp = 4'b1100;
		#1;
		check_bit("GT", pass_cmp, ($signed(a) >  $signed(b)), alu_flags);

		cond_cmp = 4'b1101;
		#1;
		check_bit("LE", pass_cmp, ($signed(a) <= $signed(b)), alu_flags);
	end
	endtask

	initial begin
		a = 32'd0;
		b = 32'd0;
		cond_cmp  = 4'b0;
		cond_dir  = 4'b0;
		flags_dir = 4'b0;
		#1;

		// ---- Edge cases ----
		test_pair(32'd0,          32'd0);
		test_pair(32'd1,          32'd1);
		test_pair(32'd0,          32'd1);
		test_pair(32'd1,          32'd0);
		test_pair(32'hFFFFFFFF,   32'd1);
		test_pair(32'd1,          32'hFFFFFFFF);
		test_pair(32'hFFFFFFFF,   32'hFFFFFFFF);
		test_pair(32'h7FFFFFFF,   32'h80000000);
		test_pair(32'h80000000,   32'h7FFFFFFF);
		test_pair(32'h80000000,   32'd1);
		test_pair(32'h7FFFFFFF,   32'hFFFFFFFF);
		test_pair(32'h80000000,   32'h80000000);

		// Random, plus values right next to each other
		for (i = 0; i < 300; i = i + 1) begin
			x = $urandom;
			test_pair($urandom, $urandom);
			test_pair(x, x);
			test_pair(x, x + 32'd1);
			test_pair(x, x - 32'd1);
		end

		// Conditions with no operator match, so drive flags directly 
		for (f = 0; f < 16; f = f + 1) begin
			flags_dir = f[3:0];
			#1;

			cond_dir = 4'b0100;
			#1;
			check_bit("MI", pass_dir, flags_dir[3], flags_dir);

			cond_dir = 4'b0101;
			#1;
			check_bit("PL", pass_dir, ~flags_dir[3], flags_dir);

			cond_dir = 4'b0110;
			#1;
			check_bit("VS", pass_dir, flags_dir[0], flags_dir);

			cond_dir = 4'b0111;
			#1;
			check_bit("VC", pass_dir, ~flags_dir[0], flags_dir);

			cond_dir = 4'b1110;
			#1;
			check_bit("AL", pass_dir, 1'b1, flags_dir);

			cond_dir = 4'b1111;
			#1;
			check_bit("NV", pass_dir, 1'b0, flags_dir);
		end

		$display("----------------------------");
		$display("Checks passed: %0d", passed);
		$display("Checks failed: %0d", failed);
		if (failed == 0) $display("ALL TESTS PASSED");
		else             $display("%0d TESTS FAILED", failed);
		$display("----------------------------");
		$stop;
	end



endmodule