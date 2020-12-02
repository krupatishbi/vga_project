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
    
    //values to use for simulation
//    `define ACTIVE_Hend (63)
//    `define FRONT_PORCH_Hend (65)
//    `define SYNC_PULSE_Hend (75)
//    `define BACKPORCH_Hend (79)
    
//    `define ACTIVE_Vend (40)
//    `define FRONT_PORCH_Vend (43)
//    `define SYNC_PULSE_Vend (46)
//    `define BACKPORCH_Vend (52)

    `define ACTIVE_Hend (639)
    `define FRONT_PORCH_Hend (655)
    `define SYNC_PULSE_Hend (751)
    `define BACKPORCH_Hend (799)
    
    `define ACTIVE_Vend (479)
    `define FRONT_PORCH_Vend (489)
    `define SYNC_PULSE_Vend (491)
    `define BACKPORCH_Vend (520)
    
    horizontal_counter #(.BACKPORCH_Hend(`BACKPORCH_Hend)) vga_horiz(clk, reset, enable_V_counter, H_count_value);
    vertical_counter #(.BACKPORCH_Vend(`BACKPORCH_Vend)) vga_vert(clk, reset, enable_V_counter, V_count_value);
  
    
    //outputs
    assign VGA_HS = ~(H_count_value > `FRONT_PORCH_Hend && H_count_value <= `SYNC_PULSE_Hend) ? 1'b1:1'b0;
    assign VGA_VS = ~(V_count_value > `FRONT_PORCH_Vend && V_count_value <= `SYNC_PULSE_Vend) ? 1'b1:1'b0;
    
    
    //state machiine with one hot encoding
    reg [5:0] present_state;
    parameter idle = 6'b000001;
    parameter edge_a = 6'b000010;
    parameter edge_b = 6'b000100;
    parameter edge_c = 6'b001000;
    parameter done = 6'b010000;
    parameter transient = 6'b100000;
    //variables for BRAM block
    reg [18:0] write_addr;
    reg [18:0] read_addr;
    reg [7:0] d_in;
    wire [7:0] d_out;
    reg write_enable;
    //defining the traingle points
    reg [9:0] x0, x1, x2;
    reg [8:0] y0, y1, y2;
    reg [9:0] half_length;
    
    reg [9:0] mar_x; //write x
    reg [8:0] mar_y; //write y
    
     
    always @ (posedge clk)
    begin
        if(reset)
        begin
            //initializing 
            x0 <= 10'd20;
            y0 <= 9'd460;
            half_length <= 10'd300;
            x1 <= (x0 + (2*half_length)) - 1;
            y1 <= y0;
            x2 <= x0 + (half_length);
            y2 <= (y0 - (half_length)) + 1;
            d_in <= 8'b11111111;
            
            present_state <= idle;
            mar_x <= x0;
            mar_y <= y0;
            write_enable <= 0;
            read_addr <= 0;
            write_addr <= 0;
            VGA_R = 0;
            VGA_G = 0;
            VGA_B = 0;
        end
        else
        begin
            case(present_state)
                idle:
                    if(!reset)
                    begin
                        present_state <= edge_a;
                        mar_x <= x0;
                        mar_y <= y0;
                    end
                        
                edge_a:
                begin
                    write_enable <= 1;
                    mar_x <= mar_x + 1;
                    if(mar_x == (x1-1)) //x1 = (x0 + 2*halflength) - 1
                        present_state <= edge_b;
                end
                edge_b:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y - 1;
                    if(mar_x == (x2+1)) //x2 = x0 + halflength
                        present_state <= transient;
                    
                end
                transient:
                begin
                    mar_x <= mar_x - 1; //move left one space
                    present_state <= edge_c;
                end
                edge_c:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y + 1;
                    if(mar_x == (x0+1))
                    begin
                        present_state <= done;
                        
                    end
                end
                done:
                begin
                    x0 <= x0 + 2; //moves right 2
                    y0 <= y0 - 1; //moves up 1
                    mar_x <= x0 + 2;
                    mar_y <= y0 - 1;
                    d_in <= d_in + 1; //changes the color of each successive triangle
                    //setting new values for new points of the triangles
                    if (half_length > 5)
                    begin
                        half_length <= half_length - 2;
                        x1 <= x0 + (2*half_length);
                        y1 <= y0;
                        x2 <= x0 + (half_length);
                        y2 <= y0 - (half_length);
                        present_state <= idle;
                    end
                    else
                        write_enable <= 0;
                end
                default:
                    present_state <= idle;
            endcase
            
            read_addr <= {H_count_value[9:0], V_count_value[8:0]}; //addra
            write_addr <= {mar_x, mar_y}; //addrb
            
            VGA_R <= {d_out[5],{3{d_out[4]}}}; //concat so that color is never black, brighter
            VGA_G <= {d_out[3],{3{d_out[2]}}};
            VGA_B <= {d_out[1],{3{d_out[0]}}};
        
        end
    end
    
    blk_mem_gen_0 ram(clk, write_enable, write_addr, d_in, clk, read_addr, d_out);
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .locked(locked), .clk_in1(clk_in1));
    
endmodule
