`ifndef MY_ENV__SV
`define MY_ENV__SV

class my_env extends uvm_env;   //是一个容器，用于例化/连接各个组件，都是TLM级别传输

   my_agent   i_agt;
   my_agent   o_agt;
   my_model   mdl;
   my_scoreboard scb; //例化各组件
   
   uvm_tlm_analysis_fifo #(my_transaction) agt_scb_fifo;  //声明一个参数化的类，参数是传输数据的类型
   uvm_tlm_analysis_fifo #(my_transaction) agt_mdl_fifo;
   uvm_tlm_analysis_fifo #(my_transaction) mdl_scb_fifo;
   
   function new(string name = "my_env", uvm_component parent); //扩展类的构造函数
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      i_agt = my_agent::type_id::create("i_agt", this);    //组件例化
      o_agt = my_agent::type_id::create("o_agt", this);
      i_agt.is_active = UVM_ACTIVE;                        //参数传递，i_agt,o_agt在build中例化的话，is_active变量就能够被识别，如果用new例化，还要用config_db传输is_active才行
      o_agt.is_active = UVM_PASSIVE;
      mdl = my_model::type_id::create("mdl", this);         //组件例化
      scb = my_scoreboard::type_id::create("scb", this);
      agt_scb_fifo = new("agt_scb_fifo", this);             //类例化
      agt_mdl_fifo = new("agt_mdl_fifo", this);
      mdl_scb_fifo = new("mdl_scb_fifo", this);

   endfunction

   extern virtual function void connect_phase(uvm_phase phase); //build_phase后执行
   
   `uvm_component_utils(my_env)
endclass

function void my_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
   i_agt.ap.connect(agt_mdl_fifo.analysis_export);         //TLM级别传输通过fifo来连接输入/输出
   mdl.port.connect(agt_mdl_fifo.blocking_get_export);
   mdl.ap.connect(mdl_scb_fifo.analysis_export);
   scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
   o_agt.ap.connect(agt_scb_fifo.analysis_export);
   scb.act_port.connect(agt_scb_fifo.blocking_get_export); 
endfunction

`endif