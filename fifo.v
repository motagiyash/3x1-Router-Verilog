module router_fifo(clk,reset,soft_reset,write_enb,read_enb,lfd_state,datain,full,empty,dataout);
//I/O
input clk,reset,soft_reset,write_enb,read_enb,lfd_state;
input [7:0]datain;
output full,empty;
output reg [7:0]dataout;
//Data types
reg [4:0]read_ptr,write_ptr;
reg [5:0]count;
reg [8:0]fifo[15:0];
integer i,j;
reg temp;
//Full and empty conditions

assign full =((read_ptr[4]!=write_ptr[4]) && (read_ptr[3:0]==write_ptr[3:0]))?1'b1:1'b0;

assign empty =(write_ptr[4:0]==read_ptr[4:0])?1'b1:1'b0;

always@(posedge clk)
	begin
		if(~reset)
			temp<=1'b0;
		else
			temp<=lfd_state;
	end
//Fifo write logic
always@(posedge clk)
	begin
		if(~reset)
			begin
				for(i=0;i<16;i=i+1)
					fifo[i]<=0; 
			end
		else if(soft_reset)
			begin
				for(j=0;j<16;j=j+1)
					fifo[j]<=0; 
			end
		
		else if(write_enb && ~full)
				{fifo[write_ptr[3:0]][8],fifo[write_ptr[3:0]][7:0]}<={temp,datain};
	
	end
			
//Fifo Read logic		
always@(posedge clk)
	begin
		if(~reset)
			dataout<=8'd0;

		else if(soft_reset)
			dataout<=8'hzz;
		
		else
			begin 
				if(read_enb && ~empty)
					dataout<=fifo[read_ptr[3:0]];
				if(count==0)
					dataout<=8'hzz;
			end
	end
			
//Count logic

always@(posedge clk)
	begin
		
		 if(read_enb && ~empty)
			begin
				if(fifo[read_ptr[3:0]][8])
					count<=fifo[read_ptr[3:0]][7:2]+1'b1;

				else if(count!=6'd0)
					count<=count-1'b1;
				
			end
	
	end

//pointer logic
always@(posedge clk)
	begin
		if(~reset)
			begin
				read_ptr=5'd0;
				write_ptr=5'd0;
			end

		else if (soft_reset)
			begin
				read_ptr=5'd0;
				write_ptr=5'd0;
			end

		else 
			begin
				if(write_enb && ~full)
					write_ptr=write_ptr+1'b1;

				if(read_enb && ~empty)
					read_ptr=read_ptr+1'b1;
			end
	end

endmodule
