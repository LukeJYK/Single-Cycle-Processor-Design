`timescale 1ns/1ps
module scp_top_tb;
reg clk;
reg rstb;

parameter clk_period = 10;
parameter instr_file_name = "./data/unsigned_sum.dat";
parameter data_file_name = "./data/unsigned_sum.dat";

scp_top #(
	.instr_file_name(instr_file_name), 
	.data_file_name(instr_file_name)
	)
	scp_top(
	.clk(clk),
	.rstb(rstb)
	);

initial begin
clk = 1'b1;
forever begin
#(clk_period/2)
clk = ~clk;
end
end

initial begin
rstb = 1'b1;
#(clk_period/2)
rstb = 1'b0;
#(clk_period*2)
rstb = 1'b1;
#500
$finish;
end
/*
always @ (posedge clk) begin
$display ("PC=%0d, Instr=%h", scp_top.IF.current_pc, scp_top.instr);
//  for(index = 0; index < 32; index = index+1) begin
//    $write("REG[%0d]=%h; ", index, RF.mem[index]);
//    if (index == 31) $write("\n");
//  end
$display ("DCACHE[2]=%0d, DCACHE[3]=%0d, DCACHE[4]=%0d", D_CACHE.mem[2],D_CACHE.mem[3],D_CACHE.mem[4]);
$write("\n");
end
*/
integer status_log = 0;
initial begin:write_log_file
	status_log = $fopen("unsigned_sum_status_log.txt",w);
	fork
		begin:
			@(posedge clk);
			$fwrite(status_log,"PC=%h, Instr=%h \n",scp_top.IF.current_pc,scp_top.instr);
		end
	join
end

			

endmodule
