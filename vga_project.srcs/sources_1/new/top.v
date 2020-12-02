`timescale 1ns / 1ps

//`define REFRESH_MEM_MODE (1)

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

    reg [18:0] lfsr;        // for Linear Feedback Shift Register
    
    always @ (posedge clk)
    begin
        pre_reset <= ~rst_;
        reset <= pre_reset;
    end
    
    // values to use for simulation
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
    
        //code for sprite animation, basically just animates a square around the screen
     reg [9:0] length;
     reg [8:0] height;
     reg [6:0] vx_mag; //x magnitude
     reg [6:0] vy_mag; //y magnitude

     reg signed [9:0]  sprite1_top; //y coord
     reg signed [10:0] sprite1_left; //x coord
     reg signed [9:0]  sprite2_top; //y coord
     reg signed [10:0] sprite2_left; //x coord
     reg signed [9:0]  sprite3_top; //y coord
     reg signed [10:0] sprite3_left; //x coord
     reg signed [9:0]  sprite4_top; //y coord
     reg signed [10:0] sprite4_left; //x coord
     reg signed [9:0]  sprite5_top; //y coord
     reg signed [10:0] sprite5_left; //x coord
     reg signed [9:0]  sprite6_top; //y coord
     reg signed [10:0] sprite6_left; //x coord
     reg signed [7:0] sprite1_vx_dir; //actual x direction
     reg signed [7:0] sprite1_vy_dir; //actual y direction
     reg signed [7:0] sprite2_vx_dir; //actual x direction
     reg signed [7:0] sprite2_vy_dir; //actual y direction
     reg signed [7:0] sprite3_vx_dir; //actual x direction
     reg signed [7:0] sprite3_vy_dir; //actual y direction
     reg signed [7:0] sprite4_vx_dir; //actual x direction
     reg signed [7:0] sprite4_vy_dir; //actual y direction
     reg signed [7:0] sprite5_vx_dir; //actual x direction
     reg signed [7:0] sprite5_vy_dir; //actual y direction
     reg signed [7:0] sprite6_vx_dir; //actual x direction
     reg signed [7:0] sprite6_vy_dir; //actual y direction

     reg [5:0] color;

