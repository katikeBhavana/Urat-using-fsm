module uart_rx_fsm(
input clk,
input rst,
input rx,
input sample_tick,       // 16x baud tick
  output reg [7:0] data_out,  // prallel output
output reg done          // completely recevied busy=1     
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;

  reg [3:0] sample_count;   // 2^4=16
  reg [3:0] bit_index;      //==15
  reg [7:0] shift_reg;  // stored in shift register

reg rx_d;    // for storing prev rx value


// ----------------------
// RX Edge Detection
// ----------------------
always @(posedge clk or posedge rst)
begin
    if(rst)
        rx_d <= 1'b1;
    else
        rx_d <= rx;   // for storing prev rx value
end


// ----------------------
// UART RX FSM
// ----------------------
always @(posedge clk or posedge rst)
begin
if(rst)
begin
    state <= IDLE;
    sample_count <= 0;
    bit_index <= 0;
    shift_reg <= 0;
    done <= 0;
    data_out <= 0;
end

else
begin
done <= 0;

case(state)

IDLE:
begin
  
    // detect falling edge (start bit)
  
    if(rx_d == 1 && rx == 0)
    begin
        sample_count <= 0;
        state <= START;
    end
end


START:
begin
    if(sample_tick)
    begin
        sample_count <= sample_count + 1; // total 16 samples 325 cycles

        // sample in middle of start bit
      
        if(sample_count == 7)
        begin
            sample_count <= 0;
            bit_index <= 0;
            state <= DATA;
        end
    end
end


DATA:
begin
    if(sample_tick)
    begin
        sample_count <= sample_count + 1;

        if(sample_count == 15)
        begin
          shift_reg <= {rx, shift_reg[7:1]};  // shifting data
            sample_count <= 0;
            bit_index <= bit_index + 1;

          if(bit_index == 7) // for data completion 
                state <= STOP; // moves to stop state 
        end
    end
end


STOP:
begin
    if(sample_tick)
    begin
        sample_count <= sample_count + 1;

        if(sample_count == 15)
        begin
            data_out <= shift_reg;  // store dout
            done <= 1;
            state <= IDLE;
        end
    end
end

endcase
end
end

endmodule
