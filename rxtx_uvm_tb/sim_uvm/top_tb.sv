`timescale 1ns/1ps                     //定义仿真单位/精度
`include "uvm_macros.svh"              //调用uvm宏

import uvm_pkg::*;                     //导入uvm库
`include "my_if.sv"                    //调用仿真文件
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"

module top_tb;  //测试顶层

reg clk;        
reg rst_n;
reg[7:0] rxd;
reg rx_dv;
wire[7:0] txd;
wire tx_en;

my_if input_if(clk, rst_n);   //在顶层做接口例化，用于连接测试上述的测试文件和dut
my_if output_if(clk, rst_n);  //对dut的输出口的接口例化

dut my_dut(.clk(clk),                     //dut的端口连接不同的接口信号，clk和rst信号直接在top_tb的initial 中生成
           .rst_n(rst_n),
           .rxd(input_if.data),
           .rx_dv(input_if.valid),
           .txd(output_if.data),
           .tx_en(output_if.valid));

initial begin                              //生产时钟信号
   clk = 0;
   forever begin
      #100 clk = ~clk;
   end
end

initial begin                              //生成rst信号
   rst_n = 1'b0;
   #1000;
   rst_n = 1'b1;
end

initial begin
   run_test();  
   //括号中如果有参数的话，应该是一个字符串类型如，run_test("my_case0")。将会自动创建一个my_case0的实例，例化名为uvm_test_top。并自动调用该my_case0中的main_phase。
   //这里括号中没有参数，是为了多个用例的选择，通过仿真时指定 +UVM_TESTNAME = my_case1来指定测试用例。
end             


initial begin
//虚接口的连接，第一参数指定传输类型时虚接口，set的第二个参数是第一个参数的相对路径，这里第一个参数是top_tb,是一个Module，不是类，不能使用this指针，第二个参数使用run_test例化后的例化名uvm_test_top作为根目录
//第三个参数是目标路径设定的接口句柄（set和get的第三个参数必须相同），第四个参数是当前层的传输对象名。
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);  //把input_if接口和i_agt下句柄名为drv的driver模块中的句柄名为vif的接口连接起来
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);  //输入monitor的连接
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if); //输出口monitor的连接
end

endmodule