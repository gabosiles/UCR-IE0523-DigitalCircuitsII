// Universidad de Costa Rica
// Proyecto Final Circuitos Digitales II
// Diseño: Gabriel Siles

// Integrantes:
// - Gabriel Siles Chaves (Transmisor)
// - Jun Hyun Yeom (Sincronizador)
// - Jorge Loría Chaves (Receptor)
`include "code_group.v"

module transmit_ordered_set (
    input TX_EN, GTX_CLK, RESET,
    input [7:0] TXD,
    output reg [7:0] TX_OSET
);

reg [6:0] next_state, current_state;            // [7B] STATE TRANSITIONS
reg [7:0] tx_o_set;                             // [K/D] CODE-GROUP SET
reg tx_even;                                    // [1/0] (EVEN/ODD)
reg counter_idle, next_counter_idle, next_wait_a_little, wait_a_little;                 // Contador de Idles


localparam XMIT_DATA =              6'b000001; // [1] IDLE: Initial (/I/)
localparam START_OF_PACKET =        6'b000010; // [2] START (/S/)
localparam TX_PACKET =              6'b000100; // [4] TX_EN/!TX_EN PACKET
localparam TX_DATA =                6'b001000; // [8] DATA (/D/)
localparam END_OF_PACKET_NOEXT =    6'b010000; // [16] END (/T/)
localparam EPD2_NOEXT =             6'b100000; // [32] CARRIER (/R/)

always @(posedge GTX_CLK) begin
    if (!RESET) begin
        current_state <= XMIT_DATA;
        counter_idle <= 0;
        wait_a_little <= 0;
    end else begin
        current_state <= next_state;
        counter_idle <= next_counter_idle;
        wait_a_little <= next_wait_a_little;
    end
end

always @(*) begin
    next_state = current_state;
    next_counter_idle = counter_idle;
    next_wait_a_little = wait_a_little;
    case(current_state) 

    XMIT_DATA: begin                                        // [1] Envío de Idles
        if (TX_EN) begin
            TX_OSET = `K27_7_octet;
            next_state = START_OF_PACKET;  // Se habilita transmision inicio de paquete
        end else if(!TX_EN && !counter_idle) begin              // Si no se ha mandado idle iniciar con K28.5
                TX_OSET = `K28_5_octet;
                next_counter_idle = 1;                        
        end else if (!TX_EN && counter_idle == 1) begin
                TX_OSET = `D16_2_octet;
                next_counter_idle = 0;
        end
    end

    START_OF_PACKET: begin // [2]
        TX_OSET = `K27_7_octet;                // Se envia inicio de transmision /S/
        next_state = TX_PACKET;
    end

    TX_PACKET: begin // [4]
        if (TX_EN) begin
            TX_OSET = TXD;
        end else begin 
            next_state = END_OF_PACKET_NOEXT;
        end 
    end

    TX_DATA: begin // [8] ELIMINAR
        TX_OSET = TXD;
        next_state = TX_PACKET;
    end

    END_OF_PACKET_NOEXT: begin // [16]
        TX_OSET = `K29_7_octet;
        next_state = EPD2_NOEXT;
    end

    EPD2_NOEXT: begin // [32]
        TX_OSET = `K23_7_octet;
        next_wait_a_little = wait_a_little + 1;
        if (wait_a_little) begin
            TX_OSET = `K28_5_octet;
            next_state = XMIT_DATA; // agregar estado
        end 
    end

    default: begin
        next_state = XMIT_DATA;
    end

    endcase
end

endmodule

module transmit_code_group (
    input GTX_CLK, RESET,
    input [7:0] TX_OSET,
    output [9:0] tx_code_group
);

reg tx_disparity, rd_inicial, rd_parcial;                       // [1/0] (RD+/RD-) RUNNING DISPARITY
reg tx_even;                            // [1/0] (EVEN/ODD) PARITY

reg [3:0] six_bit_counter;
reg [1:0] four_bit_counter;

reg [3:0] next_state, current_state;    // [8B] STATE TRANSITIONS
reg [7:0] tx_o_set;                     // [8B] (K/D) CODE-GROUP SET

reg [9:0] tx_code_group;                // [10B] ENCODED CODE-GROUP
reg TX_OSET_indicate;

localparam GENERATE_CODE_GROUPS =   4'b0001;    // [1] GENERATE INITIAL
localparam IDLE_I2B =               4'b0010;    // [4] PRESERVING IDLE /I2/
localparam SPECIAL_GO =             4'b0100;    // [8] /S/ OR /T/ OR /R/
localparam DATA_GO =                4'b1000;    // [16] ENCODE DATA

