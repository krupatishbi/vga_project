`timescale 1ns / 1ps

module vga_tb;

reg clk = 0;
reg rst_; //active low
wire VGA_HS;
wire VGA_VS;
wire [3:0] VGA_R;
wire [3:0] VGA_G;
wire [3:0] VGA_B;

top UUT (clk, rst_, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);

// period is 40ns, so toggle every 20ns
always #5 clk = ~clk;

initial
    begin
        rst_ = 0;
        #100
        rst_ = 1;
    end 

endmodule
