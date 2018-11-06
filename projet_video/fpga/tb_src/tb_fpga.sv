module tb_fpg();
   logic fpga_CLK = 0;
   logic fpga_CLK_AUX = 0;
   wire  fpga_LEDR0;
   wire  fpga_LEDR1;
   wire  fpga_LEDR2;
   wire  fpga_LEDR3;
   logic fpga_SW0 = 0;
   logic fpga_SW1 = 0;
   logic fpga_NRST = 0;
   wire  fpga_SEL_CLK_AUX;

   fpgap  dut (.*);

   always #10ns fpga_CLK = ! fpga_CLK;
   always #18.5ns fpga_CLK_AUX = fpga_SEL_CLK_AUX ? !fpga_CLK_AUX : fpga_CLK_AUX;

   initial
     begin
	fpga_SW0 = 1;
	repeat (8) @ (negedge clk);
	fpga_NRSET = 0;
	fpga_SW0 = 0;
	fpga_SW1 = 1;
	repeat (8) @ (negedge clk);
	fpga_NRSET = 0;
	fpga_SW0 = 0;
	fpga_SW1 = 0;
	stop();
     end
   
endmodule // tb_fpg
