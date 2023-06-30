`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon )

class scoreboard extends uvm_scoreboard;
  
	`uvm_component_utils (scoreboard)
  
	function new (string name, uvm_component parent=null);
		super.new (name, parent);
	endfunction
  
  
  uvm_analysis_imp_drv #(sdram_ctrl_item, scoreboard) mc_drv;
  uvm_analysis_imp_mon #(sdram_ctrl_item, scoreboard) mc_mon;

    int afifo[$]; // address  fifo
  	int s_data[int];

	function void build_phase (uvm_phase phase);
      mc_drv = new ("mc_drv", this);
      mc_mon = new ("mc_mon", this);
	endfunction
	
  virtual function void write_drv (sdram_ctrl_item item);
    reg [31:0] address;  
    address={5'h0,item.addr[7:0]};
     `uvm_info ("drv", $sformatf("Data received = 0x%0h", item.data), UVM_MEDIUM)
    
    `uvm_info ("drv", $sformatf("Data bl = 0x%0h", item.bl), UVM_MEDIUM)
    
     `uvm_info ("drv", $sformatf("Addr received = 0x%0h", address), UVM_MEDIUM)
     //`uvm_info ("drv", $sformatf("Bl received = 0x", item.bl), UVM_MEDIUM)
    	s_data[address] = item.data;
    	afifo.push_back(address);
	endfunction
  
  
  
    virtual function void write_mon (sdram_ctrl_item item);
      reg [31:0] r_data;
      r_data = s_data[item.addr];
      `uvm_info ("mon", $sformatf("Data received = 0x%0h, Data delivered= %x", item.data, r_data), UVM_MEDIUM)
      if (item.data !== s_data[item.addr]) begin
        `uvm_error("Data error", "Data mismatch");
      end
      else begin
        `uvm_info("Data PASS", $sformatf("Data received = 0x%0h", item.data), UVM_MEDIUM);
      end
      
      if (item.addr !==  afifo.pop_front()) begin
        `uvm_error("Addr Error", "Addr mismatch");
      end
      else begin
        `uvm_info("Addr PASS", $sformatf("Addr received = 0x%0h", item.addr), UVM_MEDIUM);
      end
      
      
      
    endfunction

	virtual task run_phase (uvm_phase phase);
		
    endtask
  
  

endclass
