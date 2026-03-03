module uart_tx_fsm(
input clk,
input rst,
input start,
input baud_tick,
input [7:0] data,
output reg tx,
output reg busy
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [3:0] bit_index;
reg [7:0] data_reg;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= IDLE;
        tx <= 1'b1;
        busy <= 0;
        bit_index <= 0;
    end
    else begin
        case (state)

        IDLE: begin
            tx <= 1'b1;
            busy <= 0;
            if (start) begin
                data_reg <= data;
                busy <= 1;
                state <= START;
            end
        end

        START: begin
            tx <= 0;
            if (baud_tick) begin
                bit_index <= 0;
                state <= DATA;
            end
        end

        DATA: begin
            tx <= data_reg[bit_index];
            if (baud_tick) begin
                bit_index <= bit_index + 1;
                if (bit_index == 7)
                    state <= STOP;
            end
        end

        STOP: begin
            tx <= 1;
            if (baud_tick) begin
                state <= IDLE;
                busy <= 0;
            end
        end

        endcase
    end
end

endmodule
