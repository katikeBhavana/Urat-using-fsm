`include "uart_tx_fsm.sv"
`include "uart_rx_fsm.sv"

module baud_gen #(
parameter CLK_FREQ = 50000000,
parameter BAUD_RATE = 9600
)(
input clk,
input rst,
output reg baud_tick
);

localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

reg [15:0] baud_counter;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        baud_counter <= 0;
        baud_tick <= 0;
    end
    else
    begin
        if (baud_counter == BAUD_COUNT-1)
        begin
            baud_counter <= 0;
            baud_tick <= 1;
        end
        else
        begin
            baud_counter <= baud_counter + 1;
            baud_tick <= 0;
        end
    end
end

endmodule
