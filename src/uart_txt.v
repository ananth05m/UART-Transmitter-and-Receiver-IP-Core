`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2026 19:12:56
// Design Name: 
// Module Name: uart_tx
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


module uart_tx (
    input clk_50M,
    input rst,
    input tx_en,
    input [7:0] data,
    output reg tx,
    output reg tx_done
);

parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;

reg [1:0] state = IDLE;
reg [8:0] clk_count = 0;
reg [2:0] bit_index = 0;

parameter CLKS_PER_BIT = 434;

always @(posedge clk_50M or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1;
        tx_done <= 0;
        clk_count <= 0;
        bit_index <= 0;
    end else begin
        case (state)

            IDLE: begin
                tx <= 1;
                tx_done <= 0;

                if (tx_en) begin
                    state <= START;
                end
            end

            START: begin
                tx <= 0;
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;
                    state <= DATA;
                end
            end

            DATA: begin
                tx <= data[bit_index];
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    clk_count <= 0;

                    if (bit_index < 7)
                        bit_index <= bit_index + 1;
                    else begin
                        bit_index <= 0;
                        state <= STOP;
                    end
                end
            end

            STOP: begin
                tx <= 1;
                if (clk_count < CLKS_PER_BIT-1) begin
                    clk_count <= clk_count + 1;
                end else begin
                    tx_done <= 1;
                    clk_count <= 0;
                    state <= IDLE;
                end
            end

        endcase
    end
end

endmodule