module uart_tx_fsm(
input clk,
input rst,
input start,             // start =1 user defined
input baud_tick,
input [7:0] data,
output reg tx,           // serial data
output reg busy          // data running =1
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [3:0] bit_index;
  reg [9:0] frame;   // 10-bit UART frame 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1'b1;       // active high vdd
        busy <= 0;         // not running 
        bit_index <= 0;
    end
    else begin
        case (state)

        IDLE: begin
            tx <= 1'b1;
            busy <= 0;
          if (start) begin                  // start =1
                frame <= {1'b1, data, 1'b0}; // STOP + DATA + START
                busy <= 1;
                state <= START;
            end
        end

        START: begin
            tx <= frame[0];   // start bit
          if (baud_tick) begin   // comes from baud gen
                bit_index <= 1;
                state <= DATA;
            end
        end

        DATA: begin
            tx <= frame[bit_index];
            if (baud_tick) begin
                bit_index <= bit_index + 1;
                if (bit_index == 8)
                    state <= STOP;
            end
        end

        STOP: begin
            tx <= frame[9];   // stop bit
            if (baud_tick) begin
              state <= IDLE;     // at a time 1 byte of dats send
                busy <= 0;
            end
        end

        endcase
    end
end

endmodule
