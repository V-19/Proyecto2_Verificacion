class test_basic2 extends test_basic;

  `uvm_component_utils(test_basic2)
  
  function new (string name="test_basic2", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
  	 
     // Get handle to the singleton factory instance
    uvm_factory factory = uvm_factory::get();
    
    super.build_phase(phase);
    
    //factory to override 'base_agent' by 'child_agent' by name
    factory.set_type_override_by_name("gen_item_seq", "gen_item_seq2");

    // Print factory configuration
    factory.print();
  endfunction

endclass

class gen_item_seq2 extends gen_item_seq;
    `uvm_object_utils(gen_item_seq2)
  function new(string name="gen_item_seq2");
    super.new(name);
  endfunction
  
  rand int num; 	// Config total number of items to be sent

  constraint c1 { num inside {[20:50]}; }
  
  virtual task body();
     fifo_item f_item = fifo_item::type_id::create("f_item");
    for (int i = 0; i < num; i ++) begin
        `uvm_do(f_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask

endclass

