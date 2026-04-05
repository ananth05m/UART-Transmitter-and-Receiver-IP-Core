`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2026 19:14:28
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx (
    input clk_50M,
    input rst,
    input rx,
    output reg [7:0] rx_msg,
    output reg rx_complete
);

parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;

reg [1:0] state = IDLE;
reg [8:0] clk_count = 0;
reg [2:0] bit_index = 0;

parameter CLKS_PER_BIT = 434;

always @(posedge clk_50M or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
        rx_msg <= 0;
        rx_complete <= 0;
    end else begin
        case (state)

            IDLE: begin
                rx_complete <= 0;
                clk_count <= 0;
                bit_index <= 0;

                if (rx == 0) begin // start bit detected
                    state <= START;
                end
            end

            START: begin
                if (clk_count == (CLKS_PER_BIT/2)) begin
                    if (rx == 0) begin
                        clk_count <= 0;
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end else begin
                    clk_count <= clk_count + 1;
                end
            end

            DATA: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    rx_msg[bit_index] <= rx;

                    if (bit_index < 7) begin
                        bit_index <= bit_index + 1;
                    end else begin
                        bit_index <= 0;
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    rx_complete <= 1;
                    clk_count <= 0;
                    state <= IDLE;
                end
            end

        endcase
    end
end

endmodule
