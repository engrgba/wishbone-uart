`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:08:31 05/24/2024 
// Design Name: 
// Module Name:    Wishbone_Controller 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Wishbone_Controller(
        input wire  i_clk,
        input wire  i_rst,
		  input wire  push_button,
		  input wire i_uart_rx,
//wishbone signals
       // input wire          i_wb_ack,
        //input wire          i_wb_stall,
        //input wire  [31:0]  i_wb_data,

        output reg         o_wb_we,
        output reg         o_wb_cyc,
        output reg         o_wb_stb,
		  output reg  [3:0]  o_wb_sel,
        output reg  [1:0]  o_wb_addr,
        output reg  [31:0] o_wb_data ,
		  output	wire		   o_uart_tx
        );
localparam [31:0] tx_byte = {24'd0, "f"};

wire 		   i_wb_ack;
wire [31:0] i_wb_data;

reg setup = 1'b0;
reg [10:0]t_a_time = 11'd0;  
  wbuart wbu(
						.i_clk(i_clk),
						.i_reset(1'b0),
						.o_wb_ack(i_wb_ack),
						//.o_wb_stall(i_wb_stall),
						.o_wb_data(i_wb_data), 
						.i_wb_we(o_wb_we),
						.i_wb_cyc(o_wb_cyc),
						.i_wb_stb(o_wb_stb),
						.i_wb_sel(o_wb_sel),
						.i_wb_addr(o_wb_addr),
						.i_wb_data(o_wb_data),
						.o_uart_tx(o_uart_tx)
						);

wire [35:0]CONTROL0;
						

						
localparam IDLE        			 	= 3'd0,
			  UART_SETUP   			= 3'd1,
			  UART_TX               = 3'd2,
			  Turn_Around_time      = 3'd3,
			  Ack          			= 3'd4;
		
reg [2:0]state = 3'b000;
        always@(posedge i_clk)
        begin
        
       
		 case(state) 
		 IDLE: //0
						begin
							 o_wb_we    <= 1'b0; //read state
                      o_wb_stb   <= 1'b0;
                      o_wb_addr  <= 2'b00;
                      o_wb_cyc   <= 1'b0;
                      o_wb_data  <= 32'd0;
							 if(!push_button && !setup)
							 begin
									state      <= UART_SETUP;
									o_wb_we    <= 1'b1;
									o_wb_stb   <= 1'b1;
                           o_wb_cyc   <= 1'b1;
									o_wb_addr  <= 2'b00;
									o_wb_data  <= 32'd434;
							 end
							 else if(!push_button && setup)
							 begin
									state      <= UART_TX;
									o_wb_we    <= 1'b1;
									o_wb_stb   <= 1'b1;
                           o_wb_cyc   <= 1'b1;
									o_wb_addr  <= 2'b11; 
									o_wb_data  <= tx_byte;
							 end
							 else state      <= IDLE;
						end
		 UART_SETUP://1
						begin
							 if(i_wb_ack)
							 begin
									o_wb_we    <= 1'b0;
									setup      <= 1'b1;
									o_wb_stb   <= 1'b0;
									o_wb_cyc   <= 1'b0;
									o_wb_addr  <= 2'b00;
									o_wb_data  <= 32'h00;
									state      <= Turn_Around_time;
							 end
								
							else state <= UART_SETUP;
						end

		UART_TX://2
						begin
							 o_wb_we    <= 1'b1;
                      o_wb_stb   <= 1'b1;
                      o_wb_cyc   <= 1'b1;
                      o_wb_addr  <= 2'b11;
                      o_wb_data  <= tx_byte;
							 o_wb_sel   <= 4'b1111;
							 state      <= Ack;
							 t_a_time   <= 11'd0;
						end
		Turn_Around_time://3
						begin
							if(t_a_time == 1500)
								begin
									 state    <= IDLE;
									 t_a_time <= 11'd0;
								end
							else   t_a_time <= t_a_time+1;
						end
		Ack://4
						begin
							 if(i_wb_ack)  
								begin
									state        <= Turn_Around_time;
							      o_wb_we      <= 1'b0;
									o_wb_cyc     <= 1'b0;
									o_wb_stb     <= 1'b0;
									o_wb_cyc     <= 1'b0;
									o_wb_addr    <= 2'b0;
									o_wb_data    <= 32'd0;
								end
							 else 
								state <= Ack;
						end
						
				default: state <= IDLE;
			endcase
		 
end 

wire [255:0]DATA;
ILA ila (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(i_clk), // IN
    .DATA(DATA), // IN BUS [255:0]
    .TRIG0({o_uart_tx, o_wb_stb, push_button} ) // IN BUS [7:0]
);
control cntrl (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
);


		assign DATA[1]     =  i_rst;
		assign DATA[2]     =  push_button;
		assign DATA[3]     =  i_wb_ack;
		assign DATA[4]     =  o_wb_stb;
		assign DATA[7:5]   =  state;
		assign DATA[39:8]  =  o_wb_data;
		assign DATA[41:40] =  o_wb_addr;
		assign DATA[73:42] =  i_wb_data;
		assign DATA[74]    =  o_wb_we;
		assign DATA[75]    =  o_wb_cyc;
		assign DATA[76]    =  o_uart_tx;
		assign DATA[80:77] =  o_wb_sel;
		
  endmodule


//reset fn khatam
//state machine should run on push button 
//add uart delay of 30us after every transaction

