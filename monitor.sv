class SDRAM_monitor extends uvm_monitor;
  `uvm_component_utils (SDRAM_monitor)


   virtual intf_WB_G2 vir_intf_WB;
   virtual intf_SRAM_G2 vir_intf_SRAM;
  
  
  
   bit     enable_check = 0; //Turned OFF by default
   bit     enable_coverage = 0; //Turned OFF by default
  
  uvm_analysis_port #(sdram_ctrl_item)   mon_analysis_port;

   function new (string name, uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);

      // Create an instance of the analysis port
      mon_analysis_port = new ("mon_analysis_port", this);

      // Get virtual interface handle from the configuration DB
           
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
     
     
   endfunction
  

   virtual task run_phase (uvm_phase phase);
      super.run_phase(phase);
   endtask

   virtual function void check_protocol ();
      // Function to check basic protocol specs
   endfunction
endclass

class sdram_monitor_write extends SDRAM_monitor;
  `uvm_component_utils (sdram_monitor_write)

   function new (string name, uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
   endfunction

   virtual task run_phase (uvm_phase phase);
      sdram_ctrl_item  data_obj = sdram_ctrl_item::type_id::create ("data_obj", this);
      forever begin
       
        @ (posedge vir_intf_WB.sys_clk);
	 
        if(vir_intf_WB.wb_stb_i== 1 && vir_intf_WB.wb_cyc_i ==1 && vir_intf_WB.wb_we_i== 1&& vir_intf_WB.wb_ack_o==1) 
       
          begin
        
        	//sb.write(vir_intf_WB.wb_dat_i, vir_intf_WB.wb_addr_i);
        	
            data_obj.data = vir_intf_WB.wb_dat_i;
            data_obj.addr = vir_intf_WB.wb_addr_i;
          	mon_analysis_port.write (data_obj);
            
          end
        
       
      end
   endtask

endclass

class sdram_monitor_rd extends SDRAM_monitor;
  `uvm_component_utils (sdram_monitor_rd)

   function new (string name, uvm_component parent= null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase (uvm_phase phase);
      super.build_phase (phase);
   endfunction

   virtual task run_phase (uvm_phase phase);
      sdram_ctrl_item   data_obj = sdram_ctrl_item::type_id::create ("data_obj", this);
     int i;
      forever begin   
        
        @ (posedge vir_intf_WB.sdram_clk);

        if(vir_intf_SRAM.sdr_ras_n== 1 && vir_intf_SRAM.sdr_cas_n ==0 && vir_intf_SRAM.sdr_we_n== 1) begin
         
          
          data_obj.addr = vir_intf_SRAM.sdr_addr;
             
          /*repeat (3) begin
  			@(posedge vir_intf_WB.sdram_clk);
            $display("Espera ");
		  end*/
          #30        
          data_obj.data = vir_intf_SRAM.Dq;
          mon_analysis_port.write (data_obj);
        end
        
       end
   endtask
          
endclass
