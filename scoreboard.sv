`uvm_analysis_imp_decl( _drv )
`uvm_analysis_imp_decl( _mon ) 

class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils (fifo_scoreboard)

    function new (string name, uvm_component parent=null);
		super.new (name, parent);
	endfunction

    uvm_analysis_imp_drv #(fifo_item, fifo_scoreboard) fifo_drv;
    uvm_analysis_imp_mon #(fifo_item, fifo_scoreboard) fifo_mon;

    logic [7:0] ref_model [$];  
  
	function void build_phase (uvm_phase phase);
      fifo_drv = new ("fifo_drv", this);
      fifo_mon = new ("fifo_mon", this);
	endfunction

    virtual function void write_drv (fifo_item item);
      `uvm_info ("drv", $sformatf("Data received = 0x%0h", item.data), UVM_MEDIUM)
      ref_model.push_back(item.data);
	endfunction
  
    virtual function void write_mon (fifo_item item);
      `uvm_info ("mon", $sformatf("Data received = 0x%0h", item.data), UVM_MEDIUM)
      if (item.data !== ref_model.pop_front()) begin
        `uvm_error("SB error", "Data mismatch");
      end
      else begin
        `uvm_info("SB PASS", $sformatf("Data received = 0x%0h", item.data), UVM_MEDIUM);
      end
    endfunction

	virtual task run_phase (uvm_phase phase);
		
	endtask

	virtual function void check_phase (uvm_phase phase);
      if(ref_model.size() > 0)
        `uvm_warning("SB Warn", $sformatf("FIFO not empty at check phase. Fifo still has 0x%0h data items allocated", ref_model.size()));
	endfunction
endclass