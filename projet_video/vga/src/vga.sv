`default_nettype none
module vga(input wire clk,
	   input wire nrst,
	   vga_if.master vga_ifm);
   // dimension
   parameter	HDISP		= 640;
   parameter	VDISP		= 480;
   // horizontal
   localparam	HFP		= 16;
   localparam	HPULSE		= 96;
   localparam	HBP		= 48;
   // vertical
   localparam	VPULSE		= 2;   
   localparam	VBP		= 31;
   localparam	VFP		= 11;
   // pixels
   localparam	max_h_pixels	= HDISP + HFP + HPULSE + HBP;
   localparam	max_v_pixels	= VDISP + VFP + VPULSE + VBP;
   // wires
   wire		vga_clk;
   wire		locked;
   wire		rst;
   // compteurs
   logic [$clog2(max_h_pixels)-1:0] h_cpt;
   logic [$clog2(max_v_pixels)-1:0] v_cpt;
   // tmp signals
   logic tmp_vga_hs;
   logic tmp_vga_h_blank;
   logic tmp_vga_vs;
   logic tmp_vga_v_blank;
   logic tmp_vga_blank;
   
   // assign signal combinatorially
   assign tmp_vga_hs = (h_cpt < HDISP + HFP) || (h_cpt >= HDISP + HFP + HPULSE);
   assign tmp_vga_vs = (v_cpt < VDISP + VFP) || (v_cpt >= VDISP + VFP + VPULSE);
   assign tmp_vga_h_blank = h_cpt < HDISP;
   assign tmp_vga_v_blank = v_cpt < VDISP;
   assign tmp_vga_blank = tmp_vga_h_blank & tmp_vga_v_blank;
      
   vga_pll	pll (
		     .refclk(clk), 
		     .rst(!nrst), 
		     .outclk_0(vga_clk), 
		     .locked(locked)
		);
   reset_sync #(1) reset_sync_25_17M (
				      .clk(vga_clk), 
				      .nrst(nrst), 
				      .n_rst(rst)
				      );

   // horizontal cpt
   always_ff @ (posedge vga_clk)
     begin
	if (rst) h_cpt <= '0;
	else
	  begin
	     h_cpt <= h_cpt + 1'b1;
	     if (h_cpt == max_h_pixels-1)
	       h_cpt <= '0;
	  end
     end

   // vertical cpt
   always_ff @ (posedge vga_clk)
     begin
	if (rst) v_cpt <= '0;
	else if (h_cpt == max_h_pixels-1)
	  begin
	     v_cpt <= v_cpt + 1'b1;
	     if (v_cpt == max_v_pixels-1)
	       v_cpt <= '0;
	  end
     end

   assign vga_ifm.VGA_CLK = !vga_clk;
   assign vga_ifm.VGA_SYNC = 0;
     
   always @ (posedge vga_clk)
     begin
	vga_ifm.VGA_HS <= tmp_vga_hs;
	vga_ifm.VGA_VS <= tmp_vga_vs;
	vga_ifm.VGA_BLANK <= tmp_vga_blank;
     end // always @ (posedge vga_clk)

   always_ff @ (posedge vga_clk)
     begin
	vga_ifm.VGA_R <= 0;
	vga_ifm.VGA_G <= 0;
	vga_ifm.VGA_B <= 0;
	if (h_cpt[3:0] == 0 || v_cpt[3:0] == 0)
	  begin
	     vga_ifm.VGA_R <= 255;		  
	     vga_ifm.VGA_G <= 255;
	     vga_ifm.VGA_B <= 255;
	  end
     end
endmodule
