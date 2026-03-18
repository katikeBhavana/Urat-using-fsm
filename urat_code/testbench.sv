`timescale 1ns/1ps

module uart_tb;

reg clk;
reg rst;
reg start;
reg [7:0] data;

wire baud_tick;
wire sample_tick;
wire tx;
wire busy;
wire [7:0] data_out;
wire done;


// ----------------------
// 50 MHz Clock
// ----------------------
always #10 clk = ~clk;


// ----------------------
// Baud Generator (TX)
// ----------------------
baud_gen #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(9600)
) baud_tx (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);


// ----------------------
// Oversampling Generator (16x)
// ----------------------
baud_gen #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(9600*16)
) baud_rx (
    .clk(clk),
    .rst(rst),
    .baud_tick(sample_tick)
);


// ----------------------
// UART TX
// ----------------------
uart_tx_fsm tx_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .baud_tick(baud_tick),
    .data(data),
    .tx(tx),
    .busy(busy)
);


// ----------------------
// UART RX
// ----------------------
uart_rx_fsm rx_inst (
    .clk(clk),
    .rst(rst),
    .rx(tx),              // loopback
    .sample_tick(sample_tick),
    .data_out(data_out),
    .done(done)
);


// ----------------------
// Waveform Dump
// ----------------------
initial begin
    $dumpfile("uart_wave.vcd");
    $dumpvars(0, uart_tb);
end


// ----------------------
// Monitor
// ----------------------
always @(posedge done)
begin
    $display("Time=%0t | Sent=%b | Received=%b",
              $time, data, data_out);
end


// ----------------------
// Stimulus
// ----------------------
initial
begin
    clk = 0;
    rst = 1;
    start = 0;
    data = 8'b00000000;

    #100;
    rst = 0;

    #100;

    // Send first byte
    data = 8'b10101010;
    start = 1;
    #20;
    start = 0;

    wait(done);

    #100000;

    // Send second byte
    data = 8'b11001100;
    start = 1;
    #20;
    start = 0;

    wait(done);

    #100000;

    $finish;
end

endmodule
