module scp_controller(
//input
opCode,
eqzero,
not_eqzero,
greater,
func,
//output
ALUctrl,
RegDst,
RegWr,
Branch,
Jump,
ALUSrc,
MemWr,
MemtoReg,
ExtOp
);
input [5:0] opCode;
input [5:0] func;
input eqzero;
input not_eqzero;
input greater;
output [2:0] ALUctrl;
output RegDst;
output RegWr;
output Branch;
output Jump;
output ALUSrc;
output MemWr;
output MemtoReg;
output ExtOp;

wire not_op0;
wire not_op1;
wire not_op2;
wire not_op3;
wire not_op4;
wire not_op5;

//wire [2:0] ALUop;

wire Rtype;
wire lw;
wire sw;
wire beq;
wire bneq;
wire bgtz;
wire addi;


wire or1;
wire or2;
wire or3;
wire or4;
wire and1;
wire and2;
wire and3;
wire [2:0] aluop;

assign RegDst = Rtype;
assign MemWr = sw;
assign MemtoReg = lw;
assign Jump = 0;


assign aluop[2] = Rtype;
assign aluop[1] = 0;

//not opCode
not_gate note_gate0(
.x(opCode[0]),
.z(not_op0)
);

not_gate note_gate1(
.x(opCode[1]),
.z(not_op1)
);

not_gate note_gate2(
.x(opCode[2]),
.z(not_op2)
);

not_gate note_gate3(
.x(opCode[3]),
.z(not_op3)
);

not_gate note_gate4(
.x(opCode[4]),
.z(not_op4)
);

not_gate note_gate5(
.x(opCode[5]),
.z(not_op5)
);

//R-type
and_6unit R_and(
.and0(not_op0),
.and1(not_op1),
.and2(not_op2),
.and3(not_op3),
.and4(not_op4),
.and5(not_op5),
.and_result(Rtype)
);


//lw
and_6unit lw_and(
.and0(opCode[0]),
.and1(opCode[1]),
.and2(not_op2),
.and3(not_op3),
.and4(not_op4),
.and5(opCode[5]),
.and_result(lw)
);
//sw
and_6unit sw_and(
.and0(opCode[0]),
.and1(opCode[1]),
.and2(not_op2),
.and3(opCode[3]),
.and4(not_op4),
.and5(opCode[5]),
.and_result(sw)
);
//beq
and_6unit beq_and(
.and0(not_op0),
.and1(not_op1),
.and2(opCode[2]),
.and3(not_op3),
.and4(not_op4),
.and5(not_op5),
.and_result(beq)
);
//bneq
and_6unit bneq_and(
.and0(opCode[0]),
.and1(not_op1),
.and2(opCode[2]),
.and3(not_op3),
.and4(not_op4),
.and5(not_op5),
.and_result(bneq)
);
//bgtz
and_6unit bgtz_and(
.and0(opCode[0]),
.and1(opCode[1]),
.and2(opCode[2]),
.and3(not_op3),
.and4(not_op4),
.and5(not_op5),
.and_result(bgtz)
);
//addi
and_6unit addi_and(
.and0(not_op0),
.and1(not_op1),
.and2(not_op2),
.and3(opCode[3]),
.and4(not_op4),
.and5(not_op5),
.and_result(addi)
);




//ExtOp
or_gate or_gate1(
.x(lw),
.y(sw),
.z(ExtOp)
);
//RegWrite
or_gate or_gate2(
.x(Rtype),
.y(addi),
.z(or1)
);
or_gate or_gate3(
.x(or1),
.y(lw),
.z(RegWr)
);

//ALUSrc
or_gate or_gate4(
.x(addi),
.y(lw),
.z(or2)
);
or_gate or_gate5(
.x(or2),
.y(sw),
.z(ALUSrc)
);

//alu op 0
or_gate or_gate6(
.x(beq),
.y(bneq),
.z(or3)
);
or_gate or_gate7(
.x(or3),
.y(bgtz),
.z(aluop[0])
);

//branch
and_gate branch1(
.x(beq),
.y(eqzero),
.z(and1)
);
and_gate branch2(
.x(bneq),
.y(not_eqzero),
.z(and2)
);
and_gate branch3(
.x(bgtz),
.y(greater),
.z(and3)
);
or_gate branch4(
.x(and1),
.y(and2),
.z(or4)
);
or_gate branch5(
.x(or4),
.y(and3),
.z(Branch)
);
//alu ctrl
alu_control alu_control(
.func(func),
.ALUop(aluop),
//output
.ALUctrl(ALUctrl)
);
endmodule