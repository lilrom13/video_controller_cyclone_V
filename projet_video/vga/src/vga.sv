`default_nettype none
module vga(input wire clk,
	   input wire nrst,
	   vga_if.master vga_ifm,
	   wshb_if.master wshb_ifm);
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

   logic [15:0] response;
   logic [$clog2(HDISP * VDISP)-1:0] cpt_pixels;
   logic 			     full;
   logic 			     empty;
   logic [15:0]			     rdata;
   logic   			     read;   
   // La toute première lecture ne pourra pas avoir lieu tant que
   // la FIFO n'aura pas été FULL au moins une fois.
   bit 				     at_least_one;
   
   fifo_async #(.DEPTH_WIDTH(8)) fifo(
		   .rst(rst),
		   .rclk(vga_clk),
		   .read(read), 
		   .rdata(rdata),
		   .rempty(empty),
		   .wclk(wshb_ifm.clk),
		   .wdata(response),
		   .write(wshb_ifm.ack),
		   .wfull(full)
		   );
   
   assign at_least_one	= full | at_least_one;
   assign read		= at_least_one && tmp_vga_blank;
   assign response	= wshb_ifm.dat_sm;
   assign wshb_ifm.cyc	= 1;
   assign wshb_ifm.sel	= 2'b11;
   assign wshb_ifm.stb	= !full;
   assign wshb_ifm.we	= '0;
   assign wshb_ifm.cti	= '0;
   assign wshb_ifm.bte	= '0;

   always_comb
     begin	
	vga_ifm.VGA_R = rdata[15:11]<<3;
	vga_ifm.VGA_G = rdata[10:5]<<2;
	vga_ifm.VGA_B = rdata[4:0]<<3;
     end // always_ff @

   // Lecture dans la SDRAM
   always_ff @ (posedge wshb_ifm.clk)
     begin
	if (rst)
	  begin
	     wshb_ifm.adr <= '0;
	     cpt_pixels <= '0;
	  end
	// Si on reçoit un signal ACK alors la donnée est accessible
	if (wshb_ifm.ack == 1)
	  begin
	     $display("resonse = %h", response);
	     // On fait avancer l'adresse pour lire le prochain pixel.
	     wshb_ifm.adr <= wshb_ifm.adr + 'h2;
	     cpt_pixels <= cpt_pixels + 1;
	     
	     // Nous avons lu tous les pixels de l'image. Retour a début.
	     if (cpt_pixels == (HDISP * VDISP) -1)
	       begin
		  $display("1 frame has been read. Total pixel counted = %d", cpt_pixels + 1);
		  wshb_ifm.adr <= '0;
		  cpt_pixels <= '0;
	       end
	  end
     end
endmodule
