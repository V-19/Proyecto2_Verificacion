//_________Clase item__________///////////////////////////////////
class sdram_ctrl_item extends uvm_sequence_item;

  rand logic [31:0] data;
  rand logic [31:0] addr;
  rand logic [3:0]	bl;
  
  
  //constraints
  constraint distribution_bl {
    bl dist { 2 :=1 , 4 :=1, 8 :=1}; 
  }

  constraint distribution_addr {
    addr dist { [32'h0:32'h63] :=10000000 ,[32'h65:32'hFFFFFDC4] :=1, [32'hFFFFFDC5:32'hFFFFFFFF] :=10000000}; 
  }
//171798691
  
  `uvm_object_utils_begin(sdram_ctrl_item)
    `uvm_field_int (data, UVM_DEFAULT)
  	`uvm_field_int (addr, UVM_DEFAULT)
  	`uvm_field_int (bl, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "sdram_ctrl_item");
    super.new(name);
  endfunction
endclass



//_________Clase sequence__________///////////////////////////////////
class sdrm_ctrl_gen_item_seq extends uvm_sequence;
  `uvm_object_utils(sdrm_ctrl_gen_item_seq)
  function new(string name="sdrm_ctrl_gen_item_seq");
    super.new(name);
  endfunction

  rand int num; 	

  constraint c1 { num inside {[20:30]}; } 

  virtual task body();
    sdram_ctrl_item  sdr_ctrl_item_1 = sdram_ctrl_item::type_id::create("sdram_ctrl_item");
    
    for (int i = 0; i < num; i ++) begin
      start_item(sdr_ctrl_item_1);
      sdr_ctrl_item_1.randomize();
      `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW) 
      sdr_ctrl_item_1.print();
      finish_item(sdr_ctrl_item_1);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass



