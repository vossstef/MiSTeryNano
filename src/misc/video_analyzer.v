//
// video_analyzer.v
//
// try to derive video parameters from hs/vs/de
//

module video_analyzer 
(
 // system interface
 input 	    clk,
 input 	    hs,
 input 	    vs,
 input 	    de,

 output reg pal,
 output reg vreset
);
   

// generate a reset signal in the upper left corner of active video used
// to synchonize the HDMI video generation to the Atari ST
reg vsD, hsD;
reg [12:0] hcnt;    // signal ranges 0..2047
reg [12:0] hcntL;
reg [9:0] vcnt;    // signal ranges 0..313
reg [9:0] vcntL;
reg changed;

always @(posedge clk) begin
    // ---- hsync processing -----
    hsD <= hs;

    // begin of hsync, falling edge
    if(!hs && hsD) begin
        // check if line length has changed during last cycle
        hcntL <= hcnt;
        if(hcntL != hcnt)
            changed <= 1'b1;

        hcnt <= 0;
    end else
        hcnt <= hcnt + 13'd1;

    if(!hs && hsD) begin
       // ---- vsync processing -----
       vsD <= vs;
       // begin of vsync, falling edge
       if(!vs && vsD) begin
          // check if image height has changed during last cycle
          vcntL <= vcnt;
          if(vcntL != vcnt)
             changed <= 1'b1;

          vcnt <= 0;
	  
	  // check for PAL/NTSC values
	  if(vcnt == 10'd312 && hcntL == 13'd2047) pal <= 1'b1;	     
	  if(vcnt == 10'd262 && hcntL == 13'd2031) pal <= 1'b0;
	  
       end else
         vcnt <= vcnt + 10'd1;
    end
       
   vreset <= 1'b0;
   // account for back porches
   if( (hcnt == 152 && vcnt == 28 && changed &&  pal) ||
       (hcnt == 152 && vcnt == 18 && changed && !pal) ) begin
      vreset <= 1'b1;
      changed <= 1'b0;
   end
end


endmodule