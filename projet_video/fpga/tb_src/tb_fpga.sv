module tb_fpga();
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

   fpga  dut (.*);

   always #10ns fpga_CLK = ! fpga_CLK;
   always #18.5ns fpga_CLK_AUX = fpga_SEL_CLK_AUX ? !fpga_CLK_AUX : fpga_CLK_AUX;

   initial
     begin
	// On est en reset, le compteur sur clk_50 est remis a zero
	// l'autre compteur est "indéfini"
	repeat(100) @ (negedge fpga_CLK);
	// On démarre l'horloge 27Mhz
	fpga_SW1 = 1;
	// On sort du reset
	repeat(100) @(negedge fpga_CLK) ;
	fpga_NRST=1;
	repeat(1024) @(negedge fpga_CLK) ;
	fpga_SW1 = 0;
	repeat(1024) @(negedge fpga_CLK) ;
	fpga_SW0=1;
	repeat(100) @(negedge fpga_CLK);
	fpga_SW0=0;
	
	$stop();
     end
   
endmodule // tb_fpg
