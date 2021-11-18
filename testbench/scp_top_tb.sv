`timescale 1ns/1ps
module scp_top_tb;
reg clk;
reg rstb;

parameter clk_period = 10;
parameter instr_file_name = "./data/sort_corrected_branch.dat";
parameter data_file_name = "./data/sort_corrected_branch.dat";

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
#5000
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
integer i = 0;
integer j = 0;
integer k = 0;
integer c = 0;
initial begin:write_log_file
	status_log = $fopen("sort_corrected_branch_status_log.txt","w");
	forever begin
		fork
			begin
				@(negedge clk);
				$fwrite(status_log,"PC=%h, Instr=%h \n",scp_top.instr_addr,scp_top.instr);
				for(k = 32'h10000000; k<32'h10000032;k=k+4)begin
					for(c=0; c<50; c++)begin
						if(scp_top.data_cache.mem[c][0] == k)begin
							$fwrite(status_log,"MEM[%h] = %h \n",k,scp_top.data_cache.mem[c][1]);
						end
					end
				end
				for (i = 0; i < 4; i++)begin
					for (j = 0 ; j < 8 ; j ++)begin
						$fwrite(status_log,"REG[%2d] = %h  ",8*i+j,scp_top.RF.mem[8*i+j]);
					end
					$fwrite(status_log,"\n");
				end
				$fwrite(status_log,"\n");
			end
		join
	end
end

			

endmodule
