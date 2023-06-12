`timescale 1ns / 1ps

module main_funk(
    input clk_i,
    input rst_i,
    input [7:0] a_in,
    input [7:0] b_in,
    input start_i,
    output busy_o,
    output reg [23:0] answer
    );
     
    reg [7:0] a, b;
    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;
    reg state = 0;
    
    assign busy_o = state;
    reg [16:0] mul_a;
    reg [8:0] mul_b;
    reg mul_start;
    wire mul_busy;
    wire [23:0] mul_result;
    
    mul mul(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_bi(mul_a),
        .b_bi(mul_b),
        .start_i(mul_start),
        .busy_o(mul_busy),
        .y_bo(mul_result)
    );
    reg mul_works;
        
    reg cube_start;
    reg cube_ready;
    reg [23:0] cube_result;
    reg [1:0]cube_n;
      
    reg mul_a_b_start;
    reg mul_a_b_ready;
    reg [15:0] mul_a_b_result;   
    
    always @(posedge clk_i)
        if(rst_i) begin
            answer <= 0 ;
            state <= IDLE ;
            cube_start <= IDLE;
            mul_a_b_start <= IDLE;
            cube_ready <= 0;
            mul_a_b_ready<= 0;
            mul_works <= 0;
            cube_n <= 0;
        end else begin
            case (state)
                IDLE :
                    if (start_i) begin
                        state <= WORK;
                        a <= a_in ;
                        b <= b_in ;
                        cube_ready <= 0;  
                        mul_a_b_ready<= 0;
                        cube_n <= 0;
                    end
                WORK:
                    begin
                       if(cube_ready && mul_a_b_ready) begin
                             answer <= mul_a_b_result + cube_result;
                             state <= IDLE;
                       end else if(!mul_a_b_ready) begin
                            if(!mul_a_b_start && !mul_works) begin
                                mul_a_b_start <= WORK;
                                mul_works <= WORK;
                            end
                       end else if(!cube_ready) begin
                            if(!cube_start && !mul_works) begin
                                cube_n <= 0;
                                cube_start <= WORK;
                                mul_works <= WORK;
                            end
                       end
                    end
            endcase
    end
    
    // mul_a_b
    reg wait_1;
    always @(posedge clk_i)
        if(mul_a_b_start) begin
            if(!mul_busy && mul_works) begin
                mul_start <= 1;
                mul_a <= a;
                mul_b <= b;
                mul_a_b_start <= 0;
                wait_1 <= 1;
            end 
        end else if(!mul_busy && mul_works && !mul_a_b_ready) begin
                if(wait_1) begin
                    wait_1 <= 0;
                    mul_start <= 0;
                end else begin
                    mul_a_b_result <= mul_result;
                    mul_a_b_ready <= 1;
                    mul_works <= 0;
                end
        end
        
    // cube
    always @(posedge clk_i)
        if(cube_start) begin
            if(!mul_busy && mul_works && !cube_n) begin
                mul_start <= 1;
                mul_a <= a;
                mul_b <= a;
                cube_start <= 0;
                wait_1 <= 1;
                cube_n <= 1;
            end
            end else if(!mul_busy && mul_works && cube_n == 1) begin
                if(wait_1) begin 
                    wait_1 <= 0;
                    mul_start <= 0;
                end else begin
                    mul_start <= 1;
                    mul_a <= mul_result;
                    mul_b <= a;
                    wait_1 <= 1;
                    cube_n <= 2;
                end
            end else if(!mul_busy && mul_works && !cube_ready && cube_n == 2) begin
                 if(wait_1) begin
                    wait_1 <= 0;
                    mul_start <= 0;
                 end else begin
                    cube_result <= mul_result;
                    cube_ready <= 1;
                    mul_works <= 0;
                 end
            end
         
endmodule
