module fpga_nes (
    input CLOCK_50,
    input [3:0] KEY, // bit 0 is set up as Reset
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output [7:0]  VGA_R, VGA_G, VGA_B,
    output VGA_CLK, VGA_SYNC_N, VGA_BLANK_N, VGA_VS, VGA_HS,
    inout [15:0] OTG_DATA,
    output [1:0] OTG_ADDR,
    output OTG_CS_N, OTG_OE_N, OTG_WE_N, OTG_RST_N,
    input [1:0] OTG_INT,
    output [12:0] DRAM_ADDR,
    inout [31:0]  DRAM_DQ,
    output [1:0]  DRAM_BA,
    output [3:0]  DRAM_DQM,
    output DRAM_RAS_N, DRAM_CAS_N, DRAM_CKE, DRAM_WE_N, DRAM_CS_N, DRAM_CLK
    );

    logic Reset_h, vssig, Clk;
    logic [9:0] drawxsig, drawysig, ballxsig, ballysig, ballsizesig;
    logic [23:0] keycode1, keycode2;
    logic [5:0][7:0] keycodes;

    assign Clk = CLOCK_50;
    assign {Reset_h} = ~(KEY[0]); // The push buttons are active low
    assign keycodes = {keycode2, keycode1};

    wire [1:0] hpi_addr;
	wire [15:0] hpi_data_in, hpi_data_out;
	wire hpi_r, hpi_w,hpi_cs;

    hpi_io_intf hpi_io_inst(.from_sw_address(hpi_addr),
        .from_sw_data_in(hpi_data_in),
        .from_sw_data_out(hpi_data_out),
        .from_sw_r(hpi_r),
        .from_sw_w(hpi_w),
        .from_sw_cs(hpi_cs),
        .OTG_DATA(OTG_DATA),    
        .OTG_ADDR(OTG_ADDR),    
        .OTG_OE_N(OTG_OE_N),    
        .OTG_WE_N(OTG_WE_N),    
        .OTG_CS_N(OTG_CS_N),    
        .OTG_RST_N(OTG_RST_N),   
        .OTG_INT(OTG_INT),
        .Clk(Clk),
        .Reset(Reset_h)
    );

    final_soc m_final_soc (
        .clk_clk(Clk),         
        .reset_reset_n(KEY[0]),   
        .sdram_wire_addr(DRAM_ADDR), 
        .sdram_wire_ba(DRAM_BA),   
        .sdram_wire_cas_n(DRAM_CAS_N),
        .sdram_wire_cke(DRAM_CKE),  
        .sdram_wire_cs_n(DRAM_CS_N), 
        .sdram_wire_dq(DRAM_DQ),   
        .sdram_wire_dqm(DRAM_DQM),  
        .sdram_wire_ras_n(DRAM_RAS_N),
        .sdram_wire_we_n(DRAM_WE_N), 
        .sdram_clk_clk(DRAM_CLK),
        .keycode1_export(keycode1),
        .keycode2_export(keycode2),
        .otg_hpi_address_export(hpi_addr),
        .otg_hpi_data_in_port(hpi_data_in),
        .otg_hpi_data_out_port(hpi_data_out),
        .otg_hpi_cs_export(hpi_cs),
        .otg_hpi_r_export(hpi_r),
        .otg_hpi_w_export(hpi_w)
    );
    
    vga_controller vgasync_instance(.*, .Reset(Reset_h), .hs(VGA_HS), .vs(VGA_VS), .pixel_clk(VGA_CLK),
        .blank(VGA_BLANK_N), .sync(VGA_SYNC_N), .DrawX(drawxsig), .DrawY(drawysig));
       
    ball ball_instance(.*, .keycode(keycode1), .Reset(Reset_h), .frame_clk(VGA_VS), .BallX(ballxsig), .BallY(ballysig),
        .BallS(ballsizesig));
       
    color_mapper color_instance(.DrawX(drawxsig), .DrawY(drawysig), .BallX(ballxsig), .BallY(ballysig),
        .Ball_size(ballsizesig), .Red(VGA_R), .Green(VGA_G), .Blue(VGA_B));
                                          
    HexDriver hex_inst_0 (keycodes[0][3:0], HEX0);
    HexDriver hex_inst_1 (keycodes[0][7:4], HEX1);
    
    HexDriver hex_inst_2 (keycodes[1][3:0], HEX2);
    HexDriver hex_inst_3 (keycodes[1][7:4], HEX3);
    
    HexDriver hex_inst_4 (keycodes[2][3:0], HEX4);
    HexDriver hex_inst_5 (keycodes[2][7:4], HEX5);
    
    HexDriver hex_inst_6 (keycodes[3][3:0], HEX6);
    HexDriver hex_inst_7 (keycodes[3][7:4], HEX7);

endmodule
