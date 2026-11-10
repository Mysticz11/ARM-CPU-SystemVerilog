
module alu_tb;

    logic [31:0] a, b;
    logic [3:0] opcode;
    logic [31:0] result;
    logic [3:0] flags;

    integer passed = 0;
    integer failed = 0;

    alu dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .flags(flags)
    );

	 // new thing, Task is the rough equivilant of a function 
	 // Task is used multiple times, each time it runs down below
	 // Hence the alu will be taking in new inupts and outputting different results.
    task automatic check(
        input [255:0] test_name,
        input [3:0] op,
        input [31:0] x,
        input [31:0] y,
        input [31:0] expected_result,
        input [3:0] expected_flags
    );
    begin
        opcode = op;
        a = x;
        b = y;
		  
		  // Used to wait 10 simulation time before continuing
		  // Just so it doesnt trip over itself
        #10;

        if (result !== expected_result ||
            flags !== expected_flags) begin
            $display("FAIL: %s", test_name);
            $display("  Result: expected %h, got %h",
                     expected_result, result);
            $display("  Flags:  expected %b, got %b",
                     expected_flags, flags);
            failed = failed + 1;
        end
        else begin
            $display("PASS: %s", test_name);
            passed = passed + 1;
        end
    end
    endtask

    initial begin
        // ADD
        check("ADD basic", 4'b0100,
              32'd5, 32'd3, 32'd8, 4'b0000);

        check("ADD carry", 4'b0100,
              32'hFFFFFFFF, 32'd1, 32'd0, 4'b0110);

        check("ADD overflow", 4'b0100,
              32'h7FFFFFFF, 32'd1,
              32'h80000000, 4'b1001);

        // SUB
        check("SUB basic", 4'b0010,
              32'd5, 32'd3, 32'd2, 4'b0010);

        check("SUB borrow", 4'b0010,
              32'd3, 32'd5, 32'hFFFFFFFE, 4'b1000);

        check("SUB overflow", 4'b0010,
              32'h80000000, 32'd1,
              32'h7FFFFFFF, 4'b0011);

        // AND
        check("AND", 4'b0000,
              32'hF0F0F0F0, 32'h0FF00FF0,
              32'h00F000F0, 4'b0000);

        // ORR
        check("ORR", 4'b1100,
              32'hF0000000, 32'h0000000F,
              32'hF000000F, 4'b1000);

        // EOR
        check("EOR", 4'b0001,
              32'hAAAAAAAA, 32'h55555555,
              32'hFFFFFFFF, 4'b1000);
	
        check("EOR zero", 4'b0001,
              32'h12345678, 32'h12345678,
              32'h00000000, 4'b0100);

        // MOV
        check("MOV", 4'b1101,
              32'd0, 32'h80000000,
              32'h80000000, 4'b1000);

        // CMP
        check("CMP equal", 4'b1010,
              32'd5, 32'd5, 32'd0, 4'b0110);

        check("CMP borrow", 4'b1010,
              32'd3, 32'd5, 32'hFFFFFFFE, 4'b1000);
	
			// Edge cases
			check("SUB zero minus one", 4'b0010,
					32'd0, 32'd1, 32'hFFFFFFFF, 4'b1000);

			check("SUB equal", 4'b0010,
					32'h12345678, 32'h12345678, 32'd0, 4'b0110);

        $display("----------------------------");
        $display("Passed: %0d", passed);
        $display("Failed: %0d", failed);
        $display("----------------------------");

        $stop;
    end

endmodule
