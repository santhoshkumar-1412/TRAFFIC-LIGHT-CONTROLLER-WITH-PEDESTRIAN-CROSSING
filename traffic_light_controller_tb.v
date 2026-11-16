`timescale 1ns/1ps
module traffic_controller_tb;
wire [2:0] light_ns, light_ew;
wire walk_ns, walk_ew;
reg clk, rst_n,ped_ns, ped_ew;
traffic_controller uut (.clk(clk),.rst_n(rst_n),.ped_ns(ped_ns),.ped_ew(ped_ew),.light_ns(light_ns),.light_ew(light_ew),.walk_ns(walk_ns),.walk_ew(walk_ew));
always #5 clk = ~clk;
initial begin
    $fsdbDumpfile("traffic_controller.fsdb");
    $fsdbDumpvars(0, traffic_controller_tb);
end
initial begin
    $monitor("Time=%0t rst_n=%b ped_ns=%b ped_ew=%b NS=%b EW=%b WALK_NS=%b WALK_EW=%b",$time, rst_n, ped_ns, ped_ew,light_ns, light_ew, walk_ns, walk_ew);
end
initial begin
    clk = 0;
    rst_n = 0;
    ped_ns = 0;
    ped_ew = 0;
//test1
    #20 rst_n = 1;
//test2
    #10000;
//test3
    ped_ns = 1;
    #50 ped_ns = 0;
//test4
    #100;
    ped_ew = 1;
    #50 ped_ew = 0;
//test5
    #100;
    ped_ns = 1;
    ped_ew = 1;
    #50;
    ped_ns = 0;
    ped_ew = 0;
    #10000;
    $finish;
end
endmodule
