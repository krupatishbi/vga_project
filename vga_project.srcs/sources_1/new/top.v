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
    
    //code for sprite animation, basically just animates a square around the screen
//     reg signed [9:0] top; //y coord
//     reg signed [10:0] left; //x coord
//     reg [9:0] length;
//     reg [8:0] height;
//     reg [6:0] vx_mag; //x magnitude
//     reg [6:0] vy_mag; //y magnitude
//     reg signed [7:0] vx_dir; //actual x direction
//     reg signed [7:0] vy_dir; //actual y direction

//   always @ (posedge clk)
//     begin
//         if(reset)
//         begin
//             length <= 20;
//             height <= 20;
//             vx_mag <= 5;
//             vy_mag <= 4;
//             vx_dir <= -vx_mag; 
//             vy_dir <= vy_mag; 
//         end
//         else if (H_count_value == 0 && V_count_value == 0)
//         begin
//             //left edge bounce
//             if(left <= $signed(H_count_value)) 
//                 vx_dir <= vx_mag;
//             //right edge bounce
//             else if((left + length) >= `ACTIVE_Hend)
//                 vx_dir <= -vx_mag;
//             //top edge bounce
//             if(top <= $signed(V_count_value))
//                 vy_dir <= vy_mag;
//             //bottom edge bounce
//             else if((top + height) >= `ACTIVE_Vend)
//                 vy_dir <= -vy_mag;
            
//         end
//     end

//     always @ (posedge clk)
//     begin
//         if(reset)
//         begin
//             top <= 0;
//             left <= 0;
//         end
//         else
//         begin
//             if(H_count_value == 0 && V_count_value == 0)
//             begin
//                 top <= top + vy_dir;
//                 left <= left + vx_dir;
//             end
//         end
//     end
    
// always @ (*)
//     begin
        
//     //animating a square
//     //basically just a box
//     if(H_count_value <= `ACTIVE_Hend && V_count_value <= `ACTIVE_Vend)
//     begin
//         if(V_count_value >= top && V_count_value <= (top + height) && H_count_value >= left && H_count_value <= (left + length))
//         begin
//             VGA_R = 4'hf;
//             VGA_G = 4'hf;
//             VGA_B = 4'hf;
//         end
//         else
//         begin
//             VGA_R = 4'h0;
//             VGA_G = 4'h0;
//             VGA_B = 4'h0;
//         end
//     end
// end 

    
    reg [3:0] present_state;
    reg [3:0] next_state;
    parameter idle = 5'b00001;
    parameter edge_a = 5'b00010;
    parameter edge_b = 5'b00100;
    parameter edge_c = 5'b01000;
    parameter done = 5'b10000;
    reg [18:0] write_addr;
    reg [18:0] read_addr;
    reg [7:0] d_in;
    wire [7:0] d_out;
    reg write_enable;
    reg [9:0] x0, x1, x2;
    reg [8:0] y0, y1, y2;
    reg [9:0] half_length;
    reg [9:0] mar_x;
    reg [8:0] mar_y;
    
    //define every color so you can mix intensities
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
            x0 <= 10'd20;
            y0 <= 9'd460; //111001100
            half_length <= 10'd100;
            x1 <= x0 + (2*half_length);
            y1 <= y0;
            x2 <= x0 + (half_length);
            y2 <= y0 - (half_length);
            d_in <= 8'b11111111;
            
        end
    end
    
    always @ (posedge clk)
    begin
        if(reset)
        begin
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
                        write_enable <= 1;
                        mar_x <= x0;
                        mar_y <= y0;
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
                    x0 <= x0 + 4; //moves right 4
                    y0 <= y0 - 4; //moves up 4
                    if ( half_length > 20)
                    begin
                        half_length <= half_length - 8;
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
            
            VGA_R <= d_out[7:5];
            VGA_G <= d_out[4:2];
            VGA_B <= d_out[1:0];
        
        end
    end
    
    blk_mem_gen_0 ram(clk, write_enable, write_addr, d_in, clk, read_addr, d_out);
    clk_wiz_0 CLKWIZ0(.clk_out1(clk), .locked(locked), .clk_in1(clk_in1));
    
endmodule
