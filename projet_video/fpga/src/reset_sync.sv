`default_nettype none
module reset_sync(input wire clk,
		  input wire nrst,
		  output logic n_rst);

   parameter active_state = 0;
   
   logic [1:0] bd;

   assign n_rst = active_state? !bd[1]: bd[1];
   
   always @ (posedge clk or negedge nrst)
     if (!nrst) bd <= 0;
     else
       begin
	  bd[0] <= 1;
	  bd[1] <= bd[0];
	  // bd <= {bd[0],1'b1};
       end
   
endmodule
