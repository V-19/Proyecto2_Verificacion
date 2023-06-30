class SDRAM_agent_active extends uvm_agent;
  `uvm_component_utils(SDRAM_agent_active)
  function new(string name="SDRAM_agent_active", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  
 
  sdr_ctrl_driver sdram_drv;
  
  uvm_sequencer #(sdram_ctrl_item) sdram_seqr;

  sdram_monitor_write sdram_mntr_wr;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
            
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    
    
    sdram_drv = sdr_ctrl_driver ::type_id::create ("sdram_drv", this); 
    
    sdram_seqr = uvm_sequencer#(sdram_ctrl_item)::type_id::create("sdram_seqr", this);
    
    sdram_mntr_wr = sdram_monitor_write::type_id::create ("sdram_mntr_wr", this);
    
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.env.fifo_ag.fifo_drv", "VIRTUAL_INTERFACE", intf);    no

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      sdram_drv.seq_item_port.connect(sdram_seqr.seq_item_export);
  endfunction

endclass

class SDRAM_agent_passive extends uvm_agent;
  `uvm_component_utils(SDRAM_agent_passive)
  function new(string name="SDRAM_agent_passive", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  
  
  sdram_monitor_rd sdram_mntr_rd;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    sdram_mntr_rd = sdram_monitor_rd::type_id::create ("sdram_mntr_rd", this);

    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.env.fifo_ag.fifo_drv", "VIRTUAL_INTERFACE", intf);    no

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

endclass