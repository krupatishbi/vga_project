`timescale 1ns / 1ps

`define SPRITE_WID (40)
`define SPRITE_HGT (40)

module sprite(
    input CLK,
    input RESET,
    
    input [9:0] SPRITE_ORIGIN_OFFSET_X,
    input [8:0] SPRITE_ORIGIN_OFFSET_Y,
    input VISIBLE,
    input [9:0] RASTER_X,
    input [8:0] RASTER_Y,
    
    output [3:0] RED,
    output [3:0] GRN,
    output [3:0] BLU,
    output VALID
    );
    
    wire [9:0] sprite_local_x;      // local position of raster
    wire [8:0] sprite_local_y;      // within this sprite
    wire in_sprite_rect;            // tells whether the raster is in the sprite
    
    assign sprite_local_x = RASTER_X - SPRITE_ORIGIN_OFFSET_X;
    assign sprite_local_y = RASTER_Y - SPRITE_ORIGIN_OFFSET_Y;

    assign in_sprite_rect = (RASTER_X >= SPRITE_ORIGIN_OFFSET_X) &&
                            (RASTER_X < SPRITE_ORIGIN_OFFSET_X + `SPRITE_WID) &&
                            (RASTER_Y >= SPRITE_ORIGIN_OFFSET_Y) &&
                            (RASTER_Y < SPRITE_ORIGIN_OFFSET_Y + `SPRITE_HGT);
                            
    assign VALID = in_sprite_rect & VISIBLE;

    wire [7:0] red_t;    
    wire [7:0] grn_t;    
    wire [7:0] blu_t;    
lp_40x40_rom lp_40x40_rom(
    .x_idx(sprite_local_x[5:0]),
    .y_idx(sprite_local_y[5:0]),
    .RED  (red_t  ),
    .GRN  (grn_t  ),
    .BLU  (blu_t  ));

assign RED = red_t[7:4];    
assign GRN = grn_t[7:4];    
assign BLU = blu_t[7:4];    
endmodule
