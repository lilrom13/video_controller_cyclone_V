`default_nettype none 
module fpga(input  wire fpga_CLK,
	    input  wire fpga_CLK_AUX,
	    output logic fpga_LEDR0,
	    output logic fpga_LEDR1,
	    output logic fpga_LEDR2,
	    output logic fpga_LEDR3,
	    input  wire fpga_SW0,
	    input  wire fpga_SW1,
	    input  wire fpga_NRST,
	    output logic fpga_SEL_CLK_AUX);

`ifdef SIMULATION
   localparam hcmpt=5;
`else
   localparam hcmpt=25;
`endif

   logic [hcmpt-1:0]    cpt;
   logic [hcmpt:0]    cpt2;
    
   assign fpga_LEDR0 = fpga_SW0;
   assign fpga_SEL_CLK_AUX = fpga_SW1;
   assign fpga_LEDR1 = cpt[hcmpt-1];
   assign fpga_LEDR2 = cpt2[hcmpt];
   assign fpga_LEDR3 = fpga_NRST;
     
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
