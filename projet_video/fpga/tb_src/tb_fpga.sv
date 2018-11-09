
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
   
   vga_if vga_if0() ;

   fpga  #(.HDISP(160), .VDISP(90)) dut (.*, .vga_ifm(vga_if0)) ;
   screen #(.mode(0),.X(160),.Y(90)) screen0(.vga_ifs(vga_if0)) ;
   
   always #10ns fpga_CLK = ! fpga_CLK;
   always #18.5ns fpga_CLK_AUX = fpga_SEL_CLK_AUX ? !fpga_CLK_AUX : fpga_CLK_AUX;

   initial
     begin
	// On fait un reset
	fpga_NRST = 0;
	fpga_SW1 = 1;
	repeat(30) @ (posedge fpga_CLK);
	fpga_NRST = 1;
	#10ms
	$stop();
     end   
endmodule // tb_fpg
