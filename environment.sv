class environment extends uvm_env;
  
  `uvm_component_utils(environment)
  
  /*driver drvr;
  scoreboard sb;
  monitor_write mntrw;
  monitor_read mntrr;
  */
  

  
  /*virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
           
  function new(virtual intf_WB_G2 vir_intf_WB, virtual intf_SRAM_G2 vir_intf_SRAM);
    $display("Creating environment");
    this.vir_intf_WB = vir_intf_WB;
    this.vir_intf_SRAM=vir_intf_SRAM;
    sb = new();
    drvr = new(vir_intf_WB,vir_intf_SRAM,sb);
    mntrw = new(vir_intf_WB,vir_intf_SRAM,sb);
    mntrr = new(vir_intf_WB,vir_intf_SRAM,sb);
    fork 
      mntrr.check();
      mntrw.check();
    join_none
  endfunction*/

  
  function new (string name = "environment", uvm_component parent = null);
    super.new (name, parent);
  endfunction
  
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  
  
  SDRAM_agent_active SDRAM_ag_active;
  SDRAM_agent_passive SDRAM_ag_passive; 
  scoreboard sb;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
        
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    
    SDRAM_ag_active = SDRAM_agent_active::type_id::create ("SDRAM_ag_active", this);
    SDRAM_ag_passive =  SDRAM_agent_passive::type_id::create ("SDRAM_ag_passive", this);
    sb = scoreboard::type_id::create ("sb", this); 
    
    //uvm_config_db #(virtual fifo_intf)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE", intf);    
      
    uvm_report_info(get_full_name(),"End_of_build_phase", UVM_LOW);
    print();

  endfunction
  
   virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
     SDRAM_ag_active.sdram_mntr_wr.mon_analysis_port.connect(sb.mc_drv);
     SDRAM_ag_passive.sdram_mntr_rd.mon_analysis_port.connect(sb.mc_mon);
  endfunction
  
endclass