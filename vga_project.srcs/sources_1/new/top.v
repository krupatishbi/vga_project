`timescale 1ns / 1ps


module top(
    input clk_in1,
    input rst_,
    output VGA_HS,
    output VGA_VS,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B);
    
    wire enable_V_counter;
    wire [15:0] H_count_value;
    wire [15:0] V_count_value;
    reg reset;
    reg pre_reset;
    wire clk;
    wire locked;
    
    always @ (posedge clk)
    begin
        pre_reset <= ~rst_;
        reset <= pre_reset;
    end
    
    horizontal_counter vga_horiz(clk, reset, enable_V_counter, H_count_value);
    vertical_counter vga_vert(clk, reset, enable_V_counter, V_count_value);
    
    `define ACTIVE_Hend (639)
    `define FRONT_PORCH_Hend (655)
    `define SYNC_PULSE_Hend (751)
    `define BACKPORCH_Hend (799)
    
    `define ACTIVE_Vend (479)
    `define FRONT_PORCH_Vend (489)
    `define SYNC_PULSE_Vend (491)
    `define BACKPORCH_Vend (520)
    
    //outputs
    assign VGA_HS = ~(H_count_value > `FRONT_PORCH_Hend && H_count_value <= `SYNC_PULSE_Hend) ? 1'b1:1'b0;
    assign VGA_VS = ~(V_count_value > `FRONT_PORCH_Vend && V_count_value <= `SYNC_PULSE_Vend) ? 1'b1:1'b0;
   
    reg [8:0] top; //y coord
    reg [9:0] left; //x coord
    reg [9:0] length;
    reg [8:0] height;
    reg [6:0] v_x; //x
    reg [6:0] v_y; //y
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            top <= 0;
            left <= 0;
            length <= 50;
            height <= 50;
            v_x <= 5;
            v_y <= 4;
        end
        else if (H_count_value == 0 && V_count_value == 0)
        begin
            top <= top + v_y;
            left <= left + v_x;
        end
    end
    
    always @ (*)
    begin
        //if-else statements assigning colors
        //order of colors: black, white, red, yellow, green, cyan, blue, magenta
//        if(H_count_value <=79)
//        begin
//            VGA_R = 4'h0;
//            VGA_G = 4'h0;
//            VGA_B = 4'h0;
//        end        
//        else if(H_count_value <=159)
//        begin
//            VGA_R = 4'hF;
//            VGA_G = 4'hF;
//            VGA_B = 4'hF;
//        end
//        else if(H_count_value <=239)
//        begin
//            VGA_R = 4'hF;
//            VGA_G = 4'h0;
//            VGA_B = 4'h0;
//        end
//        else if(H_count_value <=319)
//        begin
//            VGA_R = 4'hF;
//            VGA_G = 4'hF;
//            VGA_B = 4'h0;
//        end
//        else if(H_count_value <=399)
//        begin
//            VGA_R = 4'h0;
//            VGA_G = 4'hF;
//            VGA_B = 4'h0;
//        end
//        else if(H_count_value <=479)
//        begin
//            VGA_R = 4'h0;
//            VGA_G = 4'hF;
//            VGA_B = 4'hF;
//        end
//        else if(H_count_value <= 559)
//        begin
//            VGA_R = 4'h0;
//            VGA_G = 4'h0;
//            VGA_B = 4'hF;
//        end
//        else if(H_count_value <=639)
//        begin
//            VGA_R = 4'hF;
//            VGA_G = 4'h0;
//            VGA_B = 4'hF;
//        end
//        else
//        begin
//            VGA_R = 4'h0;
//            VGA_G = 4'h0;
//            VGA_B = 4'h0;
//        end
//        VGA_R = (H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend) ? 4'hF:4'h0;
//        VGA_G = (H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend) ? 4'hF:4'h0;
//        VGA_B = (H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend) ? 4'hF:4'h0;
    
    //animating a square
    //basically just a box
    if(H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend)
    begin
        if(V_count_value >= top && V_count_value <= (top + height) && H_count_value >= left && H_count_value <= (left + length))
        begin
            VGA_R = 4'hf;
            VGA_G = 4'hf;
            VGA_B = 4'hf;
        end
        else
        begin
            VGA_R = 4'h0;
            VGA_G = 4'h0;
            VGA_B = 4'h0;
        end
    end
end 
    
    
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .resetn(rst_), .locked(locked), .clk_in1(clk_in1));
endmodule
