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
   logic [1:0] tmp_vga_hs;
   logic [1:0] tmp_vga_h_blank;
   logic [1:0] tmp_vga_vs;
   logic [1:0] tmp_vga_v_blank;
   logic [1:0] tmp_vga_blank;

   // assign signal combinatorially
   assign tmp_vga_hs = (h_cpt > HDISP + HFP && h_cpt < HDISP + HFP + HBP) ? 0: 1;
   assign tmp_vga_vs = (h_cpt > VDISP + VFP && v_cpt < VDISP + VFP + VBP) ? 0: 1;
   assign tmp_vga_h_blank = (h_cpt) > HDISP ? 0: 1;
   assign tmp_vga_v_blank = (v_cpt) > VDISP ? 0: 1;
   assign tmp_vga_blank = tmp_vga_h_blank && tmp_vga_v_blank;
      
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

   always @ (posedge vga_clk)
     begin
	vga_ifm.VGA_SYNC = 0;
	vga_ifm.VGA_CLK = !vga_clk;
	if (rst)
	  begin
	     vga_ifm.VGA_HS <= '0;
	     vga_ifm.VGA_VS <= '0;
	     vga_ifm.VGA_BLANK <= '0;
	     vga_ifm.VGA_CLK <= 0;
	  end
	else
	  begin
	     vga_ifm.VGA_HS <= tmp_vga_hs;
	     vga_ifm.VGA_VS <= tmp_vga_hs;
	     vga_ifm.VGA_BLANK <= tmp_vga_blank;
	  end
     end // always @ (posedge vga_clk)

   // print white line every 16 pixels.
   always @ (posedge vga_clk)
     begin
	if (rst)
	  begin
	     vga_ifm.VGA_R = '0;
	     vga_ifm.VGA_G = '0;
	     vga_ifm.VGA_B = '0;
	  end
	else
	  begin
	     if (h_cpt[3:0] == 0)
	       begin
		  vga_ifm.VGA_R = 8'b1;		  
		  vga_ifm.VGA_G = 8'b1;
		  vga_ifm.VGA_B = 8'b1;
	       end
	     else
	       begin
		  vga_ifm.VGA_R = 8'b0;
		  vga_ifm.VGA_G = 8'b0;
		  vga_ifm.VGA_B = 8'b0;
	       end
	  end
     end
endmodule
