`timescale 1ns/1ps
module scp_top(
//input
clk,
rstb,
//output
);
//parameter
parameter DATAWIDTH = 32;
parameter ADDRESSWIDTH = 5;
parameter data_file_name = "";
parameter instr_file_name = "";
//input
input clk;
input rstb;


//output



//reg




//wire
//register file
wire [ADDRESSWIDTH - 1 : 0] regW_wr_addr;
//wire [ADDRESSWIDTH - 1 : 0] regA_rd_addr;
//wire [ADDRESSWIDTH - 1 : 0] regB_rd_addr;
wire reg_wr_en;
wire [DATAWIDTH - 1 : 0] regW_wr_data;
wire [DATAWIDTH - 1 : 0] regA_rd_data;
wire [DATAWIDTH - 1 : 0] regB_rd_data;
//ALU
wire [DATAWIDTH - 1 : 0] alu_input_b;
wire [DATAWIDTH - 1 : 0] alu_output;
//*add equal and not_equal
wire [2:0] alu_ctrl;
wire equal;
wire not_equal;

//data_cache
wire [DATAWIDTH - 1 : 0] dc_output;


//extender
wire [DATAWIDTH - 1 : 0] extender_output;
//from controller
wire alu_src_ctrl;
wire data_cache_wr_en;
wire data_cache_wr_enb;
wire mem2reg_ctrl;
wire ext_ctrl;
wire reg_dst;
wire jump;
wire branch;
//to controller
wire [DATAWIDTH - 1 : 0] instr;
wire greater;
//for IF
wire [ADDRESSWIDTH - 1 : 0] regS_addr;
wire [ADDRESSWIDTH - 1 : 0] regT_addr;
wire [ADDRESSWIDTH - 1 : 0] regD_addr;
wire [DATAWIDTH/2 - 1 : 0] imm16;
//for instr_cache
wire [DATAWIDTH - 1 : 0] instr_addr;
assign instr_addr[1:0] = 2'b00; 


not_gate not_gate1(
.x(data_cache_wr_en),
.z(data_cache_wr_enb)
);

mux_nbit #(.n(5)) mux_regW_data(
.sel({{4'b0},reg_dst}),
.src0(regT_addr),
.src1(regD_addr),
.z(regW_wr_addr)
);

register_file RF(
.clk(clk),
.rstb(rstb),
.rdA_addr(regS_addr),
.rdB_addr(regT_addr),
.rdA_data(regA_rd_data),
.rdB_data(regB_rd_data),
.wr_addr(regW_wr_addr),
.wr_data(regW_wr_data),
.wr_en(reg_wr_en)
);

mux_32 mux_reg2alu(
.sel({{31{1'b0}},alu_src_ctrl}),
.src0(regB_rd_data),
.src1(extender_output),
.z(alu_input_b)
);

extender extender(
.in(imm16),
.ext_ctrl(ext_ctrl),
.out(extender_output)
);

ALU ALU(
.ctrl(alu_ctrl),		//TBD from control logic
.A(regA_rd_data),
.B(alu_input_b),
.shamt(instr[10:6]), 		//TBD from control logic
.cout(),		//not sure if use,probably output of top
.ovf(),			//not sure if use,probably output of top
.ze(equal),			//not sure if use,probably equal signal
.R(alu_output)
);

sram_fix #(.mem_file(data_file_name)) data_cache(
.cs(1'b1),
.oe(data_cache_wr_enb),  	//data cache read should be always on
.we(data_cache_wr_en),
.addr(alu_output),
.din(regB_rd_data),
.dout(dc_output)
);

mux_32 mux_mem2reg(
.sel({31'b0,mem2reg_ctrl}),
.src0(alu_output),
.src1(dc_output),
.z(regW_wr_data)
);

instr_fetch_unit IF(
.clk(clk),
.rstb(rstb),
.branch(branch),
//delete equal
.jump(jump),
.instr(instr), //TBD,connected to instr mem
.current_pc(instr_addr[31:2]), //TBD,connected to instr mem
.regS_addr(regS_addr),
.regT_addr(regT_addr),
.regD_addr(regD_addr),
.imm16(imm16)
);

sram_fix #(.mem_file(instr_file_name)) instr_cache(  //fake file name
.cs(1'b1),
.oe(1'b1),  		//instr cache read should be always on
.we(1'b0),
.addr(instr_addr),
.din(32'h00000000),
.dout(instr)
);

//*prepare for bneq judge signal
not_gate not_gate2(
.x(equal),
.z(not_equal)
);

nor_gate nor_gate(
.x(alu_output[31]),
.y(equal),
.z(greater)
);

//* add controller
scp_controller scp_ctrl(
.opCode(instr[31:26]),
.eqzero(equal),
.not_eqzero(not_equal),
.greater(greater),
.func(imm16[5:0]),
.ALUctrl(alu_ctrl),
.RegDst(reg_dst),
.RegWr(reg_wr_en),
.Branch(branch),
.Jump(jump),
.ALUSrc(alu_src_ctrl),
.MemWr(data_cache_wr_en),
.MemtoReg(mem2reg_ctrl),
.ExtOp(ext_ctrl)
);

endmodule




