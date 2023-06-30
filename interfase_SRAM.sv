interface intf_SRAM_G2();
  
	
  
  	parameter APP_AW   = 26;  // Application Address Width
  	parameter APP_DW   = 32;  // Application Data Width 
  	parameter APP_BW   = 4;   // Application Byte Width
  	parameter APP_RW   = 9;   // Application Request Width
	parameter SDR_DW   = 16;  // SDR Data Width 
	parameter SDR_BW   = 2;   // SDR Byte Width
	parameter dw  = 32;  // data width
	parameter tw  = 8;   // tag id width
	parameter bl  = 9;   // burst_lenght_width 
  
  	logic sdr_cke; // SDRAM CKE
	logic sdr_cs_n; // SDRAM Chip Select
	logic sdr_ras_n; // SDRAM ras
	logic sdr_cas_n; // SDRAM cas
	logic sdr_we_n; // SDRAM write enable
	logic [SDR_BW-1:0] 	sdr_dqm; // SDRAM Data Mask
	logic [1:0] 		sdr_ba; // SDRAM Bank Enable
	logic [12:0] 		sdr_addr; // SDRAM Address
	logic [SDR_DW-1:0] 	sdr_dq; // SDRA Data Input/output
 	//logic [SDR_DW-1:0] 	Dq; // SDRA Data Input/output
  
  //	`ifdef SDR_32BIT
  	wire [31:0]           Dq                 ; // SDRAM Read/Write Data Bus
 	wire [3:0]            sdr_dqm            ; // SDRAM DATA Mask
	/*`elsif SDR_16BIT 
  	wire [15:0]         Dq                  ; // SDRAM Read/Write Data Bus
  	wire [1:0]           sdr_dqm            ; // SDRAM DATA Mask
	`else 
  	wire [7:0]          Dq                ; // SDRAM Read/Write Data Bus
 	wire [0:0]          sdr_dqm            ; // SDRAM DATA Mask
	`endif
  
  
  */
endinterface