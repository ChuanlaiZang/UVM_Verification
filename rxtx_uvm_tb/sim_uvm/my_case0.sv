`ifndef MY_CASE0__SV
`define MY_CASE0__SV
class case0_sequence extends uvm_sequence #(my_transaction); //用例也是一个参数化的类，参数是准备处理的数据包
   my_transaction m_trans;                                   //声明句柄

   function  new(string name= "case0_sequence");             //扩展类的构造函数
      super.new(name);
   endfunction 
   
   virtual task body();                                      //每个sequence都有一个body 任务，sequence启动时会自动执行body中的代码
      if(starting_phase != null)                             //在通过default_sequence启动用例时，在sequencer中会自动得到一个phase类型的starting_phase
         starting_phase.raise_objection(this);               //所以可以在sequence中通过starting_phase来提起objection来控制验证平台的开启
      repeat (10) begin
         `uvm_do(m_trans)                                    //`uvm_do 包含三个动作，1）实例化m_trans、2）将其随机化 3）把它传给sequencer
      end
      #100;
      if(starting_phase != null) 
         starting_phase.drop_objection(this);                //关闭仿真平台
   endtask

   `uvm_object_utils(case0_sequence)                         //注册case0_sequence
endclass


class my_case0 extends base_test;                            //派生自base_test，base_test派生自uvm_test

   function new(string name = "my_case0", uvm_component parent = null); //扩展类的构造函数
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase);   //在uvm_test_top组件的build中启动case0_sequence
   `uvm_component_utils(my_case0)                                           
endclass


function void my_case0::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this,                            //通过config_db来设定case0_sequence在第一/二参数指定的路径下启动。main_phase是固定的要求
                                           "env.i_agt.sqr.main_phase",      //这里定义了config_db的set，但是不需要在目标类中再定义get,UVM中自动做了这件事  
                                           "default_sequence",                 //固定的要求
                                           case0_sequence::type_id::get());    //case0_sequence 按要求修改
endfunction

`endif