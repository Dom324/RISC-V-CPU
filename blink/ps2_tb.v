module testbench3();
reg clk, data, is_valid_exp;
wire is_valid;
wire [7:0] scancode, buffer;
reg [7:0] scancode_exp;
reg [31:0] vectornum, errors;
reg [9:0] testvectors[25:0];
wire [3:0] FSM, FSM_state_next;
// instantiate device under test
ps2_interface dut(clk, data, scancode, buffer, is_valid, FSM, FSM_state_next);
// generate clock
always
begin
clk = 1; #5; clk = 0; #5;
end
// at start of test, load vectors
// and pulse reset
initial
begin
$readmemb("testbench.dat", testvectors, 0, 25);
vectornum = 0; errors = 0;
end
// apply test vectors on rising edge of clk
always @(negedge clk)
begin
#1; {data, is_valid_exp, scancode_exp} = testvectors[vectornum];
end
// check results on falling edge of clk
always @(posedge clk) begin
if ((is_valid !== is_valid_exp) || (scancode !== scancode_exp)) begin // check result
$display("\nTest vector: %b", testvectors[vectornum]);
$display("Error: data = %b FSM: %b FSM next: %b", data, FSM, FSM_state_next);
$display(" outputs = %b (%b expected) %b (%b exp) \n", is_valid, is_valid_exp, scancode, scancode_exp);
errors = errors + 1;
end
$display("Test vector: %b", testvectors[vectornum]);
$display("FSM: %b next FSM %b buffer %b", FSM, FSM_state_next, buffer);
$display(" outputs = %b (%b expected) %b (%b exp) \n", is_valid, is_valid_exp, scancode, scancode_exp);
vectornum = vectornum + 1;
if (testvectors[vectornum] === 10'bx) begin
$display("%d tests completed with %d errors",
vectornum, errors);
$finish;
end
end
endmodule
