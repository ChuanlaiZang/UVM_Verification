`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item; 
//该数据包在my_case0，测试用例中被`uvm_do例化，随机化，并传到sequencer中，
//传到那个sequencer通过在default_sequence中指定的启动路径决定

   rand bit[47:0] dmac;
   rand bit[47:0] smac;
   rand bit[15:0] ether_type;
   rand byte      pload[];
   rand bit[31:0] crc;

   constraint pload_cons{        //随机约束
      pload.size >= 46;
      pload.size <= 1500;
   }

   function bit[31:0] calc_crc();       //这里只是例子，不是实际的crc校验算法
      return 32'h0;
   endfunction

   function void post_randomize();      
      crc = calc_crc;
   endfunction

   `uvm_object_utils_begin(my_transaction)  //通过field_automation机制，注册transation中的成员变量，之后就能使用uvm中的宏来处理这些数据
      `uvm_field_int(dmac, UVM_ALL_ON)
      `uvm_field_int(smac, UVM_ALL_ON)
      `uvm_field_int(ether_type, UVM_ALL_ON)
      `uvm_field_array_int(pload, UVM_ALL_ON)
      `uvm_field_int(crc, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
   endfunction

endclass
`endif