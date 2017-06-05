`timescale 1ns/100ps



module top
(
    input  wire          clk8M,
    input  wire          rst_n,

    output wire          cpu1_rst_n,
    //input  wire  [9:0]   cpu1_pwm,

    input  wire          cpu1_spi_cs,
    input  wire          cpu1_spi_sck,
    input  wire          cpu1_spi_out,
    output wire          cpu1_spi_in,

    input  wire          cpu1_uart1_tx,
    output wire          cpu1_uart1_rx,
    input  wire          cpu1_uart5_tx,
    output wire          cpu1_uart5_rx,
	 
	 output wire          uart3_tx,
    input  wire          uart3_rx,
    output wire          uart4_tx,
    input  wire          uart4_rx,
		 
    input  wire  [5:0]   rc_pwm_in,
    output wire  [7:0]   pwm_out,
		 
    output wire          led,

	 input  wire  [3:0]   board_id
	 
	 //inout  wire  [4:0]   rsv_io

	);
	

	wire clk_in;
	wire [15:0]   cpu1_pwm_width_ch1;
	wire [15:0]   cpu1_pwm_width_ch2;
	wire [15:0]   cpu1_pwm_width_ch3;
	wire [15:0]   cpu1_pwm_width_ch4;
	wire [15:0]   cpu1_pwm_width_ch5;
	wire [15:0]   cpu1_pwm_width_ch6;
	wire [15:0]   cpu1_pwm_width_ch7;
	wire [15:0]   cpu1_pwm_width_ch8;
	
	wire [15:0]   cpu1_pwm_period;
	//wire [15:0]   cpu1_pwm_period7;	
	//wire [15:0]   cpu1_pwm_period8;
	
	wire [15:0]   cpu1_tx_data;
	wire [15:0]   cpu1_rx_data;
	wire          cpu1_tx_data_ready;
	wire          cpu1_rx_data_ready;
	
	wire          cpu1_spi_frame_lost_error;	
	wire          cpu1_spi_clk_error;
	
	//wire [1:0]    cpu1_sonar_control;
 
	wire          cpu1_watch_dog_pulse;
	wire [3:0]    cpu1_reg_cpu_mode;
	
	wire [15:0]   cpu1_reg_ctrl;

	wire [3:0]    reg_cpu_mode;
	
   //wire [1:0]    sonar_control;
   //wire [15:0]   sonar_data;
	
	wire [14:0]   rc_pulse_width_ch1;
	wire [14:0]   rc_pulse_width_ch2;
	wire [14:0]   rc_pulse_width_ch3;
	wire [14:0]   rc_pulse_width_ch4;
	wire [14:0]   rc_pulse_width_ch5;
	wire [14:0]   rc_pulse_width_ch6;
	wire [14:0]   rc_pulse_period;
   
	wire [7:0]    pwm_out_auto;
	wire          pwm_update_pulse;
	
 //-------------------------------------------------------------------------------------------------------------
   wire [31:0]   version;//
 //-------------------------------------------------------------------------------------------------------------
   //parameter             DOG_HUNGRY_TIME = 7'd70  ;      // time(ms) that watch_dog_pulse did not show up
	parameter             FRE_DIV         = 8'd24  ;      // PWM CLK = clk/fre_div; 1MHz default)
 //-------------------------------------------------------------------------------------------------------------
   reg [1:0]   rst_n_buf;
	always @ (posedge clk_in)
	  rst_n_buf <= {rst_n_buf[0],rst_n};
 //-------------------------------------------------------------------------------------------------------------
                     /*  generate 1MHz  PWM sampling Clock  */
  reg          pwm_clk      ;
  reg  [1:0]   pwm_clk_delay; 
  reg  [7:0]   fre_divider  ;
  
  always @ (posedge clk_in or negedge rst_n_buf[1]) 
   begin
        if(!rst_n_buf[1])
		     fre_divider <= 8'd0;
		  else begin
		        if(fre_divider == 8'd0)
				     begin
			          fre_divider <= FRE_DIV - 8'd1;
			        end
			     else begin
			            fre_divider <= fre_divider - 8'd1;
			          end
		       end  
   end
	/* pwm_clk is used as reference time for CPU Failure switch */
	always @(posedge clk_in or negedge rst_n_buf[1])
	  begin
	       if(!rst_n_buf[1])
			     pwm_clk       <= 1'd0;
			 else 
			     begin
			       if(fre_divider == FRE_DIV - 8'd1)
			         pwm_clk <= 1'd1;
					 else 
					   pwm_clk <= 1'd0;
					end						
	  end 
    /* 2 clk_in cycle delay of pwm_clk,used to sample PWM signal,
	     and update servo PWM width  ,so that PWM width is updated right after CPU Failure switch */ 
 	always @(posedge clk_in)
	       if(!rst_n_buf[1])
			     pwm_clk_delay <= 2'd0;
			 else 
			     pwm_clk_delay <= {pwm_clk_delay[0],pwm_clk};					
 //-------------------------------------------------------------------------------------------------------------
                      /*  1ms global referenc time  */
  reg  [9:0]   timer_1ms;
  wire         ref_clk_1ms;
  
  always @ (posedge clk_in or negedge rst_n_buf[1]) 
   begin
        if(!rst_n_buf[1])
		     timer_1ms <= 10'd999;
		  else begin
		        if((pwm_clk) && (timer_1ms == 10'd0))
                 timer_1ms <= 10'd999;
			     else if(pwm_clk)
			            timer_1ms <= timer_1ms - 8'd1;
		       end  
   end
   assign  ref_clk_1ms = pwm_clk && (timer_1ms == 10'd0);
 //-------------------------------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------------------------------
/*reg [1:0] cpu1_pwm_update;
//reg [1:0] cpu2_pwm_update;

   always @ (posedge clk_in or negedge rst_n_buf[1])
	   if(!rst_n_buf[1])
		   begin
			   cpu1_pwm_update <= 2'b0;
			//	cpu2_pwm_update <= 2'b0;
		   end
		else
			begin
			// everytime after cpu1 and cpu2 writes pwm data to the FPGA
			// a high pulse is sent out to the cpu1_pwm[0] and cpu2_pwm[0]
			// so this pulse can be used as watch dog moniter pulse
			   cpu1_pwm_update <= {cpu1_pwm_update[0],cpu1_pwm[0]};
		   end	  */ 
//---------------------------------------------------------------------------------------------------------------

	  assign cpu1_rst_n = 1'b1;
//---------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------
	assign pwm_out= pwm_out_auto;
	//assign pwm_out[8]=pwm_out[0];
	//assign pwm_out[9]=pwm_out[1];
//---------------------------------------------------------------------------------------------------------------
   /* CPU Failure switch */
   reg [14:0]   pwm_width_ch1;
	reg [14:0]   pwm_width_ch2;
	reg [14:0]   pwm_width_ch3;
	reg [14:0]   pwm_width_ch4;
	reg [14:0]   pwm_width_ch5;
	reg [14:0]   pwm_width_ch6;
	reg [14:0]   pwm_period;
	
	//reg [14:0]   pwm_period7;
	//reg [14:0]   pwm_period8;
	
   reg [14:0]   pwm_width_ch7;
	reg [14:0]   pwm_width_ch8;
	
	always @ (posedge clk_in)
        begin
		   pwm_width_ch1 <= cpu1_pwm_width_ch1[14:0];
			pwm_width_ch2 <= cpu1_pwm_width_ch2[14:0];
			pwm_width_ch3 <= cpu1_pwm_width_ch3[14:0];
			pwm_width_ch4 <= cpu1_pwm_width_ch4[14:0];
			pwm_width_ch5 <= cpu1_pwm_width_ch5[14:0];
			pwm_width_ch6 <= cpu1_pwm_width_ch6[14:0];
			pwm_period    <= cpu1_pwm_period[14:0];
			pwm_width_ch7 <= cpu1_pwm_width_ch7[14:0];
			//pwm_period7   <= cpu1_pwm_period7[14:0];
			pwm_width_ch8 <= cpu1_pwm_width_ch8[14:0];
			//pwm_period8   <= cpu1_pwm_period8[14:0];
		 end
	
		
	assign pwm_update_pulse = cpu1_watch_dog_pulse ;
	

	assign uart4_tx      = cpu1_uart1_tx  ;
	assign uart3_tx      = cpu1_uart5_tx  ;
	
	assign cpu1_uart1_rx = uart4_rx;
	assign cpu1_uart5_rx = uart3_rx;

	

//-----------------------------for debug ------------------------------------------------------------------------------	
/*	assign rsv_io[0] = cpu1_spi_cs;
	assign rsv_io[1] = cpu1_spi_sck;
	assign rsv_io[2] = cpu1_spi_in;
	assign rsv_io[3] = cpu1_spi_out;	
	assign rsv_io[4] = cpu1_spi_frame_lost_error|cpu1_spi_clk_error;*/
//---------------------------------------------------------------------------------------------------------------
   /* cpld local time */
	reg  [15:0] cpld_local_time ;
	
	always @ (posedge clk_in or negedge rst_n_buf[1])
	  if(!rst_n_buf[1])
	    cpld_local_time <= 16'd0;
	  else if(ref_clk_1ms)
	    cpld_local_time <= cpld_local_time + 16'd1;
//---------------------------------------------------------------------------------------------------------------
   /*   LED  indication   */
	assign led        = (cpld_local_time[9:0] < 10'd127) ? 1'b1 : 1'b0;


//---------------------------------------------------------------------------------------------------------------
    /* CPU1 register read/write */
 spi_slave_reg  spi_reg_cpu1(
                                   .clk  (clk_in),
                                   .rst_n(rst_n_buf[1]),
  
                                   .rx_data_ready(cpu1_rx_data_ready),
                                   .rx_data      (cpu1_rx_data), 
                                   .tx_data_ready(cpu1_tx_data_ready),
                                   .tx_data      (cpu1_tx_data),
											  
                                   .board_id(board_id),
											  .reg_control(cpu1_reg_ctrl),

                                   .reg_cpu_mode(cpu1_reg_cpu_mode), // CPU mode indication 
  
                                   .reg_rc_period({1'b0,rc_pulse_period})       ,//Remote controller Pulse period 
                                   .reg_rc_pwidth_ch1({1'b0,rc_pulse_width_ch1}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch2({1'b0,rc_pulse_width_ch2}),// Remote controller pulse width  
                                   .reg_rc_pwidth_ch3({1'b0,rc_pulse_width_ch3}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch4({1'b0,rc_pulse_width_ch4}),// Remote controller pulse width
                                   .reg_rc_pwidth_ch5({1'b0,rc_pulse_width_ch5}),// Remote controller pulse width 
                                   .reg_rc_pwidth_ch6({1'b0,rc_pulse_width_ch6}),// Remote controller pulse width 
				  
                                   .reg_pwm_period   (cpu1_pwm_period)   ,// servo PWM signal period
                                   .reg_pwm_width_ch1(cpu1_pwm_width_ch1),// servo PWM signal pulse width for channel1
                                   .reg_pwm_width_ch2(cpu1_pwm_width_ch2),// servo PWM signal pulse width for channel2
                                   .reg_pwm_width_ch3(cpu1_pwm_width_ch3),// servo PWM signal pulse width for channel3
                                   .reg_pwm_width_ch4(cpu1_pwm_width_ch4),// servo PWM signal pulse width for channel4
                                   .reg_pwm_width_ch5(cpu1_pwm_width_ch5),// servo PWM signal pulse width for channel5
                                   .reg_pwm_width_ch6(cpu1_pwm_width_ch6),// servo PWM signal pulse width for channel6
				  
                                   .reg_sonar_control(),// Sonar enable or stop,default enable
                                   .reg_sonar_data   ()   ,// Sonar data 
                                   .frame_lost_error (cpu1_spi_frame_lost_error),// data frame lost,high level pulse
											  .watch_dog_pulse(cpu1_watch_dog_pulse),
											  
											  .reg_pwm_period7(),
											  .reg_pwm_width_ch7(cpu1_pwm_width_ch7),
											  .reg_pwm_period8(),
											  .reg_pwm_width_ch8(cpu1_pwm_width_ch8),
											  .spi_clk_error(cpu1_spi_clk_error),
											  .version(version)
                                  );
//---------------------------------------------------------------------------------------------------------------	 

//---------------------------------------------------------------------------------------------------------------	 
     /* CPU1 SPI transceiver slave  */
  spi_slave_transceiver  spi_xver1(
                                  .clk           (clk_in   ),
                                  .rst_n         (rst_n_buf[1]   ),
										    .spi_mosi      (cpu1_spi_out),     
                                  .spi_cs_n      (cpu1_spi_cs),     
                                  .spi_clk       (cpu1_spi_sck ),     
                                  .spi_miso      (cpu1_spi_in),     
                                  .spi_clk_error (cpu1_spi_clk_error),
                                  .rx_data_ready (cpu1_rx_data_ready),
                                  .rx_data       (cpu1_rx_data),
                                  .tx_data_ready (cpu1_tx_data_ready),
                                  .tx_data       (cpu1_tx_data)
                                  );  
  

//--------------------------------------------------------------------------------------------------------------- 

//--------------------------------------------------------------------------------------------------------------- 
	/* generate servo pwm pulse  */
	pwm_gen_servo pwm_gen_cpu(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
                         .pulse_period(pwm_period)         ,  
                         .pulse_width_ch1(pwm_width_ch1)   ,  
                         .pulse_width_ch2(pwm_width_ch2)   ,
                         .pulse_width_ch3(pwm_width_ch3)   ,
                         .pulse_width_ch4(pwm_width_ch4)   ,
                         .pulse_width_ch5(pwm_width_ch5)   ,
                         .pulse_width_ch6(pwm_width_ch6)   , 
								 .pulse_width_ch7(pwm_width_ch7)   ,
                         .pulse_width_ch8(pwm_width_ch8)   , 
								 .data_update_flag(pwm_update_pulse),
                         .pwm_out        (pwm_out_auto)   
                        );

//---------------------------------------------------------------------------------------------------------------									
   /* caputre pwm width of remote controller */
	pwm_cap_rc pwm_cap(
                         .clk(clk_in)                 ,  
                         .rst_n(rst_n_buf[1])                , 
								 .pwm_clk(pwm_clk_delay[1])   ,
								 .pwm_in         (rc_pwm_in)  ,
                      //   .rc_en_in(rc_en_processed)         ,  
                         .pulse_width_ch1(rc_pulse_width_ch1)   ,  
                         .pulse_width_ch2(rc_pulse_width_ch2)   ,
                         .pulse_width_ch3(rc_pulse_width_ch3)   ,
                         .pulse_width_ch4(rc_pulse_width_ch4)   ,
                         .pulse_width_ch5(rc_pulse_width_ch5)   ,
                         .pulse_width_ch6(rc_pulse_width_ch6)   ,
								 .pulse_period   (rc_pulse_period)      
                          
                        );
//---------------------------------------------------------------------------------------------------------------	

//---------------------------------------------------------------------------------------------------------------	

version_reg ver(
                    .clock(clk_in),
						  .reset(rst_n_buf[1]),
						  .data_out(version)
						  );
						  
PLL8M    pll8Min(
	              .inclk0  (clk8M), 
					  .c0      (clk_in)
	
	              );
					
endmodule