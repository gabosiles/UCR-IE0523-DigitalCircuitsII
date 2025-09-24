/////////////////////////////////////////////
/////////////// SINCRONIZADOR ///////////////
/////////////////////////////////////////////

////////// VALID SPECIAL CODE GROUPS //////////

// RD NEGATIVO

`define K28_0_10N 10'b001111_0100
`define K28_1_10N 10'b001111_1001
`define K28_2_10N 10'b001111_0101
`define K28_3_10N 10'b001111_0011
`define K28_4_10N 10'b001111_0010
`define K28_5_10N 10'b001111_1010
`define K28_6_10N 10'b001111_0110
`define K28_7_10N 10'b001111_1000
`define K23_7_10N 10'b111010_1000
`define K27_7_10N 10'b110110_1000
`define K29_7_10N 10'b101110_1000
`define K30_7_10N 10'b011110_1000

// RD POSITIVO

`define K28_0_10P 10'b110000_1011
`define K28_1_10P 10'b110000_0110
`define K28_2_10P 10'b110000_1010
`define K28_3_10P 10'b110000_1100
`define K28_4_10P 10'b110000_1101
`define K28_5_10P 10'b110000_0101
`define K28_6_10P 10'b110000_1001
`define K28_7_10P 10'b110000_0111
`define K23_7_10P 10'b000101_0111
`define K27_7_10P 10'b001001_0111
`define K29_7_10P 10'b010001_0111
`define K30_7_10P 10'b100001_0111

////////// VALID DATA CODE GROUPS //////////

// RD NEGATIVO

`define D2_2_10N   10'b101101_0101 // C2
`define D5_6_10N   10'b101001_0110 // C5
`define D16_2_10N  10'b011011_0101 // 50
`define D21_5_10N  10'b101010_1010 // C1
`define D0_0_10N   10'b100111_0100 // 00
`define D16_0_10N  10'b011011_0100 // 10
`define D0_1_10N   10'b100111_1001 // 20
`define D16_1_10N  10'b011011_1001 // 30
`define D0_2_10N   10'b100111_0101 // 40
`define D16_3_10N  10'b011011_0011 // 70
`define D0_3_10N   10'b100111_0011 // 60
`define D0_4_10N   10'b100111_0010 // 80

// RD POSITIVO

`define D2_2_10P  10'b010010_0101 // C2
`define D5_6_10P 10'b101001_0110 // C5
`define D16_2_10P 10'b100100_0101 // 50
`define D21_5_10P  10'b101010_1010 // C1
`define D0_0_10P 10'b011000_1011 // 00
`define D16_0_10P 10'b100100_1011 // 10
`define D0_1_10P 10'b011000_1001 // 20
`define D16_1_10P 10'b100100_1001 // 30
`define D0_2_10P 10'b011000_0101 // 40
`define D0_3_10P 10'b011000_1100 // 60
`define D16_3_10P 10'b100100_1100 // 70
`define D0_4_10P 10'b011000_1101 // 80

// Métodos para distinguir categorías de datos

