module Async_FIFO
# (
    parameter   DATA_WIDTH = 4,
    parameter   DATA_DEPTH = 8,
    parameter   PTR_WIDTH  = 3
)

(
    input                           w_clk, r_clk, w_rst_n, r_rst_n,
    input                           w_en, r_en,
    input       [DATA_WIDTH-1:0]    w_data,
    output  reg [DATA_WIDTH-1:0]    r_data,
    output  reg                     full, empty
);

    reg     [DATA_WIDTH-1:0]    mem_array   [0:DATA_DEPTH-1];
    reg     [PTR_WIDTH   :0]    w_ptr, r_ptr;
 //   reg     [PTR_WIDTH-1 :0]    elem_cnt;
    reg     [PTR_WIDTH   :0]    i;
    reg     [PTR_WIDTH   :0]    w_ptr_gray_d1, w_ptr_gray_d2, r_ptr_gray_d1, r_ptr_gray_d2;
    wire    [PTR_WIDTH   :0]    w_ptr_gray, r_ptr_gray;

/*-------------------------------------------\
 --------write pointer & bin -> gray---------
\-------------------------------------------*/

    always@(posedge w_clk or negedge w_rst_n)
    begin
        if(!w_rst_n)
            w_ptr <= 4'b0;
        else if(w_en && !full)
            w_ptr <= w_ptr + 4'b1;
    end

    assign w_ptr_gray = w_ptr ^ (w_ptr >> 1);

/*-------------------------------------------\
 ---------read pointer & bin -> gray---------
\-------------------------------------------*/

    always@(posedge r_clk or negedge r_rst_n)
    begin
        if(!r_rst_n)
            r_ptr <= 4'b0;
        else if(r_en && !empty)
            r_ptr <= r_ptr + 4'b1;
    end

    assign r_ptr_gray = r_ptr ^ (r_ptr >> 1);

/*-------------------------------------------\
 -----------------gray sync------------------
\-------------------------------------------*/

    always@(posedge r_clk or negedge w_rst_n)
    begin
        if(!w_rst_n)
        begin
            w_ptr_gray_d1 <= 4'b0;
            w_ptr_gray_d2 <= 4'b0;
        end
        else
        begin
            w_ptr_gray_d1 <= w_ptr_gray;
            w_ptr_gray_d2 <= w_ptr_gray_d1;
        end
    end

    always@(posedge w_clk or negedge r_rst_n)
    begin
        if(!r_rst_n)
        begin
            r_ptr_gray_d1 <= 4'b0;
            r_ptr_gray_d2 <= 4'b0;
        end
        else
        begin
            r_ptr_gray_d1 <= r_ptr_gray;
            r_ptr_gray_d2 <= r_ptr_gray_d1;
        end
    end

/*-------------------------------------------\
 -----------------full & empty---------------
\-------------------------------------------*/

    always@(*)
    begin
        if(!w_rst_n)
            full = 1'b0;
        else if(w_ptr_gray == {~r_ptr_gray_d2[PTR_WIDTH:PTR_WIDTH-1], r_ptr_gray_d2[PTR_WIDTH-2:0]})
            full = 1'b1;
        else
            full = 1'b0;
    end

    always@(*)
    begin
        if(!r_rst_n)
            empty = 1'b0;
        else if(r_ptr_gray == w_ptr_gray_d2)
            empty = 1'b1;
        else
            empty = 1'b0;
    end

/*-------------------------------------------\
 -------------------datapath-----------------
\-------------------------------------------*/

    always@(posedge w_clk or negedge w_rst_n)
    begin
        if(!w_rst_n)
        begin
            for(i = 0; i < DATA_DEPTH; i = i + 1)
            begin
                mem_array[i] <= 4'b0;
            end
        end
        else if(w_en && !full)
            mem_array[w_ptr[PTR_WIDTH-1:0]] <= w_data;
    end

    always@(posedge r_clk or negedge r_rst_n)
    begin
        if(!r_rst_n)
            r_data <= 4'b0;
        else if(r_en && !empty)
            r_data <= mem_array[r_ptr[PTR_WIDTH-1:0]];
    end
    
endmodule