//_________Clase Driver__________/////////////////////////////////
class sdr_ctrl_driver extends uvm_driver #(sdram_ctrl_item);

  `uvm_component_utils (sdr_ctrl_driver)
  
  
  function new (string name = "sdr_ctrl_driver", uvm_component parent = null);
     super.new (name, parent);   
  endfunction
  
  
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    if(uvm_config_db #(virtual intf_WB_G2)::get(this, "", "VIRTUAL_INTERFACE_WB", vir_intf_WB) == 0) begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
    
    if(uvm_config_db #(virtual intf_SRAM_G2)::get(this, "", "VIRTUAL_INTERFACE_SRAM", vir_intf_SRAM) == 0) 		begin
        `uvm_fatal("INTERFACE_CONNECT", "Could not get from the database the virtual interface for the TB")
      end
  endfunction
  
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      sdram_ctrl_item  sdram_ctrl_item_1;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_LOW)
      seq_item_port.get_next_item(sdram_ctrl_item_1);
       burst_write(sdram_ctrl_item_1);   
      burst_read(sdram_ctrl_item_1);
      seq_item_port.item_done();
    end
  endtask  



    virtual task burst_write(sdram_ctrl_item sdram_ctrl_item_1);
    int i;
      
    begin
      @ (negedge vir_intf_WB.sys_clk)      
      
      for(i=0; i < sdram_ctrl_item_1.bl; i++) begin
        vir_intf_WB.wb_stb_i        = 1;
        vir_intf_WB.wb_cyc_i        = 1;
        vir_intf_WB.wb_we_i         = 1;
        vir_intf_WB.wb_sel_i        = 4'b1111;
        vir_intf_WB.wb_addr_i       = {sdram_ctrl_item_1.addr[31:2]+i,2'b00};
        vir_intf_WB.wb_dat_i = {sdram_ctrl_item_1.data[31:2]+i,2'b00}; 
        
        do begin
          @ (posedge vir_intf_WB.sys_clk);
        end while(vir_intf_WB.wb_ack_o == 1'b0);
        @ (negedge vir_intf_WB.sys_clk);
      end
      
      vir_intf_WB.wb_stb_i        = 0;
      vir_intf_WB.wb_cyc_i        = 0;
      vir_intf_WB.wb_we_i         = 'hx;
      vir_intf_WB.wb_sel_i        = 'hx;
      vir_intf_WB.wb_addr_i       = 'hx;
      vir_intf_WB.wb_dat_i        = 'hx;
    end
  endtask

  
   
  virtual task burst_read(sdram_ctrl_item sdram_ctrl_item_1);
    int j;
    begin      
      @ (negedge vir_intf_WB.sys_clk);
      for(j=0; j < sdram_ctrl_item_1.bl; j++) begin
        vir_intf_WB.wb_stb_i        = 1;
        vir_intf_WB.wb_cyc_i        = 1;
        vir_intf_WB.wb_we_i         = 0;
        vir_intf_WB.wb_addr_i       = {sdram_ctrl_item_1.addr[31:2]+j,2'b00};

        do begin
          @ (posedge vir_intf_WB.sys_clk);
        end while(vir_intf_WB.wb_ack_o == 1'b0);
        
        @ (negedge vir_intf_WB.sdram_clk);
      end
      vir_intf_WB.wb_stb_i        = 0;
      vir_intf_WB.wb_cyc_i        = 0;
      vir_intf_WB.wb_we_i         = 'hx;
      vir_intf_WB.wb_addr_i       = 'hx;
    end
  endtask
  
  
  
 virtual task reset();  
    $display("Executing Reset\n");
    vir_intf_WB.ErrCnt         = 0;
    vir_intf_WB.wb_addr_i      = 0;
    vir_intf_WB.wb_dat_i       = 0;
    vir_intf_WB.wb_sel_i       = 4'h0;
    vir_intf_WB.wb_we_i        = 0;
    vir_intf_WB.wb_stb_i       = 0;
    vir_intf_WB.wb_cyc_i       = 0;
  	vir_intf_WB.RESETN         = 1'h1;
 	#100
  	// Applying reset
  	vir_intf_WB.RESETN         = 1'h0;
  	#10000;
  	// Releasing reset
  	vir_intf_WB.RESETN         = 1'h1;
   #1000;
    wait(vir_intf_WB.sdr_init_done == 1);
   #1000;
   
  endtask
        
  
  
endclass



///////////////////////////////////////////////////////////////////////
//  Inicio version sin UVM
///////////////////////////////////////////////////////////////////////
/*
class driver;
  
  stimulus sti;
  scoreboard sb;
  
  virtual intf_WB_G2 vir_intf_WB;
  virtual intf_SRAM_G2 vir_intf_SRAM;
  
  function new(virtual intf_WB_G2 vir_intf_WB,virtual intf_SRAM_G2 vir_intf_SRAM ,scoreboard sb);
    this.vir_intf_WB = vir_intf_WB;
    this.vir_intf_SRAM=vir_intf_SRAM;
    this.sb = sb;
  endfunction
  
  
  
  task reset();  
    
    vir_intf_WB.ErrCnt          = 0;
    vir_intf_WB.wb_addr_i      = 0;
    vir_intf_WB.wb_dat_i      = 0;
    vir_intf_WB.wb_sel_i       = 4'h0;
    vir_intf_WB.wb_we_i        = 0;
    vir_intf_WB.wb_stb_i       = 0;
    vir_intf_WB.wb_cyc_i       = 0;

  	vir_intf_WB.RESETN    = 1'h1;

 	#100
  	// Applying reset
  	vir_intf_WB.RESETN    = 1'h0;
  	#10000;
  	// Releasing reset
  	vir_intf_WB.RESETN    = 1'h1;
  endtask
        
  
  task burst_write;
	//input [31:0] Address;
	input [7:0]  bl;
    reg [31:0] address;
	int i;
	begin
      
  	
      sti = new();
      	
      vir_intf_WB.burst=bl;
      
        sb.bfifo.push_back(bl); 

        if(sti.randomize()) 
        address = sti.value2; // Drive to DUT
            
		sb.afifo.push_back(address);
      
     	@ (negedge vir_intf_WB.sys_clk)
     
      //$display("Write Address: %x, Burst Size: %d",address,vir_intf_WB.burst);  
      
      for(i=0; i < bl; i++) begin
      vir_intf_WB.wb_stb_i        = 1;
      vir_intf_WB.wb_cyc_i        = 1;
      vir_intf_WB.wb_we_i         = 1;
      vir_intf_WB.wb_sel_i        = 4'b1111;
      vir_intf_WB.wb_addr_i       = {address[31:2]+i,2'b00};
      if(sti.randomize()) 
        vir_intf_WB.wb_dat_i = sti.value; // Drive to DUT
	
      do begin
          @ (posedge vir_intf_WB.sys_clk);
      end while(vir_intf_WB.wb_ack_o == 1'b0);
          @ (negedge vir_intf_WB.sys_clk);
   		$display("Status: Burst-No: %d  Write Address: %x  WriteData: %x ",i,vir_intf_WB.wb_addr_i,vir_intf_WB.wb_dat_i);
   end
      
   	 vir_intf_WB.wb_stb_i        = 0;
   	 vir_intf_WB.wb_cyc_i        = 0;
     vir_intf_WB.wb_we_i         = 'hx;
     vir_intf_WB.wb_sel_i        = 'hx;
     vir_intf_WB.wb_addr_i       = 'hx;
     vir_intf_WB.wb_dat_i        = 'hx;

end
   
endtask


  
  task burst_read;
    // reg [7:0]  bl;
    reg [31:0] address;
	int j;
	input [7:0]  bl;
    
    
	begin
      
        
      	//bl      = sb.bfifo.pop_front(); 
   		address = sb.afifo.pop_front(); 
        //vir_intf_WB.burst      =  sb.bfifo.pop_front(); //p
      
   		@ (negedge vir_intf_WB.sys_clk);
      
       for(j=0; j < bl; j++) begin
         vir_intf_WB.wb_stb_i        = 1;
         vir_intf_WB.wb_cyc_i        = 1;
         vir_intf_WB.wb_we_i         = 0;
         vir_intf_WB.wb_addr_i       = {address[31:2]+j,2'b00};
         
         do begin
             @ (posedge vir_intf_WB.sys_clk);
         end while(vir_intf_WB.wb_ack_o == 1'b0);
         
         //$display("Address: %d Addr:",vir_intf_WB.wb_addr_i);
         
         @ (negedge vir_intf_WB.sdram_clk);
          //vir_intf_WB.address =  sb.afifo.pop_front(); //p 
       end
          //vir_intf_WB.exp_data        = sb.dfifo.pop_front();//p // Exptected Read Data
      vir_intf_WB.wb_stb_i        = 0;
   	  vir_intf_WB.wb_cyc_i        = 0;
      vir_intf_WB.wb_we_i         = 'hx;
      vir_intf_WB.wb_addr_i       = 'hx;
    
 
      end
  
endtask
endclass

*/


///////////////////////////////////////////////////////////////////////
//  Fin version sin UVM
///////////////////////////////////////////////////////////////////////
