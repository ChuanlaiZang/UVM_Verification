`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
class my_monitor extends uvm_monitor;

   virtual my_if vif;

   uvm_analysis_port #(my_transaction)  ap;   //TLM的发送数据的参数化的类，其参数就是需要传递的数据的类型，这里声明一个句柄
   
   `uvm_component_utils(my_monitor)
   function new(string name = "my_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))  //接收虚接口
         `uvm_fatal("my_monitor", "virtual interface must be set for vif!!!") 
      ap = new("ap", this);  //例化TLM发送数据的类
   endfunction

   extern task main_phase(uvm_phase phase);  
   extern task collect_one_pkt(my_transaction tr);
endclass

task my_monitor::main_phase(uvm_phase phase);
   my_transaction tr;  //例化数据
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      ap.write(tr);
   end
endtask

task my_monitor::collect_one_pkt(my_transaction tr);
   byte unsigned data_q[$];
   byte unsigned data_array[];
   logic [7:0] data;
   logic valid = 0;
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.valid) break; //vaild无效时不收集数据
   end
   
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW); 
   while(vif.valid) begin
      data_q.push_back(vif.data);      //使能信号有效时，按照时钟周期，把data压入队列data_q中
      @(posedge vif.clk);
   end
   data_size  = data_q.size();         //构造一个和队列size相同的动态数组
   data_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      data_array[i] = data_q[i];       //给动态数组赋值
   end
   tr.pload = new[data_size - 18]; //da sa, e_type, crc  //pload在transation中本来就是一个动态数组，
   data_size = tr.unpack_bytes(data_array) / 8;  //通过unpack_bytes函数把data_q中收集到的byte流数据转换成tr中的各个字段，unpacked_bytes的参数必须是一个动态数组，所以才有54行代码的操作
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif