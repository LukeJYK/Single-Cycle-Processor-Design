module instr_fetch_unit(
//input
clk,
rstb,
branch,
jump,
instr,
//output
current_pc,
regS_addr,
regT_addr,
regD_addr,
imm16
);
input clk,rstb,branch,jump;
input [31:0] instr;
output reg [29:0] current_pc;
output wire [4:0] regS_addr;
output wire [4:0] regT_addr;
output wire [4:0] regD_addr;
output wire [15:0] imm16;

wire [29:0] next_pc;
wire [29:0] pc_plus4;
wire [29:0] pc_plus4_plusimm16;
//* 

//for register file
assign regS_addr = instr[25:21];
assign regT_addr = instr[20:16];
assign regD_addr = instr[15:11];
// sign extension for imm16
wire [29:0] imm16_exted;
assign imm16 = instr[15:0];
assign imm16_exted = {{14{imm16[15]}},imm16[15:0]};

//jump address generation
wire [29:0] pc_wijump;
assign pc_wijump = {current_pc[29:26],instr[25:0]};
wire [29:0] pc_wojump;
//register address distribution
assign regS = instr[25:21];
assign regT = instr[20:16];
assign regD = instr[15:11];

//for adder compensate
wire [31:0] pc_plus4_plusimm16_temp;
wire [31:0] pc_plus4_temp;
assign pc_plus4_plusimm16 = pc_plus4_plusimm16_temp[29:0];
assign pc_plus4 = pc_plus4_temp[29:0];

mux_nbit #(.n(30)) mux_nextpc(
.sel({29'b0,jump}),
.src0(pc_wojump),
.src1(pc_wijump),
.z(next_pc)
);

mux_nbit #(.n(30)) mux_branchzero(
.sel({29'b0,branch}),
.src0(pc_plus4),
.src1(pc_plus4_plusimm16),
.z(pc_wojump)
);

adder_32bit adder_branchzero(
.in_a({{2{pc_plus4[29]}},pc_plus4}),
.in_b({{2{imm16_exted[29]}},imm16_exted}),
.cin(1'b0),
.sum(pc_plus4_plusimm16_temp)
);

adder_32bit adder_pc_plus4(
.in_a({{2{current_pc[29]}},current_pc}),
.in_b({31'h00000000,1'b1}),
.cin(1'b0),
.sum(pc_plus4_temp)
);

//and_gate and_gate(
//.x(branch),
//.y(zero),
//.z(branchzero)
//);

always @(posedge clk or negedge rstb) begin
	if (~rstb) begin
		current_pc <= 30'b000000000100000000000000001000;
	end
	else begin
		current_pc <= next_pc;
	end
end

endmodule



