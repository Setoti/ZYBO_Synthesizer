module sin_gen(
    input logic clk96M,
    input logic reset,
    input logic [14:0] freq,
    output logic [15:0] dout
    );
    
    logic [20:0] cnt;      // Int 21bit
    logic [10:0] cnt2000;
    logic cnt2000_flag;
    logic [14:0] freq_ff;  // Int 15bit
    logic chg_freq_flag;
    logic [35:0] p_int;    // Int 36bit
    logic [39:0] p_int_ff; // Int 40bit 
    logic [50:0] p;        // Int 32bit  Decimal 19bit
    logic [10:0] p_ff;     // Int 11bit
    
    localparam tmp = 11'd1398; // Int 1bit, Decimal 10bit
    
    // cnt2000
    always_ff @(posedge clk96M) begin
        if(reset)
            cnt2000 <= 11'd0;
        else if(cnt2000 == 11'd1999)
            cnt2000 <= 11'd0;
        else
            cnt2000 <= cnt2000 + 11'd1;
    end
    
    // cnt2000_flga
    assign cnt2000_flag = (cnt2000 == 11'd1999);
    
    // freq_ff
    always_ff @(posedge clk96M) begin
        if(reset)
            freq_ff <= 15'd0;
        else
            freq_ff <= freq;
    end
            
    // chg_freq_flag
    assign chg_freq_flag = (freq != freq_ff);
    
    // cnt
    always_ff @(posedge clk96M) begin
        if(reset)
            cnt <= 21'd0;
        else if(chg_freq_flag)
            cnt <= 21'd0;
        else if(cnt2000_flag)
            cnt <= cnt + 21'd1; 
        else
            cnt <= cnt;
    end 
    
    // p_int
    assign p_int = cnt*freq;
    
    // p_int_ff
    always_ff @(posedge clk96M) begin
        if(reset)
            p_int_ff <= 40'd0;
        else
            p_int_ff <= {p_int, 4'd0};
    end
            
    // p
    assign p = p_int_ff * tmp;
    
    // p_ff
    always_ff @(posedge clk96M) begin
        if(reset)
            p_ff <= 11'd0;
        else
            p_ff <= p[30:19];
    end
    
    // BRAM
    WAVE_TBL WAVE_TBL(
        .addra (p_ff),
        .douta (dout),
        .clka (clk96M)
    );
endmodule
