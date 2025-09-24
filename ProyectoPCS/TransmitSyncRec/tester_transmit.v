`include "code_group.v"

module tester_transmit (
    input [9:0] tx_code_group,
    input TX_OSET_indicate,
    output mr_main_reset,
    output [7:0] TXD,
    output TX_EN, GTX_CLK, RESET
);

reg mr_main_reset;
reg TX_EN, RESET, GTX_CLK;
reg [7:0] TXD;

initial begin
    RESET = 0; mr_main_reset = 1;
    GTX_CLK = 0;
    TX_EN = 0;
    #10 RESET = 1; mr_main_reset = 0;
    // /I/
    #75 TX_EN = 1;
    // /S/
    #10 TXD = `D0_0_octet;
    #10 TXD = `D0_2_octet;
    #10 TXD = `D16_1_octet;
    #10 TXD = `D0_4_octet;
    #10 TXD = `D0_3_octet;
    #10 TX_EN = 0;

    #90 $finish;
end

always begin
    #5 GTX_CLK = !GTX_CLK;
end
endmodule
