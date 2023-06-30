class fifo_agent_active extends uvm_agent;
  `uvm_component_utils(fifo_agent_active)
  function new(string name="fifo_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual fifo_intf intf;
  fifo_driver fifo_drv;
  uvm_sequencer #(fifo_item)	fifo_seqr;

  fifo_monitor_wr fifo_mntr_wr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual fifo_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    fifo_drv = fifo_driver::type_id::create ("fifo_drv", this); 
    
    fifo_seqr = uvm_sequencer#(fifo_item)::type_id::create("fifo_seqr", this);
    
    fifo_mntr_wr = fifo_monitor_wr::type_id::create ("fifo_mntr_wr", this);
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.env.fifo_ag.fifo_drv", "VIRTUAL_INTERFACE", intf);    

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    fifo_drv.seq_item_port.connect(fifo_seqr.seq_item_export);
  endfunction

endclass

class fifo_agent_passive extends uvm_agent;
  `uvm_component_utils(fifo_agent_passive)
  function new(string name="fifo_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual fifo_intf intf;
  
  fifo_monitor_rd fifo_mntr_rd;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual fifo_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    fifo_mntr_rd = fifo_monitor_rd::type_id::create ("fifo_mntr_rd", this);

    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.env.fifo_ag.fifo_drv", "VIRTUAL_INTERFACE", intf);    

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass