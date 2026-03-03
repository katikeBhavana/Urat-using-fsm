module uart_rx_fsm(
input clk,
input rst,
input rx,
input baud_tick,
output reg [7:0] data_out,
output reg done
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [3:0] bit_index;
reg [7:0] shift_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        bit_index <= 0;
        shift_reg <= 0;
        data_out <= 0;
        done <= 0;
    end
    else begin
        done <= 0;

        case (state)

        IDLE: begin
            if (rx == 0)   // start detected
                state <= START;
        end

        START: begin
            if (baud_tick) begin
                bit_index <= 0;
                state <= DATA;
            end
        end

        DATA: begin
            if (baud_tick) begin
                shift_reg <= {rx, shift_reg[7:1]};
                bit_index <= bit_index + 1;

                if (bit_index == 7)
                    state <= STOP;
            end
        end

        STOP: begin
            if (baud_tick) begin
                data_out <= shift_reg;
                done <= 1;
                state <= IDLE;
            end
        end

        endcase
    end
end

endmodule
