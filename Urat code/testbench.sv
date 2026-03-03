module uart_tb;

reg clk;
reg rst;
reg start;
reg [7:0] data;

wire baud_tick;
wire tx;
wire busy;
wire [7:0] data_out;
wire done;

// --------------------
// 50 MHz Clock
// --------------------
always #10 clk = ~clk;   // 20ns period

// --------------------
// Baud Generator
// --------------------
baud_gen #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(9600)
) baud_inst (
    .clk(clk),
    .rst(rst),
    .baud_tick(baud_tick)
);

// --------------------
// UART TX
// --------------------
uart_tx_fsm tx_inst (
    .clk(clk),
    .rst(rst),
    .start(start),
    .baud_tick(baud_tick),
    .data(data),
    .tx(tx),
    .busy(busy)
);

// --------------------
// UART RX (Loopback)
// --------------------
uart_rx_fsm rx_inst (
    .clk(clk),
    .rst(rst),
    .rx(tx),           // TX connected to RX
    .baud_tick(baud_tick),
    .data_out(data_out),
    .done(done)
);

// --------------------
// Waveform Dump
// --------------------
initial begin
    $dumpfile("uart_full.vcd");
    $dumpvars(0, uart_tb);
end

// --------------------
// Monitor
// --------------------
always @(posedge done) begin
    $display("Time=%0t | SENT=%b | RECEIVED=%b",
              $time, data, data_out);
end

// --------------------
// Test Stimulus
// --------------------
initial begin
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
