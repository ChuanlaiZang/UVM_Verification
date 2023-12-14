`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
   
   uvm_blocking_get_port #(my_transaction)  port;  //TLM级别的接收数据的参数化的类 uvm_blocking_get_port,参数就是接收的数据的类型
   uvm_analysis_port #(my_transaction)  ap;        //发送数据的参数化的类

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(my_model)
endclass 

function my_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void my_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this); //类的例化，所有的UVM都应该用uvm宏的方式注册，其他的类用new?
   ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
   my_transaction tr;
   my_transaction new_tr;
   super.main_phase(phase);
   while(1) begin
      port.get(tr);           //通过blocking_get_port的get方法来接收monitor传过来的数据
      new_tr = new("new_tr"); //例化
      new_tr.copy(tr);        //transaction中的成员变量都使用field_automation注册过了，可以使用UVM的copy函数
      `uvm_info("my_model", "get one transaction, copy and print it:", UVM_LOW)
      new_tr.print();         //打印函数也是UVM宏
      ap.write(new_tr);       //通过ap把new_tr发送给scoreboard。发送对象在env层次的fifo指定
   end
endtask
`endif