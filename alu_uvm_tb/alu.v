module adder32_cla(
  input         clk     ,
  input         rst     ,
  input         enable  ,
  input  [31:0] a       ,
  input  [31:0] b       ,
  input         cin     ,
  output [31:0] sum_r   ,
  output        cout_r  
);

  reg [31:0] sum_r  = 32'h00000000 ;
  reg        cout_r = 1'h0  ;

always @(posedge clk or negedge rst) 
  begin
    if (!rst)
      begin
        sum_r  = 32'h00000000  ;
        cout_r =  1'h0          ;
      end
    else if(enable)
      begin 
        {cout_r,sum_r} <= a + b + cin;              
      end
    else
      begin               
        sum_r  <= sum_r  ;
        cout_r <= cout_r ;
      end                                   
  end    
  
endmodule