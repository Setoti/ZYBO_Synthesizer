`timescale 1ps / 1ps

module sim_para2serial;

localparam [63:0] STEP = 10416;
localparam [63:0] CLKNUM = 960000*4;

logic clk96M;
logic [14:0] freq;
logic reset;
logic bclk;
logic pbdat;
logic pblrc;

logic [1:0] cnt4;
logic [8:0] cnt500;

design_1_wrapper design_1_wrapper(
    .bclk(bclk),
    .clk96M (clk96M),
    .freq (freq),
    .pbdat (pbdat),
    .pblrc (pblrc),
    .reset (reset)
    );

// clk96M
always begin
    clk96M = 0; #(STEP/2);
    clk96M = 1; #(STEP/2);
end     

// cnt4
always_ff @(posedge clk96M) begin
    if(reset)
        cnt4 <= 2'd0;
    else
        cnt4 <= cnt4 + 2'd1;
end

// cnt500
always_ff @(posedge clk96M) begin
    if(reset)
        cnt500 <= 9'd0;
    else if(cnt4==2'd2)
        if(cnt500==9'd499)
            cnt500 <= 9'd0;
        else
            cnt500 <= cnt500 + 9'd1;
end

// pblrc
always_ff @(posedge clk96M) begin
    if(reset)
        pblrc <= 1'b0; 
    else if(cnt500==9'd499 | cnt500==9'd498)
        pblrc <= 1'b1;
    else
        pblrc <= 1'b0;
end

// bclk
always_ff @(posedge clk96M) begin
    if(reset)
        bclk <= 1'b0;
    else if(cnt4==2'd3)
        bclk <= ~bclk;
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
