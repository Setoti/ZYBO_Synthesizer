`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/23 19:32:34
// Design Name: 
// Module Name: sim_sim_gen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_sim_gen;

localparam [63:0] STEP = 10416;
localparam [63:0] CLKNUM = 960000*4;

logic clk96M;
logic [15:0] dout;
logic [14:0] freq;
logic reset;

design_1_wrapper design_1_wrapper(
    .clk96M (clk96M),
    .dout (dout),
    .freq (freq),
    .reset (reset)
    );
    
always begin
    clk96M = 0; #(STEP/2);
    clk96M = 1; #(STEP/2);
end     

initial begin
    reset = 0;
    freq = 15'd440;
    #(STEP*600);
    reset = 1;
    #(STEP*20);
    reset = 0;
    #(STEP*CLKNUM);
    freq = 15'd600;
    #(STEP*CLKNUM);
    $stop;
end

endmodule