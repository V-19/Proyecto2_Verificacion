interface fifo_intf(input clk);
  
  logic rst;
  logic wr_cs;
  logic rd_cs;
  logic [7:0] data_in;
  logic rd_en;
  logic wr_en;
  logic [7:0] data_out;
  logic empty;
  logic full; 

endinterface
