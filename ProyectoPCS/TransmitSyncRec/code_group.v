`ifndef code_group
`define code_group

// Data group code
// D00.0
    `define D0_0_octet          8'b000_00000
    `define D0_0_rd_neg         10'b100111_0100
    `define D0_0_rd_pos         10'b011000_1011

// D00.1
    `define D0_1_octet          8'b001_00000
    `define D0_1_rd_neg         10'b100111_1001
    `define D0_1_rd_pos         10'b011000_1001

// D00.2
    `define D0_2_octet          8'b010_00000
    `define D0_2_rd_neg         10'b100111_0101 
    `define D0_2_rd_pos         10'b011000_0101

// D00.3
    `define D0_3_octet          8'b011_00000
    `define D0_3_rd_neg         10'b100111_0011
    `define D0_3_rd_pos         10'b011000_1100

// D00.4
    `define D0_4_octet          8'b100_00000
    `define D0_4_rd_neg         10'b100111_0010
    `define D0_4_rd_pos         10'b011000_1101

// D5.6
    `define D5_6_octet          8'b110_00101
    `define D5_6_rd_neg         10'b101001_0110
    `define D5_6_rd_pos         10'b101001_0110

// D16.0
    `define D16_0_octet         8'b000_10000
    `define D16_0_rd_neg        10'b011011_0100
    `define D16_0_rd_pos        10'b100100_1011 

// D16.1
    `define D16_1_octet         8'b001_10000
    `define D16_1_rd_neg        10'b011011_1001
    `define D16_1_rd_pos        10'b100100_1001

// D16.2 
    `define D16_2_octet         8'b010_10000
    `define D16_2_rd_neg        10'b011011_0101
    `define D16_2_rd_pos        10'b100100_0101

// D16.3
    `define D16_3_octet         8'b011_10000
    `define D16_3_rd_neg        10'b011011_0011
    `define D16_3_rd_pos        10'b100100_1100

// D21.5
    `define D21_5_octet         8'b101_10101
    `define D21_5_rd_neg        10'b101010_1010 
    `define D21_5_rd_pos        10'b101010_1010


// Special group code

// K28.5 IDLE /I/ 
    `define K28_5_octet         8'b101_11100
    `define K28_5_rd_neg        10'b001111_1010
    `define K28_5_rd_pos        10'b110000_0101

// K23.7 EXTEND /R/
    `define K23_7_octet        8'b111_10111
    `define K23_7_rd_neg       10'b111010_1000
    `define K23_7_rd_pos       10'b000101_0111

// K27.7 START /S/
    `define K27_7_octet        8'b111_11011
    `define K27_7_rd_pos       10'b001001_0111
    `define K27_7_rd_neg       10'b110110_1000

// K29.7 END /T/
    `define K29_7_octet        8'b111_11101
    `define K29_7_rd_pos       10'b010001_0111
    `define K29_7_rd_neg       10'b101110_1000
    
`endif