`define IsComma(rx_code_group) \
    ( \
	(rx_code_group == `K28_5_10N) || (rx_code_group == `K28_5_10P) \
    )

`define IsSpecial(rx_code_group) \
    ( \
	(rx_code_group == `K28_0_10N) || (rx_code_group == `K28_0_10P) || \
	(rx_code_group == `K28_1_10N) || (rx_code_group == `K28_1_10P) || \
	(rx_code_group == `K28_2_10N) || (rx_code_group == `K28_2_10P) || \
	(rx_code_group == `K28_3_10N) || (rx_code_group == `K28_3_10P) || \
	(rx_code_group == `K28_4_10N) || (rx_code_group == `K28_4_10P) || \
	(rx_code_group == `K28_5_10N) || (rx_code_group == `K28_5_10P) || \
	(rx_code_group == `K28_6_10N) || (rx_code_group == `K28_6_10P) || \
	(rx_code_group == `K28_7_10N) || (rx_code_group == `K28_7_10P) || \
	(rx_code_group == `K23_7_10N) || (rx_code_group == `K23_7_10P) || \
	(rx_code_group == `K27_7_10N) || (rx_code_group == `K27_7_10P) || \
    (rx_code_group == `K29_7_10N) || (rx_code_group == `K29_7_10P) || \
	(rx_code_group == `K30_7_10N) || (rx_code_group == `K30_7_10P) \
    )
    
`define IsData(rx_code_group) \
    ( \
	(rx_code_group == `D5_6_10N) || (rx_code_group == `D5_6_10P) || \
	(rx_code_group == `D16_2_10N) || (rx_code_group == `D16_2_10P) || \
	(rx_code_group == `D0_0_10N) || (rx_code_group == `D0_0_10P) || \
	(rx_code_group == `D16_0_10N) || (rx_code_group == `D16_0_10P) || \
	(rx_code_group == `D0_1_10N) || (rx_code_group == `D0_1_10P) || \
	(rx_code_group == `D16_1_10N) || (rx_code_group == `D16_1_10P) || \
	(rx_code_group == `D0_2_10N) || (rx_code_group == `D0_2_10P) || \
	(rx_code_group == `D0_3_10N) || (rx_code_group == `D0_3_10P) || \
    (rx_code_group == `D16_3_10N) || (rx_code_group == `D16_3_10P) || \
	(rx_code_group == `D0_4_10N) || (rx_code_group == `D0_4_10P) \
    )

`define IsValid(rx_code_group) \
    ( \
    (`IsSpecial(rx_code_group)) || (`IsData(rx_code_group)) \
    )

// Definición de las señales cggood y cgbad

/*
cgbad se define como una condición en el cual se recibe una entrada válida,
o en el cual se recibe un coma en rx_even = 1, porque los comas se deben
recibir en rx_even = 0.
cggood es simplemente la negación de cgbad.
*/

`define cgbad(rx_code_group, rx_even) ((!`IsValid(rx_code_group)) || (`IsComma(rx_code_group) && rx_even))

`define cggood(rx_code_group, rx_even) (!((!`IsValid(rx_code_group)) || (`IsComma(rx_code_group) && rx_even)))



////////////////////////////////////////
/////////////// RECEPTOR ///////////////
////////////////////////////////////////

// ORDERED SETS
`define K28_5 8'b101_11100
`define K27_7 8'b111_11011 // /S/
`define D16_2 8'b010_10000
`define D21_5 8'b101_10101
`define D2_2  8'b010_00010
`define K23_7 8'b111_10111 // /R/
`define K29_7 8'b111_11101 // /T/

// DATOS EN 8 BITS
`define D5_6  8'b110_00101
`define D0_0  8'b000_00000
`define D16_0 8'b000_10000
`define D0_1  8'b001_00000
`define D16_1 8'b001_10000
`define D0_2  8'b010_00000
`define D0_3  8'b011_00000
`define D16_3 8'b011_10000
`define D0_4  8'b100_00000

`define DataReceptor(SUDI) \
  (SUDI == `D5_6_10N || SUDI == `D5_6_10P || \
   SUDI == `D16_2_10N || SUDI == `D16_2_10P || \
   SUDI == `D0_0_10N || SUDI == `D0_0_10P || \
   SUDI == `D16_0_10N || SUDI == `D16_0_10P || \
   SUDI == `D0_1_10N || SUDI == `D0_1_10P || \
   SUDI == `D16_1_10N || SUDI == `D16_1_10P || \
   SUDI == `D0_2_10N || SUDI == `D0_2_10P || \
   SUDI == `D0_3_10N || SUDI == `D0_3_10P || \
   SUDI == `D16_3_10N || SUDI == `D16_3_10P || \
   SUDI == `D0_4_10N || SUDI == `D0_4_10P)
