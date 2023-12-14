`ifndef MY_AGENT__SV
`define MY_AGENT__SV

class my_agent extends uvm_agent ; 
   my_sequencer  sqr; //agent中封装了三个组件 sequence driver monitor,他们三个因为关系密切被封装到一起，driver从sequencer中拿到激励
   my_driver     drv; //monitor和drv处理的是同一种协议，drv把transation的数据转换为dut端口可使用的数据，而monitor把dut的端口数据转换为 transaction中能检测的数据类型
   my_monitor    mon;
   
   uvm_analysis_port #(my_transaction)  ap;  //uvm_analysis_port是TLM传输级别的一种发送方式，是一个参数化的类，参数就是发送数据的类型
   
   function new(string name, uvm_component parent); //uvm_agent也是UVM的组件
      super.new(name, parent);
   endfunction 
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void connect_phase(uvm_phase phase);

   `uvm_component_utils(my_agent) //注册宏
endclass 


function void my_agent::build_phase(uvm_phase phase);
   super.build_phase(phase);
   if (is_active == UVM_ACTIVE) begin                       // is_active 是是uvm_agent中的成员变量，当is_active == UVM_PASSIVE时，只需要例化monitor
      sqr = my_sequencer::type_id::create("sqr", this);
      drv = my_driver::type_id::create("drv", this);
   end
   mon = my_monitor::type_id::create("mon", this);
endfunction 

function void my_agent::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(sqr.seq_item_export);  //seq_item_port时uvm_driver中的一个成员变量，而 seq_item_export是sequencer中的一个成员变量
   end                                                 //driver要向 sequencer申请transaction，必须先通过connect把这两个成员变量连接起来，driver才能使用get_next_item来向sequencer申请新的transaction
   ap = mon.ap;  //model中需要从monitor中拿到transaction，但是monitor和model不在一层UVM结点，需要通过agent传递一下ap值
endfunction

`endif