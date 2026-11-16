`timescale 1ns/1ps
module traffic_controller ( output reg [2:0] light_ns,light_ew,output reg walk_ns,walk_ew,input wire clk, rst_n,ped_ns, ped_ew);
parameter ns_green_time = 32'd1000;
parameter ew_green_time = 32'd500;
parameter yellow_time   = 32'd300;
parameter red_time      = 32'd100;
parameter walk_time     = 32'd700;
parameter ns_green  = 3'b000;
parameter ns_yellow = 3'b001;
parameter all_red1  = 3'b010;
parameter ew_green  = 3'b011;
parameter ew_yellow = 3'b100;
parameter all_red2  = 3'b101;
reg [2:0] state, next_state;
reg [31:0] timer_count,current_timeout;
wire timer_done;
reg ped_ns_sync1, ped_ns_sync2;
reg ped_ew_sync1, ped_ew_sync2;
reg ped_ns_pressed,ped_ew_pressed;
reg clear_ped_ns,clear_ped_ew;
assign timer_done =(timer_count >= current_timeout - 1'b1);
always @(posedge clk) begin
    if (!rst_n)
          timer_count <= 32'd0;
    else if (timer_done)
          timer_count <= 32'd0;
    else
          timer_count <= timer_count + 1'b1;
end
always @(posedge clk) begin
    if (!rst_n) begin
       ped_ns_sync1 <= 1'b0;
       ped_ns_sync2 <= 1'b0;
       ped_ew_sync1 <= 1'b0;
       ped_ew_sync2 <= 1'b0;
       end
    else begin
            ped_ns_sync1 <= ped_ns;
            ped_ns_sync2 <= ped_ns_sync1;
	    ped_ew_sync1 <= ped_ew;
            ped_ew_sync2 <= ped_ew_sync1;
        end
    end
always @(posedge clk) begin
        if (!rst_n) begin
            ped_ns_pressed <= 1'b0;
            ped_ew_pressed <= 1'b0;
        end
        else begin
            if (ped_ns_sync2 && !ped_ns_pressed)
                ped_ns_pressed <= 1'b1;
            else if (clear_ped_ns)
                ped_ns_pressed <= 1'b0;
            if (ped_ew_sync2 && !ped_ew_pressed)
                ped_ew_pressed <= 1'b1;
            else if (clear_ped_ew)
                ped_ew_pressed <= 1'b0;

        end
    end
    always @(*) begin
        next_state = state;
        current_timeout = ns_green_time;
        clear_ped_ns = 1'b0;
        clear_ped_ew = 1'b0;
        case (state)
            ns_green: begin
                current_timeout = ns_green_time;
                if (timer_done || ped_ew_pressed) begin
                    next_state = ns_yellow;
                    clear_ped_ew = 1'b1;
                end
              end
            ns_yellow: begin
                current_timeout = yellow_time;
                if (timer_done)
                    next_state = all_red1;
               end
            all_red1: begin
                current_timeout = red_time;
                if (timer_done)
                    next_state = ew_green;
              end
            ew_green: begin
                current_timeout = ew_green_time;
                if (timer_done || ped_ns_pressed) begin
                    next_state = ew_yellow;
                    clear_ped_ns = 1'b1;
                end
              end
            ew_yellow: begin
                current_timeout = yellow_time;
                if (timer_done)
                    next_state = all_red2;
               end
            all_red2: begin
                current_timeout = red_time;
                if (timer_done)
                    next_state = ns_green;
                end
            default: begin
                next_state = ns_green;
                current_timeout = ns_green_time;
                end
        endcase
end
always @(posedge clk) begin
        if (!rst_n)
            state <= ns_green;
        else if (timer_done || (next_state != state))
            state <= next_state;
    end
    always @(*) begin
        light_ns = 3'b100;
        light_ew = 3'b100;
        walk_ns = 1'b0;
        walk_ew = 1'b0;
        case (state)
            ns_green: begin
                light_ns = 3'b001;
                light_ew = 3'b100;
            end
            ns_yellow: begin
                light_ns = 3'b010;
                light_ew = 3'b100;
            end
            all_red1: begin
                light_ns = 3'b100;
                light_ew = 3'b100;
            end
            ew_green: begin
                light_ns = 3'b100;
                light_ew = 3'b001;
            end
            ew_yellow: begin
                light_ns = 3'b100;
                light_ew = 3'b010;
            end
            all_red2: begin
                light_ns = 3'b100;
                light_ew = 3'b100;
            end
            default: begin
                light_ns = 3'b100;
                light_ew = 3'b100;
            end
        endcase
    end
endmodule
