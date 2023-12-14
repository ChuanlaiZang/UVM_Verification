`timescale 1ns/1ps

module tb_Sync_FIFO;
  reg          w_clk_i, r_clk_i;
  reg          w_rst_n_i, r_rst_n_i;

  reg          wr_en_i  ;
  reg  [3:0]   wr_data_i;
  
  reg          rd_en_i  ;
  wire  [3:0]  rd_data_o;

  wire          full_o   ;
  wire          empty_o  ;

parameter  w_clk_period = 1000;   //1GHz时钟： T = 1000ns
parameter  r_clk_period = 500;    //2GHz时钟： T = 500ns

// 生成写端clk：
initial
begin
  w_clk_i = 1'b1;
  forever
  begin
    #(w_clk_period/2)  w_clk_i = ~w_clk_i;
    
  end
end

//生成读端clk
initial
begin
  r_clk_i = 1'b1;
  forever
  begin
    #(r_clk_period/2)  r_clk_i = ~r_clk_i;
    
  end
end

//生成写复位、写使能、写数据
initial 
begin
  w_rst_n_i   = 1  ;
  

  wr_en_i   = 0  ;
  wr_data_i = 4'b0;

  #(w_clk_period)     w_rst_n_i = 0;
  #(w_clk_period*2)   w_rst_n_i = 1;

  @(posedge w_clk_i)
  begin
    wr_en_i = 1;

  end

  @(posedge w_clk_i)
  begin
    wr_en_i = 0;

  end

  @(posedge w_clk_i)
  begin
    wr_en_i = 1;

  end

  @(posedge w_clk_i)
  begin
    wr_en_i = 0;

  end

  #(w_clk_period)
  repeat(50)
  begin
      @(posedge w_clk_i)
      begin
        wr_en_i     = {$random}%2;
        wr_data_i   = {$random}%5'h10;
      end
  end

  #(w_clk_period)

  @(posedge w_clk_i)
  begin
    wr_en_i = 0;

  end

end

//生成读复位、读使能
initial 
begin
  r_rst_n_i   = 1  ;
  
  rd_en_i   = 0  ;

  #(r_clk_period)     r_rst_n_i = 0;
  #(r_clk_period*2)   r_rst_n_i = 1;

  @(posedge r_clk_i)
  begin
    rd_en_i = 0;
  end

  #(r_clk_period*30)
  repeat(60)
  begin
      @(posedge r_clk_i)
      begin
        rd_en_i = {$random}%2;
      end
  end
  
  #(r_clk_period*30)

  @(posedge r_clk_i)
  begin
    rd_en_i = 1;
  end

end

initial 
begin
  #(w_clk_period*125)
  $stop;
end

Async_FIFO u_Async_FIFO
(
  .w_clk    (w_clk_i  ),
  .r_clk    (r_clk_i  ),
  .w_rst_n  (w_rst_n_i),
  .r_rst_n  (r_rst_n_i),
  .w_en     (wr_en_i  ),
  .w_data   (wr_data_i),
  .r_en     (rd_en_i  ),
  .r_data   (rd_data_o),
  .full     (full_o   ),
  .empty    (empty_o  )
);


endmodule