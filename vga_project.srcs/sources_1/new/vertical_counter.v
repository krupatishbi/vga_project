`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////


module vertical_counter #(parameter BACKPORCH_Vend = 524)
    (
    input clk,
    input reset,
    input enable_V_counter,
    output reg [15:0] V_count_value
    );

    always @ (posedge clk)
    begin
        if(reset == 1)
        begin
            V_count_value <= 0;
        end
    else
    begin
        if(enable_V_counter == 1'b1)
        begin
            if(V_count_value < BACKPORCH_Vend)
                V_count_value <= V_count_value + 1; //incrementing V counter
            else
                V_count_value <= 0; //reset horizontal counter
        end
    end
    end
    
endmodule
