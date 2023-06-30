import uvm_pkg::*;

module top_hdl();
  reg clk = 0;
  initial // clock generator
  forever #5 clk = ~clk;
   
  // Interface
  fifo_intf intf(clk);
  
  // DUT connection	
  sync_fifo dut (
    .clk   (clk), 
    .rst   (intf.rst),
    .wr_cs  (intf.wr_cs),
    .rd_cs  (intf.rd_cs),
    .data_in (intf.data_in),
    .rd_en  (intf.rd_en),
    .wr_en  (intf.wr_en),
    .data_out (intf.data_out),
    .empty  (intf.empty),
    .full   (intf.full) 
  );

initial begin
  //$dumpfile("dump.vcd"); 
  //$dumpvars;
   
  uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top", "VIRTUAL_INTERFACE", intf);
  	
end
  
endmodule