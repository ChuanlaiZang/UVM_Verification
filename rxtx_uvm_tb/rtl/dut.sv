//dut.sv
module dut(clk,                 //DUT功能，通过rxd接受数据，再通过txd发送出去
           rst_n,               //复位信号
           rxd,                 //8bit的接收到的数据
           rx_dv,               //接受的数据有效位
           txd,                 //8bit的发送的数据 
           tx_en);              //发送信号的数据有效位
input clk;
input rst_n;                    //对于这样一个简单的dut，使用UVM环境进行验证
input[7:0] rxd;                 //要造随机的测试用例作为激励给到dut，然后检测dut的输出信号，如果输出等于输入的话，那么说明dut功能正常
input rx_dv;
output [7:0] txd;
output tx_en;

reg[7:0] txd;
reg tx_en;

always @(posedge clk) begin
   if(!rst_n) begin
      txd <= 8'b0;
      tx_en <= 1'b0;
   end
   else begin
      txd <= rxd;
      tx_en <= rx_dv;
   end
end
endmodule