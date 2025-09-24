`include "sincronizador.v"
`include "transmit.v"
`include "receptor.v"
`include "tester_transmit.v"

module testbench;

    wire clock, reset;
// Wires Sincronizador
	wire [9:0] rx_code_group;
	wire [9:0] SUDI;
	wire code_sync_status,rx_even;
	wire [2:0] good_cgs;

// Wire Receptor
    wire RX_CLK;
    wire mr_main_reset;
    wire RX_ER;
    wire RX_DV;
    wire [7:0] RXD;

// Wire Transmisor
    wire  tb_TX_EN;
    wire [7:0] tb_TXD;
    wire [7:0] tb_TX_OSET_shared;                  
    wire [9:0] tb_tx_code_group;

initial begin
	$dumpfile("resultados.vcd");
    $dumpvars(-1, U0);
    $dumpvars(-1, U1);
	$dumpvars(-1, SYNC);
    $dumpvars(-1, REC);
end

sincronizador SYNC (
// Inputs
	.clock (clock),
	.reset (reset),
	.rx_code_group (tb_tx_code_group),
// Outputs
    .SUDI (SUDI[9:0]),
	.code_sync_status (code_sync_status),
	.rx_even (rx_even)
);

receptor REC (
// Inputs
    .RX_CLK(clock),
    .SUDI(SUDI),
    .code_sync_status(code_sync_status),
    .rx_even(rx_even),
    .mr_main_reset(mr_main_reset), 
//Outputs
    .RX_ER(RX_ER), 
    .RX_DV(RX_DV), 
    .RXD(RXD)
);
transmit_ordered_set U0 (
    // INPUT signals
    .TX_EN(tb_TX_EN),
    .GTX_CLK(clock),
    .RESET(reset),
    .TXD(tb_TXD),

    // SHARED signals
    .TX_OSET(tb_TX_OSET_shared)
);

transmit_code_group U1 (
    // INPUT signals
    .GTX_CLK(clock),
    .RESET(reset),

    // OUTPUT signals
    .tx_code_group(tb_tx_code_group),

    //SHARED signals
    .TX_OSET(tb_TX_OSET_shared)
);

tester_transmit T0 (
    // INPUT signals
    .tx_code_group(tb_tx_code_group),
    .TX_OSET_indicate(tb_TX_OSET_indicate),

    //OUTPUT signals
    .TXD(tb_TXD),
    .TX_EN(tb_TX_EN),
    .GTX_CLK(clock),
    .RESET(reset),
    .mr_main_reset(mr_main_reset)

);

endmodule
