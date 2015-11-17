	 module hpi_io_intf( input [1:0]  from_sw_address,
								output[15:0] from_sw_data_in,
								input [15:0] from_sw_data_out,
								input		 from_sw_r, from_sw_w, from_sw_cs,
								inout [15:0] OTG_DATA,
								output[1:0]	 OTG_ADDR,
								output		 OTG_OE_N, OTG_WE_N, OTG_CS_N, OTG_RST_N, 
								input 		 OTG_INT, Clk, Reset);
								
logic [15:0] tmp_data;

//Fill in the blanks below. 
assign OTG_RST_N = ~Reset;  // OTG_RST_N is active low
assign OTG_DATA = from_sw_w ? 16'bz : tmp_data; // from_sw_w is active low

always_ff @ (posedge Clk or posedge Reset)
begin
	if(Reset)
	begin
		tmp_data 		<= 16'b0;
		OTG_ADDR 		<= 1'b0;
		OTG_OE_N 		<= 1'b1;
		OTG_WE_N 		<= 1'b1;
		OTG_CS_N 		<= 1'b1;
		from_sw_data_in <= 16'b0;
	end
	else 
	begin
        tmp_data        <= from_sw_data_out;
		OTG_ADDR 		<= from_sw_address;
		OTG_OE_N		<= from_sw_r;
		OTG_WE_N		<= from_sw_w;
		OTG_CS_N		<= from_sw_cs;
        from_sw_data_in <= OTG_DATA;
	end
end
endmodule 