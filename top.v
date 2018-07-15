module router_top(input clk,reset,pkt_valid, input [7:0]datain,input read_enb_0,read_enb_1,read_enb_2,output [7:0] dataout_0,dataout_1,dataout_2,output vld_out_0,vld_out_1,vld_out_2,err,busy);

wire [2:0]write_enb;
wire [7:0]dataout;

router_fifo FIFO1(clk,reset,soft_reset_0,write_enb[0],read_enb_0,lfd_state,dataout,full_0,empty_0,dataout_0);

router_fifo FIFO2(clk,reset,soft_reset_1,write_enb[1],read_enb_1,lfd_state,dataout,full_1,empty_1,dataout_1);

router_fifo FIFO3(clk,reset,soft_reset_2,write_enb[2],read_enb_2,lfd_state,dataout,full_2,empty_2,dataout_2);

router_sync SYNC( clk,reset,detect_add,write_enb_reg,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2,datain[1:0],write_enb,fifo_full,vld_out_0,vld_out_1,vld_out_2,soft_reset_0,soft_reset_1,soft_reset_2);

router_fsm FSM(clk,reset,pkt_valid,datain[1:0],fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done,write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy,low_packet_valid);

router_reg REGISTER(clk,reset,pkt_valid,datain,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,parity_done,low_packet_valid,dataout);



endmodule
