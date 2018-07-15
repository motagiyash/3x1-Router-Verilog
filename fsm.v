module router_fsm(input clk,reset,pkt_valid,input [1:0] datain,input fifo_full,fifo_empty_0,fifo_empty_1,fifo_empty_2,soft_reset_0,soft_reset_1,soft_reset_2,parity_done, output write_enb_reg,detect_add,ld_state,laf_state,lfd_state,full_state,rst_int_reg,busy, input low_packet_valid);

parameter       decode_address=8'b00000001,
		wait_till_empty=8'b00000010,
		load_first_data=8'b00000100,
		load_data=8'b00001000,
		load_parity=8'b00010000,
		fifo_full_state=8'b00100000,
		load_after_full=8'b01000000,
		check_parity_error=8'b10000000;

reg [7:0] present_state,next_state;
reg [1:0]temp;

always@(posedge clk)
	begin
		if(~reset)
				present_state<=decode_address;
		else if (((soft_reset_0) && (temp==2'b00)) || ((soft_reset_1) && (temp==2'b01)) || ((soft_reset_2) && (temp==2'b10)))
				 
				present_state<=decode_address;

		else
				present_state<=next_state;
			
	end
		

//temp logic
always@(posedge clk)
	begin
		if(~reset)
			temp<=2'd0;
		else if(detect_add)
		 	temp<=datain[1:0];
	end
	

//state-decode_address
always@(*)
	begin
		case(present_state)
		decode_address:
		begin
			if((pkt_valid && (datain[1:0]==0) && fifo_empty_0)|| (pkt_valid && (datain[1:0]==1) && fifo_empty_1)|| (pkt_valid && (datain[1:0]==2) && fifo_empty_2))

					next_state=load_first_data;

			else if((pkt_valid && (datain[1:0]==0) && ~fifo_empty_0)||(pkt_valid && (datain[1:0]==1) && ~fifo_empty_1)||(pkt_valid && (datain[1:0]==2) && ~fifo_empty_2))
					next_state=wait_till_empty;
				
			else 
				next_state=decode_address;	
		end


		load_first_data:next_state=load_data;
		
		load_data:
			begin

				if(fifo_full==1'b1) 
					next_state=fifo_full_state;
				else 
					begin
						if (~fifo_full && ~pkt_valid)
							next_state=load_parity;
						else
							next_state=load_data;
					end
			end


		fifo_full_state:
			begin
				if(fifo_full==0)
					next_state=load_after_full;
				else 
					next_state=fifo_full_state;
			end

		wait_till_empty:
			begin

				if((fifo_empty_0 && (temp==2'b00))||(fifo_empty_1 && (temp==2'b01))||(fifo_empty_2 && (temp==2'b10)))
					next_state=load_first_data;
	
				else
					next_state=wait_till_empty;
			end

		load_after_full:
			begin

				if(~parity_done && low_packet_valid)
					next_state=load_parity;
				else if(~parity_done && ~low_packet_valid)
					next_state=load_data;
	
				else 
					begin 
						if(parity_done==1'b1)
							next_state=decode_address;
						else
							next_state=load_after_full;
					end
				
			end

		
		load_parity:
			begin
				next_state=check_parity_error;
			end


		check_parity_error:
			begin
				if(~fifo_full)
					next_state=decode_address;
				else
					next_state=fifo_full_state;
			end

		default next_state=decode_address; 

		endcase
	end

/*output Logic
always@(*)
	begin
		case(present_state)
			decode_address:begin
					detect_add=1'b1;end
			load_first_data:begin
					busy=1'b1;lfd_state=1'b1;end
			load_data:begin
					ld_state=1'b1;busy=1'b0;write_enb_reg=1'b1;end
			load_parity:begin
					busy=1'b1;write_enb_reg=1'b1;end
			fifo_full_state:begin
					full_state=1'b1;busy=1'b1;write_enb_reg=1'b0;end
			load_after_full:begin
					laf_state=1'b1;busy=1'b1;write_enb_reg=1'b1;end
			wait_till_empty:begin
					busy=1'b1;write_enb_reg=1'b0;end
			check_parity_error:begin
					busy=1'b1;end
		endcase
	end*/

assign busy=(present_state==load_first_data)||(present_state==load_parity)||(present_state==fifo_full_state)||(present_state==load_after_full)||(present_state==wait_till_empty)||(present_state==check_parity_error);
assign lfd_state=(present_state==load_first_data);
assign ld_state=(present_state==load_data);
assign write_enb_reg=(present_state==load_data)||(present_state==load_after_full)||(present_state==load_parity);
assign full_state=(present_state==fifo_full_state);
assign laf_state=(present_state==load_after_full);
assign rst_int_reg=(present_state==check_parity_error);
//assign low_packet_valid=(present_state==load_after_full);
assign detect_add=(present_state==decode_address);

endmodule
