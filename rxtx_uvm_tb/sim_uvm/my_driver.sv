`ifndef MY_DRIVER__SV  //drive从sequencer中拿到激励后，发送激励到dut. 条件编译
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);  
//driver 派生自 uvm_driver ，是一种通过虚拟接口来连接UVM中的类和DUT

   virtual my_if vif;          //声明虚拟接口                       

   `uvm_component_utils(my_driver)                    //通过宏注册my_driver类
   //通过注册，它使得my_driver类可以利用UVM工厂的方法，如create和type_id::create，
   //来动态创建组件实例。这对于在测试中动态更改或配置组件特别有用。
   function new(string name = "my_driver", uvm_component parent = null); 
   //派生自uvm_component的类在例化时，要指定name和parent两个参数，指定了parent后就决定了该类在UVM树的位置
      super.new(name, parent);             
      //扩展类的构造函数。如果父类的构造函数是有参数的，那么必须在子类中有一个构造函数函数，
      //而且必须在子类的构造函数第一行调用父类的构造函数，包括sv的new,UVM的build
   endfunction

   virtual function void build_phase(uvm_phase phase);                  
   //UVM中通过phase来让不同的任务发生在不同的阶段，通过build_phase来传递虚接口，例化类
      super.build_phase(phase);                                         //build_phase派生自wvm_phase 父类中有build操作，在子类中也必须被调用
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))     //uvm_config_db用来传递虚接口的用法，在driver中接受类型为virtual my_if的句柄为vif的接口传递给当前类中的名为vif接口
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")  //如果虚接口传输发生错误，报错并停止仿真。因为driver必须要和连接顶层的接口才能驱动dut
   endfunction

   extern task main_phase(uvm_phase phase);  
   //extern(外部)用于在外部定义一个类方法，以让类代码长度能够精简。main_phase是一种run_phase，会消耗仿真时间。driver的主要动作就在main_phase中发生
   extern task drive_one_pkt(my_transaction tr);  
   //外部任务，驱动一个数据包
endclass

task my_driver::main_phase(uvm_phase phase);   //通过类名来调用类中的main_phase，在此定义
   vif.data <= 8'b0;                           //在上面通过config_db连接了虚接口，这里就可以使用vif句柄来调用顶层的接口信号了
   vif.valid <= 1'b0;                           
   while(!vif.rst_n)                           //当非复位状态时
      @(posedge vif.clk);                      
   while(1) begin                              //循环
      seq_item_port.get_next_item(req);        //seq_item_port是driver中的TLM传输的方法，使用get_next_item从sequencer中得到数据包req
      drive_one_pkt(req);                      //在driver例化时如果指定了驱动的transaction的类型参数，就能使用uvm_driver中的预定义的成员变量req，req的类型就是指定的参数，这里时my_transation
      seq_item_port.item_done();               //这里driver调用了get_next_item和item_done是driver和sequencer之间的握手机制，调用item_done表示driver成功的驱动了req，sequencer可以发送新数据了，如果没有调用item_done的话，sequencer会重新发送之前的数据，直到item_done被调用
   end                                         //这里为啥用while(1)来循环？-> 因为driver只是驱动 transaction ，而不负责产生，只要有数据就驱动
endtask

task my_driver::drive_one_pkt(my_transaction tr); //driver驱动数据包，方法的参数就是数据包
   byte unsigned     data_q[];                    //定义一个位宽是字(8bit)的无符号动态数组
   int  data_size;                                //数据量
   
   data_size = tr.pack_bytes(data_q) / 8;         //这里的pack_bytes是把 transaction中的成员变量都通过field_automation机制注册后，使用的UVM系统函数。功能是把 transaction中的成员变量按照定义顺序以字单位打包到data_q中
   `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW); //打印信息的函数，第三个变量表示信息的重要程度，UVM默认只显示 UVM_LOW、UVM_MEDIUM
   repeat(3) @(posedge vif.clk);
   for ( int i = 0; i < data_size; i++ ) begin
      @(posedge vif.clk);
      vif.valid <= 1'b1;                          //把数据传输使能信号设定为有效
      vif.data <= data_q[i];                      //把data_q中存放的字单位的数据，按时钟周期传到接口上。
   end

   @(posedge vif.clk);
   vif.valid <= 1'b0;                             //数据传输完成后把使能信号无效化
   `uvm_info("my_driver", "end drive one pkt", UVM_LOW); //打印信息，表示driver已经传输完一个数据包了。
endtask


`endif