`ifndef MY_SEQUENCER__SV
`define MY_SEQUENCER__SV

class my_sequencer extends uvm_sequencer #(my_transaction);   //my_sequencer只是driver和sequence之间的桥梁，在其他层次设定了在此处启动sequence，从而得到在agent层例化，并和driver连接起来
   `uvm_component_utils(my_sequencer)

   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(my_sequencer)
endclass

`endif

