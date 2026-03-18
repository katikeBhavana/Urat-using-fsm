`include "uart_tx_fsm.sv"
`include "uart_rx_fsm.sv"
module baud_gen #(
    parameter CLK_FREQ  = 50000000,   // System clock frequency
    parameter BAUD_RATE = 9600        //  baud rate
)(
    input clk,
    input rst,
    output reg baud_tick                  // when 5208 reaches it is =1
);

localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

reg [15:0] counter;

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        counter   <= 0;
        baud_tick <= 0;
    end
    else
    begin
        if (counter == BAUD_COUNT-1)
        begin
            counter   <= 0;
          baud_tick <= 1;   // generate 1 clock pulse (5208)au
        end
        else
        begin
            counter   <= counter + 1;
            baud_tick <= 0;
        end
    end
end

endmodule
