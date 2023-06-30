class fifo_item extends uvm_sequence_item;

  rand logic [7:0] data;
  rand bit   rd;

  // Use utility macros to implement standard functions
  // like print, copy, clone, etc
  `uvm_object_utils_begin(fifo_item)
    `uvm_field_int (data, UVM_DEFAULT)
    `uvm_field_int (rd, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "fifo_item");
    super.new(name);
  endfunction
endclass

class gen_item_seq extends uvm_sequence;
  `uvm_object_utils(gen_item_seq)
  function new(string name="gen_item_seq");
    super.new(name);
  endfunction

  rand int num; 	// Config total number of items to be sent

  constraint c1 { num inside {[2:5]}; }

  virtual task body();
    fifo_item f_item = fifo_item::type_id::create("f_item");
    for (int i = 0; i < num; i ++) begin
        start_item(f_item);
    	f_item.randomize();
    	`uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
    	f_item.print();
        finish_item(f_item);
        //`uvm_do(f_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass


class fifo_driver extends uvm_driver #(fifo_item);

  `uvm_component_utils (fifo_driver)
   function new (string name = "fifo_driver", uvm_component parent = null);
     super.new (name, parent);
   endfunction

   virtual fifo_intf intf;

   virtual function void build_phase (uvm_phase phase);
     super.build_phase (phase);
     if(uvm_config_db #(virtual fifo_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
       `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
     end
   endfunction
   
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      fifo_item f_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(f_item);
      fork
        drive_fifo(f_item);
        read_fifo(f_item);
      join
      seq_item_port.item_done();
    end
  endtask  

  virtual task drive_fifo(fifo_item f_item);
    if(f_item.rd ==0)   
      begin
        @ (negedge intf.clk);
        $display("Driving 0x%h value in the DUT\n", f_item.data);
        intf.data_in = f_item.data; // Drive to DUT
        intf.wr_en = 1;
        @ (negedge intf.clk);
        intf.wr_en = 0;
      end
  endtask
  
  virtual task read_fifo(fifo_item f_item);
    if(f_item.rd ==1)
      begin
        @ (negedge intf.clk);
        intf.rd_en = 1;
        @ (negedge intf.clk);
        intf.rd_en = 0;
      end
  endtask
       
  virtual task fifo_reset();  // Reset method
    $display("Executing Reset\n");
    intf.data_in = 0;
    intf.rst = 0;
    intf.wr_cs = 0;
    intf.rd_cs = 0;
    intf.data_in = 0;
    intf.rd_en = 0;
    intf.wr_en = 0;
    intf.rst = 1;
    @ (negedge intf.clk);
    intf.rst = 0;
    @ (negedge intf.clk);
    intf.wr_cs = 1;
    intf.rd_cs = 1;

  endtask
        
  
endclass
