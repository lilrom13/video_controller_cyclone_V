module fpga(input  fpga_CLK,
	    input  fpga_CLK_AUX,
	    output fpga_LEDR0,
	    output fpga_LEDR1,
	    output fpga_LEDR3,
	    input  fpga_SW0,
	    input  fpga_SW1,
	    input  fpga_NRST,
	    output fpga_SEL_CLK_AUX);

   logic [25:0]    cpt;
   logic [26:0]    cpt2;
    
   assign fpga_SW0 = fpga_LEDR0;
   assign fpga_SEL_CLK_AUX = fpga_SW1;
   assign fpga_LEDR1 = cpt[25];
   assign fpga_LEDR2 = cpt2[26];
   assign fpage_LEDR3 = fpga_NRST;
     
   always @ (posedge fpga_CLK_AUX)
     if (!fpga_NRST)
       cpt <= 0;
     else
       cpt <= cpt + 1;

   always @ (posedge fpga_CLK)
     if (!fpga_NRST)
       cpt2 <= 0;
     else
       cpt2 <= cpt2 + 1;
   
endmodule // fpga
