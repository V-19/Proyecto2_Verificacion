/*program testcase(intf_WB_G2 vir_intf_WB, intf_SRAM_G2 vir_intf_SRAM);
  environment env = new(vir_intf_WB,vir_intf_SRAM);
  
  int k;
  initial
    begin
  env.drvr.reset();
  #1000;
  wait(u_dut.sdr_init_done == 1);
  #1000;
  $display("-------------------------------------- ");
  $display(" Case-1: Single Write/Read Case        ");
  $display("-------------------------------------- ");

  env.drvr.burst_write(8'h4);
 
 #1000;
  env.drvr.burst_read(8'h4);
  
  
   #100;
  // Repeat one more time to analysis the 
  // SDRAM state change for same col/row address
  $display("-------------------------------------- ");
  $display(" Case-2: Repeat same transfer once again ");
  $display("----------------------------------------");
  env.drvr.burst_write(8'h4);  
      env.drvr.burst_write(8'h4);
      
      #100;
  env.drvr.burst_read(8'h4);  
  env.drvr.burst_read(8'h4); 
  
 
  
  #10000;
 

        $display("###############################");
    if(intf_WB.ErrCnt == 0)
        $display("STATUS: SDRAM Write/Read TEST PASSED");
    else
        $display("ERROR:  SDRAM Write/Read TEST FAILED");
        $display("###############################");
  $display("Errorcnt %d Error:",intf_WB.ErrCnt);
    $finish;
    
    end
endprogram*/

class test_basic extends uvm_test;

  `uvm_component_utils(test_basic)
 
  function new (string name="test_basic", uvm_component parent=null);
    super.new (name, parent);
  endfunction : new
    
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  
  environment env;  
  
  virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
      
    env  = environment::type_id::create ("env", this);

    uvm_config_db #(virtual intf_WB_G2)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE_WB", vir_intf_WB);
    uvm_config_db #(virtual intf_SRAM_G2)::set (null, "uvm_test_top.*", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM);
      
  endfunction
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_report_info(get_full_name(),"End_of_elaboration", UVM_LOW);
    print();
    
  endfunction : end_of_elaboration_phase

  sdrm_ctrl_gen_item_seq  seq;
  
  virtual task run_phase(uvm_phase phase);

    phase.raise_objection (this);

    uvm_report_info(get_full_name(),"Init Start", UVM_LOW);
    
    env.SDRAM_ag_active.sdram_drv.reset();
    
    uvm_report_info(get_full_name(),"Init Done", UVM_LOW);
    
    seq = sdrm_ctrl_gen_item_seq::type_id::create("seq");
    
    seq.randomize();
    
    seq.start(env.SDRAM_ag_active.sdram_seqr);
    
    phase.drop_objection (this);
  endtask

endclass


