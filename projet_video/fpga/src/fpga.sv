`default_nettype none
module fpga(input wire 	 fpga_CLK,
	    input wire 	 fpga_CLK_AUX,
	    output logic fpga_LEDR0,
	    output logic fpga_LEDR1,
	    output logic fpga_LEDR2,
	    output logic fpga_LEDR3,
	    input wire 	 fpga_SW0,
	    input wire 	 fpga_SW1,
	    input wire 	 fpga_NRST,
	    output logic fpga_SEL_CLK_AUX,
	    vga_if.master vga_ifm
	    );

   parameter HDISP=640;
   parameter VDISP=480;

`ifdef SIMULATION
   localparam hcmpt=5;
`else
   localparam hcmpt=25;
`endif
   
   logic [hcmpt-1:0] 	 cpt;
   logic [hcmpt:0] 	 cpt2;
   
   assign fpga_LEDR0		= fpga_SW0;
   assign fpga_LEDR1		= cpt[hcmpt-1];
   assign fpga_LEDR2		= cpt2[hcmpt];
   assign fpga_LEDR3		= fpga_NRST;
   assign fpga_SEL_CLK_AUX	= fpga_SW1;

   vga #(.HDISP(HDISP), .VDISP(VDISP)) vga_ (
	     .clk(fpga_CLK_AUX),
	     .nrst(fpga_NRST),
	     .vga_ifm(vga_ifm)
	     );

   wire 		 nrst_50M;

   wire 		 nrst_27M;

   reset_sync reset_sync_50M (
			            .clk(fpga_CLK),
			            .nrst(fpga_NRST),
			            .n_rst(nrst_50M)
			      );

      reset_sync reset_sync_27M (
				       .clk(fpga_CLK_AUX),
				       .nrst(fpga_NRST),
				       .n_rst(nrst_27M)
				 );

      always @ (posedge fpga_CLK_AUX)
	     if (!nrst_27M)
	       cpt <= 0;

             else
	       cpt <= cpt + 1;

      always @ (posedge fpga_CLK)
	     if (!nrst_50M)
	       cpt2 <= 0;

             else
	       cpt2 <= cpt2 + 1;
endmodule // fpga
