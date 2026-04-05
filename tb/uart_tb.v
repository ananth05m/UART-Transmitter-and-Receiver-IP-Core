`timescale 1ns/1ps

module uart_tb;

    reg clk = 0;
    reg rst = 1;

    reg tx_en = 0;
    reg [7:0] data = 0;

    wire tx;
    wire tx_done;

    wire rx;
    wire [7:0] rx_msg;
    wire rx_complete;

    // 🔥 CONNECT TX → RX
    assign rx = tx;

    // 50 MHz clock
    always #10 clk = ~clk;

    // DUT
    uart_tx TX (
        .clk_50M(clk),
        .rst(rst),
        .tx_en(tx_en),
        .data(data),
        .tx(tx),
        .tx_done(tx_done)
    );

    uart_rx RX (
        .clk_50M(clk),
        .rst(rst),
        .rx(rx),
        .rx_msg(rx_msg),
        .rx_complete(rx_complete)
    );

    initial begin
        // RESET
        rst = 1;
        #100;
        rst = 0;

        // WAIT
        #200;

        // SEND VALUE
        data = 8'h88;
        $display("Sending = %h", data);

        // TRIGGER TX
        @(posedge clk);
        tx_en = 1;

        @(posedge clk);
        tx_en = 0;

        // WAIT FOR FULL TRANSMISSION
        #100000;

        // CHECK OUTPUT
        $display("Received = %h", rx_msg);

        if (rx_msg == data)
            $display("✅ SUCCESS");
        else
            $display("❌ FAIL");

        #10000;
        $finish;
    end

endmodule