always @(posedge GTX_CLK) begin
    rd_inicial <= tx_disparity;
        six_bit_counter <= tx_code_group[9] + tx_code_group[8] + tx_code_group[7] + tx_code_group[6] + tx_code_group[5] + tx_code_group[4];
        four_bit_counter <= tx_code_group[3] + tx_code_group[2] + tx_code_group[1]+ tx_code_group[0];
        if ((six_bit_counter > 3) || (tx_code_group[9:4] == 6'b000111)) begin 
            rd_parcial = 1;
            if ((four_bit_counter > 2) || (tx_code_group[3:0] == 4'b0011)) begin
                tx_disparity = 1;
            end else if ((four_bit_counter == 2)) begin 
                tx_disparity = rd_parcial;
            end else if ((four_bit_counter < 2) || (tx_code_group[3:0] == 4'b1100)) begin
                tx_disparity = 0;
            end
        end else if (six_bit_counter == 3) begin 
            rd_parcial = tx_disparity;
            if ((four_bit_counter > 2) || (tx_code_group[3:0] == 4'b0011)) begin
                tx_disparity = 1;
            end else if ((four_bit_counter == 4)) begin 
                tx_disparity = rd_parcial;
            end else if ((four_bit_counter < 2) || (tx_code_group[3:0] == 4'b1100)) begin
                tx_disparity = 0;
            end
        end else if ((six_bit_counter < 3) || (tx_code_group[9:4] == 6'b111000)) begin 
            rd_parcial <= 0;
            if ((four_bit_counter > 2) || (tx_code_group[3:0] == 4'b0011)) begin
                tx_disparity <= 1;
            end else if ((four_bit_counter == 4)) begin 
                tx_disparity <= rd_parcial;
            end else if ((four_bit_counter < 2) || (tx_code_group[3:0] == 4'b1100)) begin
                tx_disparity <= 0;
            end 
        end
    if (!RESET) begin
        current_state <= GENERATE_CODE_GROUPS;
        tx_disparity <= 0;
        TX_OSET_indicate <= 0;
        rd_inicial <= 0;
        rd_parcial <= 0;
        six_bit_counter <= 0;
        four_bit_counter <= 0;
    end else begin
        current_state <= next_state;

    end
end

always @(*) begin
    next_state = current_state;

    case(current_state) 
        GENERATE_CODE_GROUPS: begin // [1]
            TX_OSET_indicate = 0;
            if (TX_OSET == `K28_5_octet) begin              // /I/
                    tx_code_group = `K28_5_rd_neg;
                    tx_even = 1;
                    next_state = IDLE_I2B;  
            end else if (TX_OSET == `D0_0_octet  ||         // /D/
                        TX_OSET == `D0_1_octet   ||
                        TX_OSET == `D0_2_octet   ||
                        TX_OSET == `D0_3_octet   ||
                        TX_OSET == `D0_4_octet   ||
                        TX_OSET == `D5_6_octet   ||
                        TX_OSET == `D16_0_octet  ||
                        TX_OSET == `D16_1_octet  ||
                        TX_OSET == `D16_2_octet  ||
                        TX_OSET == `D16_3_octet  ||
                        TX_OSET == `D21_5_octet) 
                        begin 
                next_state = DATA_GO;
            end else if (TX_OSET == `K23_7_octet ||          // /R/
                        TX_OSET == `K27_7_octet  ||          // /S/
                        TX_OSET == `K29_7_octet)             // /T/            
                        begin
                if (TX_OSET == `K27_7_octet) begin 
                    if (tx_disparity) tx_code_group = `K27_7_rd_pos;
                    else tx_code_group = `K27_7_rd_neg;
                    tx_even = ~tx_even;
                    TX_OSET_indicate = 1'b1;
                    next_state = DATA_GO;
                end else if (TX_OSET == `K29_7_octet) begin 
                    if (tx_disparity) tx_code_group = `K29_7_rd_pos;
                    else tx_code_group = `K29_7_rd_neg;
                    tx_even = ~tx_even;
                    TX_OSET_indicate = 1'b1;
                    next_state = GENERATE_CODE_GROUPS;
                end if (TX_OSET == `K23_7_octet) begin 
                    if (tx_disparity) tx_code_group = `K23_7_rd_pos;
                    else tx_code_group = `K23_7_rd_neg;
                    tx_even = ~tx_even;
                    TX_OSET_indicate = 1'b1;
                    tx_disparity = 0;
                    next_state = GENERATE_CODE_GROUPS;
            end  
            end
        end 
        
        IDLE_I2B: begin // [4]
            if (tx_disparity) begin
                 tx_code_group = `D16_2_rd_pos; // PRESERVING IDLE /I2/
            end else if (!tx_disparity) begin 
                tx_code_group = `D16_2_rd_neg;
            end
            tx_even = 0;
            TX_OSET_indicate = 1;
            next_state = GENERATE_CODE_GROUPS;
        end

        SPECIAL_GO: begin // [8] eliminar
            if (TX_OSET == `K23_7_octet) begin 
                if (tx_disparity) tx_code_group = `K23_7_rd_pos;
                else tx_code_group = `K23_7_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
        end

        DATA_GO: begin // [16]
            if (TX_OSET == `D0_0_octet) begin 
                if (tx_disparity) tx_code_group = `D0_0_rd_pos;
                else tx_code_group = `D0_0_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D0_1_octet) begin 
                if (tx_disparity) tx_code_group = `D0_1_rd_pos;
                else tx_code_group = `D0_1_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D0_2_octet) begin 
                if (tx_disparity) tx_code_group = `D0_2_rd_pos;
                else tx_code_group = `D0_2_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D0_3_octet) begin 
                if (tx_disparity) tx_code_group = `D0_3_rd_pos;
                else tx_code_group = `D0_3_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D0_4_octet) begin 
                if (tx_disparity) tx_code_group = `D0_4_rd_pos;
                else tx_code_group = `D0_4_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D16_0_octet) begin 
                if (tx_disparity) tx_code_group = `D16_0_rd_pos;
                else tx_code_group = `D16_0_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D16_1_octet) begin 
                if (tx_disparity) tx_code_group = `D16_1_rd_pos;
                else tx_code_group = `D16_1_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D16_2_octet) begin 
                if (tx_disparity) tx_code_group = `D16_2_rd_pos;
                else tx_code_group = `D16_2_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D16_3_octet) begin 
                if (tx_disparity) tx_code_group = `D16_3_rd_pos;
                else tx_code_group = `D16_3_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            else if (TX_OSET == `D21_5_octet) begin 
                if (tx_disparity) tx_code_group = `D21_5_rd_pos;
                else tx_code_group = `D21_5_rd_neg;
                next_state = GENERATE_CODE_GROUPS;
            end
            tx_even = ~tx_even;
            TX_OSET_indicate = 1'b1;    // Se transmitio un paquete
        end

    endcase
end

endmodule
