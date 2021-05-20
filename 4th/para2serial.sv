module para2serial(
    input logic clk96M,
    input logic reset,
    input logic bclk,
    input logic pblrc,
    input logic [15:0] din_L,
    input logic [15:0] din_R,
    output logic pbdat
    );
    
    logic [1:0] cnt4;
    logic load;
    logic shift;
    logic [31:0] sreg_ff;
    
    // cnt4
    always_ff @(posedge clk96M) begin
        if(reset)
            cnt4 <= 2'd0;
        else if(bclk)
            cnt4 <= cnt4 + 2'd1;
        else
            cnt4 <= 2'd0;
    end
                  
    // shift register
    assign shift = (cnt4==2'd3);
    assign load = shift & pblrc;
    
    always_ff @ (posedge clk96M) begin
        if(reset)
            sreg_ff <= 32'd0;
        else if(load)
            sreg_ff <= {din_L, din_R};
        else if(shift)
            sreg_ff <= {sreg_ff[31:0], 1'b0};
    end

assign pbdat = sreg_ff[31];      
    
    
endmodule