`ifndef REFRESH_MEM_MODE

   // Sprite animation mode
   always @ (posedge clk)
     begin
         if(reset)
         begin
             length <= 40;
             height <= 40;
             vx_mag <= 7;
             vy_mag <= 5;
             sprite1_vx_dir <= -vx_mag; 
             sprite1_vy_dir <= vy_mag; 
             sprite2_vx_dir <= -vx_mag; 
             sprite2_vy_dir <= vy_mag; 
             sprite3_vx_dir <= -vx_mag; 
             sprite3_vy_dir <= vy_mag; 
             sprite4_vx_dir <= -vx_mag; 
             sprite4_vy_dir <= vy_mag; 
             sprite5_vx_dir <= -vx_mag; 
             sprite5_vy_dir <= vy_mag; 
             sprite6_vx_dir <= -vx_mag; 
             sprite6_vy_dir <= vy_mag; 
         end
         else if (H_count_value == 0 && V_count_value == 0)
         begin
             if(sprite1_left <= $signed(11'h0)) 
                 sprite1_vx_dir <= lfsr[2:0]+1;
             else if((sprite1_left + length) >= `ACTIVE_Hend)
                 sprite1_vx_dir <= -lfsr[2:0]-1;
             if(sprite1_top <= $signed(10'h0))
                 sprite1_vy_dir <= lfsr[2:0]+1;
             else if((sprite1_top + height) >= `ACTIVE_Vend)
                 sprite1_vy_dir <= -lfsr[2:0]-1;

             if(sprite2_left <= $signed(11'h0)) 
                 sprite2_vx_dir <= lfsr[5:3]+1;
             else if((sprite2_left + length) >= `ACTIVE_Hend)
                 sprite2_vx_dir <= -lfsr[5:3]-1;
             if(sprite2_top <= $signed(10'h0))
                 sprite2_vy_dir <= lfsr[5:3]+1;
             else if((sprite2_top + height) >= `ACTIVE_Vend)
                 sprite2_vy_dir <= -lfsr[5:3]-1;

             if(sprite3_left <= $signed(11'h0)) 
                 sprite3_vx_dir <= lfsr[8:6]+1;
             else if((sprite3_left + length) >= `ACTIVE_Hend)
                 sprite3_vx_dir <= -lfsr[8:6]-1;
             if(sprite3_top <= $signed(10'h0))
                 sprite3_vy_dir <= lfsr[8:6]+1;
             else if((sprite3_top + height) >= `ACTIVE_Vend)
                 sprite3_vy_dir <= -lfsr[8:6]-1;

             if(sprite4_left <= $signed(11'h0)) 
                 sprite4_vx_dir <= lfsr[2:0]+1;
             else if((sprite4_left + length) >= `ACTIVE_Hend)
                 sprite4_vx_dir <= -lfsr[2:0]-1;
             if(sprite4_top <= $signed(10'h0))
                 sprite4_vy_dir <= lfsr[2:0]+1;
             else if((sprite4_top + height) >= `ACTIVE_Vend)
                 sprite4_vy_dir <= -lfsr[2:0]-1;

             if(sprite5_left <= $signed(11'h0)) 
                 sprite5_vx_dir <= lfsr[5:3]+1;
             else if((sprite5_left + length) >= `ACTIVE_Hend)
                 sprite5_vx_dir <= -lfsr[5:3]-1;
             if(sprite5_top <= $signed(10'h0))
                 sprite5_vy_dir <= lfsr[5:3]+1;
             else if((sprite5_top + height) >= `ACTIVE_Vend)
                 sprite5_vy_dir <= -lfsr[5:3]-1;

             if(sprite6_left <= $signed(11'h0)) 
                 sprite6_vx_dir <= lfsr[8:6]+1;
             else if((sprite6_left + length) >= `ACTIVE_Hend)
                 sprite6_vx_dir <= -lfsr[8:6]-1;
             if(sprite6_top <= $signed(10'h0))
                 sprite6_vy_dir <= lfsr[8:6]+1;
             else if((sprite6_top + height) >= `ACTIVE_Vend)
                 sprite6_vy_dir <= -lfsr[8:6]-1;

         end
     end

     always @ (posedge clk)
     begin
         if(reset)
         begin
             sprite1_top <= 0;
             sprite1_left <= 0;
             sprite2_top <= 100;
             sprite2_left <= 100;
             sprite3_top <= 200;
             sprite3_left <= 200;
             sprite4_top <= 50;
             sprite4_left <= 50;
             sprite5_top <= 150;
             sprite5_left <= 150;
             sprite6_top <= 250;
             sprite6_left <= 250;
         end
         else
         begin
             if(H_count_value == 0 && V_count_value == 0)
             begin
                 sprite1_top <= sprite1_top + sprite1_vy_dir;
                 sprite1_left <= sprite1_left + sprite1_vx_dir;
                 sprite2_top <= sprite2_top + sprite2_vy_dir;
                 sprite2_left <= sprite2_left + sprite2_vx_dir;
                 sprite3_top <= sprite3_top + sprite3_vy_dir;
                 sprite3_left <= sprite3_left + sprite3_vx_dir;
                 sprite4_top <= sprite4_top + sprite4_vy_dir;
                 sprite4_left <= sprite4_left + sprite4_vx_dir;
                 sprite5_top <= sprite5_top + sprite5_vy_dir;
                 sprite5_left <= sprite5_left + sprite5_vx_dir;
                 sprite6_top <= sprite6_top + sprite6_vy_dir;
                 sprite6_left <= sprite6_left + sprite6_vx_dir;
             end
         end
     end
 
 wire [3:0] sprite1_red;
 wire [3:0] sprite1_grn;
 wire [3:0] sprite1_blu;
 wire sprite1_vld;
 wire [3:0] sprite2_red;
 wire [3:0] sprite2_grn;
 wire [3:0] sprite2_blu;
 wire sprite2_vld;
 wire [3:0] sprite3_red;
 wire [3:0] sprite3_grn;
 wire [3:0] sprite3_blu;
 wire sprite3_vld;
 wire [3:0] sprite4_red;
 wire [3:0] sprite4_grn;
 wire [3:0] sprite4_blu;
 wire sprite4_vld;
 wire [3:0] sprite5_red;
 wire [3:0] sprite5_grn;
 wire [3:0] sprite5_blu;
 wire sprite5_vld;
 wire [3:0] sprite6_red;
 wire [3:0] sprite6_grn;
 wire [3:0] sprite6_blu;
 wire sprite6_vld;
 
 sprite sprite1(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite1_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite1_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite1_red  ),
    .GRN                   (sprite1_grn  ),
    .BLU                   (sprite1_blu  ),
    .VALID                 (sprite1_vld  ) );
 sprite sprite2(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite2_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite2_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite2_red  ),
    .GRN                   (sprite2_grn  ),
    .BLU                   (sprite2_blu  ),
    .VALID                 (sprite2_vld  ) );
 sprite sprite3(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite3_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite3_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite3_red  ),
    .GRN                   (sprite3_grn  ),
    .BLU                   (sprite3_blu  ),
    .VALID                 (sprite3_vld  ) );
 sprite sprite4(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite4_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite4_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite4_red  ),
    .GRN                   (sprite4_grn  ),
    .BLU                   (sprite4_blu  ),
    .VALID                 (sprite4_vld  ) );
 sprite sprite5(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite5_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite5_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite5_red  ),
    .GRN                   (sprite5_grn  ),
    .BLU                   (sprite5_blu  ),
    .VALID                 (sprite5_vld  ) );
 sprite sprite6(
    .CLK                   (clk          ),
    .RESET                 (reset        ),
    .SPRITE_ORIGIN_OFFSET_X(sprite6_left ),
    .SPRITE_ORIGIN_OFFSET_Y(sprite6_top  ),
    .VISIBLE               (1'b1         ),
    .RASTER_X              (H_count_value),
    .RASTER_Y              (V_count_value),
    .RED                   (sprite6_red  ),
    .GRN                   (sprite6_grn  ),
    .BLU                   (sprite6_blu  ),
    .VALID                 (sprite6_vld  ) );

 always @ (*)
    if (sprite6_vld)
    begin
        VGA_R = sprite6_red;
        VGA_G = sprite6_grn;
        VGA_B = sprite6_blu;
    end
    else if (sprite5_vld)
    begin
        VGA_R = sprite5_red;
        VGA_G = sprite5_grn;
        VGA_B = sprite5_blu;
    end
    else if (sprite4_vld)
    begin
        VGA_R = sprite4_red;
        VGA_G = sprite4_grn;
        VGA_B = sprite4_blu;
    end
    else if (sprite3_vld)
    begin
        VGA_R = sprite3_red;
        VGA_G = sprite3_grn;
        VGA_B = sprite3_blu;
    end
    else if (sprite2_vld)
    begin
        VGA_R = sprite2_red;
        VGA_G = sprite2_grn;
        VGA_B = sprite2_blu;
    end
    else if (sprite1_vld)
    begin
        VGA_R = sprite1_red;
        VGA_G = sprite1_grn;
        VGA_B = sprite1_blu;
    end
    else
    begin
        VGA_R = 0;
        VGA_G = 0;
        VGA_B = 0;
    end
// always @ (*)
//     begin
        
//     //animating a square
//     //basically just a box
//     if(H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend)
//     begin
//         if(V_count_value >= top && V_count_value <= (top + height) && H_count_value >= left && H_count_value <= (left + length))
//         begin
//             VGA_R = {color[5:4],2'b11};
//             VGA_G = {color[3:2],2'b11};
//             VGA_B = {color[1:0],2'b11};
//         end
//         else
//         begin
//             VGA_R = 4'h0;
//             VGA_G = 4'h0;
//             VGA_B = 4'h0;
//         end
//     end
// end 

`else
    
    // Refresh memory mode
    reg [4:0] present_state;
    reg [4:0] next_state;
    parameter idle = 5'b00001;
    parameter edge_a = 5'b00010;
    parameter edge_b = 5'b00100;
    parameter edge_c = 5'b01000;
    parameter done = 5'b10000;
    wire [18:0] write_addr;
    wire [18:0] read_addr;
    reg [7:0] d_in;
    wire [7:0] d_out;
    reg write_enable;
    reg [9:0] x0, x1, x2;
    reg [8:0] y0, y1, y2;
    reg [9:0] half_length;
    reg [9:0] mar_x;
    reg [8:0] mar_y;
    
    //define every color so you can mix intensities

    assign read_addr = {H_count_value[9:0], V_count_value[8:0]}; //addra
    assign write_addr = {mar_x, mar_y}; //addrb

    always @ (posedge clk)
    begin
        if(reset)
        begin
            
        end
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            present_state   <= idle;
            
            mar_x           <= x0;
            mar_y           <= y0;
            
            write_enable    <= 0;
            
            VGA_R <= 0;
            VGA_G <= 0;
            VGA_B <= 0;

            x0 <= 10'd20;
            y0 <= 9'd460; //111001100

            half_length <= 10'd300;

            x1 <= x0 + (2*half_length);
            y1 <= y0;
            x2 <= x0 + (half_length);
            y2 <= y0 - (half_length);

            d_in <= 8'b11111111;
        end
        else
        begin
            case(present_state)
                idle:
                begin
                    present_state   <= edge_a;
                    write_enable    <= 1;

                    mar_x <= x0;
                    mar_y <= y0;
                    
                    VGA_R <= 0;
                    VGA_G <= 0;
                    VGA_B <= 0;
        
                    x1 <= x0 + (2*half_length);
                    y1 <= y0;
                    x2 <= x0 + (half_length);
                    y2 <= y0 - (half_length);
                end
                    
                edge_a:
                begin
                    mar_x <= mar_x + 1;
                    if(mar_x == (x1-1))
                        present_state <= edge_b;
                end
                edge_b:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y - 1;
                    if(mar_x == (x2+1))
                        present_state <= edge_c;
                    
                end
                edge_c:
                begin
                    mar_x <= mar_x - 1;
                    mar_y <= mar_y + 1;
                    if(mar_x == (x0+1))
                        present_state <= done;
                end
                done:
                begin
                    x0 <= x0 + 2; //moves right 4
                    y0 <= y0 - 2; //moves up 4
                    d_in <= d_in - 1;
                    if ( half_length > 20)
                    begin
                        half_length <= half_length - 4;
                        present_state <= idle;
                    end
                    else
                        write_enable <= 0;
                end
                default:
                    present_state <= idle;
            endcase
            
            VGA_R <= {d_out[5:4],{2{d_out[4]}}};
            VGA_G <= {d_out[3:2],{2{d_out[2]}}};
            VGA_B <= {d_out[1:0],{2{d_out[0]}}};
        
        end
    end

`endif
    
    //blk_mem_gen_0 ram(clk, write_enable, write_addr, d_in, clk, read_addr, d_out);
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .resetn(1'b1), .locked(locked), .clk_in1(clk_in1));

    // A linear feedback shift register, LFSR, which produces a pseudo-random bit stream
    
    always @ (posedge clk)
    if (reset)
        lfsr <= 19'h7FFFF;                                            // Cannot initialize to all 0's!!
    else
    begin
        lfsr[0]     <= lfsr[18] ^ lfsr[17] ^ lfsr[16] ^ lfsr[13];     // fill in with XORs
        lfsr[18:1]  <= lfsr[17:0];                                    // shift left
    end
    
endmodule
