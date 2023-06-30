class fifo_env extends uvm_env;

  `uvm_component_utils(fifo_env)

  function new (string name = "fifo_env", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual fifo_intf intf;
  fifo_agent_active fifo_ag_active;
  fifo_agent_passive fifo_ag_passive;
  fifo_scoreboard fifo_sb;
  funct_coverage cov;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(uvm_config_db #(virtual fifo_intf)::get(this, "", "VIRTUAL_INTERFACE", intf) == 0) begin
      `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
    end
    
    fifo_ag_active = fifo_agent_active::type_id::create ("fifo_ag_active", this);
    fifo_ag_passive = fifo_agent_passive::type_id::create ("fifo_ag_passive", this);
    fifo_sb = fifo_scoreboard::type_id::create ("fifo_sb", this);
    cov = funct_coverage::type_id::create ("cov", this);
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);    
      
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    fifo_ag_active.fifo_mntr_wr.mon_analysis_port.connect(fifo_sb.fifo_drv);
    fifo_ag_passive.fifo_mntr_rd.mon_analysis_port.connect(fifo_sb.fifo_mon);
  endfunction

endclass