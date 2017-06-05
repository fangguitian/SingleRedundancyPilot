`timescale 1ns/1ps

module test_top;

  reg clk;
  reg rst_n;
  
  wire [7:0] pwm_out;
  
  reg [15:0] pulse_period      ; 
  
  reg [15:0] pulse_width_ch1   ;
  reg [15:0] pulse_width_ch2   ;
  reg [15:0] pulse_width_ch3   ;
  reg [15:0] pulse_width_ch4   ;
  reg [15:0] pulse_width_ch5   ;
  reg [15:0] pulse_width_ch6 ;
  
  wire  [15:0]  pulse_period_rc;
  
  wire          cpu1_rst_n;

  wire   [9:0]   cpu1_pwm;
  
  reg           cpu1_spi_cs;
  reg           cpu1_spi_sck;
  reg           cpu1_spi_out;
  wire          cpu1_spi_in;

  wire          cpu1_uart1_tx;
  wire          cpu1_uart1_rx;
  wire          cpu1_uart5_tx;
  wire          cpu1_uart5_rx;

  wire          uart3_tx;
  wire          uart3_rx;
  wire          uart4_tx;
  wire          uart4_rx;
		 
  wire          led;
	 
  wire  [3:0]   board_id;
  wire  [7:0]   rsv_io;
        
  
  wire         spi1_miso;
  reg          spi1_mosi;
  reg          spi1_cs_n;
  reg          spi1_clk ; 

  wire         spi_clk_error;
  wire         rx_data_ready;
  wire  [15:0]  rx_data;
  reg          tx_data_ready;
  wire   [15:0]  tx_data;
  
  reg [3:0] spi1_cnt;
  
  
//-------------------------------------------------------------------------------
  
  parameter  SPI_HALF_PERIOD = 125;
  parameter  CLK_HALF_PERIOD = 20.833;

	  
//----------------------------------------------------------------------- 
  initial
    begin
     clk=0;
     rst_n=0;
     spi1_cnt=15;
     
     #10000 rst_n= 16'd1;
      $display("read BOARD_ID");
	    write_spi1(16'hc001);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read PWM_PERIOD");
	    write_spi1(16'hc010);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000);	
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH1");
	    write_spi1(16'h0011);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1500);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read PWM_WIDTH_CH1");
	    write_spi1(16'hc011);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write cpu mode");
	    write_spi1(16'h0005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("read cpu mode");
	    write_spi1(16'hc005);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
    
 	    $display("write PWM_WIDTH_CH2");
	    write_spi1(16'h0012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1520);
	    # (2*SPI_HALF_PERIOD);	    
	    	    
	    $display("read PWM_WIDTH_CH2");
	    write_spi1(16'hc012);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH3");
	    write_spi1(16'h0013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1590);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH3");
	    write_spi1(16'hc013);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH4");
	    write_spi1(16'h0014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1700);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH4");
	    write_spi1(16'hc014);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH5");
	    write_spi1(16'h0015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1200);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH5");
	    write_spi1(16'hc015);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("write PWM_WIDTH_CH6");
	    write_spi1(16'h0fff);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1400);
	    # (2*SPI_HALF_PERIOD);	
	    
	    $display("read PWM_WIDTH_CH6");
	    write_spi1(16'hc016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_period");
	    write_spi1(16'hc009);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH1");
	    write_spi1(16'hc00a);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH2");
	    write_spi1(16'hc00b);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH3");
	    write_spi1(16'hc00c);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH4");
	    write_spi1(16'hc00d);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH5");
	    write_spi1(16'hc00e);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read RC_PWM_WIDTH_CH6");
	    write_spi1(16'hc00f);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
	    
	    $display("write PWM_WIDTH_CH1");
	    write_spi1(16'h0fff);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1300);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("read sonar");
	    write_spi1(16'hc01b);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1000);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu1 write PWM_WIDTH_CH6");
	    write_spi1(16'h0016);
	    # (2*SPI_HALF_PERIOD);
	    write_spi1(16'd1530);
	    # (2*SPI_HALF_PERIOD);
	    
	    $display("cpu1 read PWM_WIDTH_CH6");
	    write_spi1(16'hc016);
	    # (2*SPI_HALF_PERIOD);// high level of spi_cs_n between frames
	    write_spi1(16'h0000); 
	    # (2*SPI_HALF_PERIOD);
	    
   
	   
	    
     #100000000 $stop;

end    
  always #CLK_HALF_PERIOD clk=~clk;


//------------------------------------------------------------------------------- 
 /*   read spi  */

reg [15:0] spi1_data;

always@(posedge spi1_clk)
	if(!rst_n) 
		spi1_cnt <= 4'd15;
  else if(!spi1_cs_n) 
		spi1_cnt <= spi1_cnt - 1;		
	
	
always@(posedge spi1_clk)
	if(!spi1_cs_n) begin
		if(spi1_cnt == 0) begin
			$display("%t, read spi1: data = %d", $time, {spi1_data[15:1], spi1_miso});
			spi1_data[spi1_cnt] <= spi1_miso;			
		end else begin
			spi1_data[spi1_cnt] <= spi1_miso;
		end
	end  
//------------------------------------------------------------------------------- 
task write_spi1;
	input [15:0] data;
	integer i;
	
	begin
		i = 15;            
		spi1_clk = 0;  
		spi1_cs_n = 0; 
		spi1_mosi = data[15];         

		#1000
    repeat(16) 
		   begin
			   spi1_clk = 1;
			   #SPI_HALF_PERIOD spi1_clk = 0;
			   i = i - 1;
			   if(i==-1) 
			      spi1_mosi = 1;
			   else
			   			spi1_mosi = data[i];  
         #SPI_HALF_PERIOD;			
		   end
		 spi1_cs_n = 1; 
	end	 
endtask
 
//-------------------------------------------------------------------------	  
task write_spi1_error;
	input [15:0] data;
	integer i;
	
	begin
		i = 15;            
		spi1_clk = 0;  
		spi1_cs_n = 0; 
		spi1_mosi = data[15];         

		#1000		
    repeat(14) 
		   begin
			   spi1_clk = 1;
			   #SPI_HALF_PERIOD spi1_clk = 0;
			   i = i - 1;
			   if(i==-1) 
			      spi1_mosi = 1;
			   else
			   			spi1_mosi = data[i];
         #SPI_HALF_PERIOD;			
		   end
		 spi1_cs_n = 0; 
  end	 
endtask
//------------------------------------------------------------------------------- 


top  test(
	.clk8M(clk),
	.rst_n(rst_n),
	.cpu1_rst_n(cpu1_rst_n),

	.cpu1_pwm(cpu1_pwm),


	.cpu1_spi_cs(spi1_cs_n),
	.cpu1_spi_sck(spi1_clk),
	.cpu1_spi_out(spi1_mosi),
	.cpu1_spi_in(spi1_miso),
//	.cpu1_gpio(cpu1_gpio),
	.cpu1_uart1_tx(cpu1_uart1_tx),
	.cpu1_uart1_rx(cpu1_uart1_rx),
	.cpu1_uart5_tx(cpu1_uart5_tx),
	.cpu1_uart5_rx(cpu1_uart5_rx),

	.rc_pwm_in(pwm_out[5:0]),
	.pwm_out(pwm_out),

	.uart3_tx(uart3_tx),
	.uart3_rx(uart3_rx),
	.uart4_tx(uart4_tx),
	.uart4_rx(uart4_rx),

	.led(led),

	.board_id(4'b0001),

	.rsv_io(rsv_io),
	
	.cpu1_rx_data(rx_data),
	.cpu1_tx_data(tx_data)
	);
	
	endmodule

