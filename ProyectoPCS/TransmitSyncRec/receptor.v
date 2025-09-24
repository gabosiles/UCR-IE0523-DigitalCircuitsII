/* ***********************************************************
                    Universidad de Costa Rica
                 Escuela de Ingenieria Electrica
                             IE0523
                     Circuitos Digitales 2

                            Proyecto

Autores: Jorge Loría,Gabriel Siles, Jun Hyung
Carnet: C04406, C17530, B17326
Fecha: 30/11/2024

************************************************************/

`include "lookup.v"

module receptor(
  input wire RX_CLK,  //Reloj de sincronizacion del receptor
  input wire mr_main_reset,
  input wire code_sync_status,
  input wire [9:0]SUDI, //rx_code_groups == SUDI en el receptor
  input wire rx_even,
  output reg [7:0] RXD,
  output reg RX_DV,
  output reg RX_ER
);


//Declarion de Estados->1 bit por estado
parameter LINK_FAILED       = 7'b0000001;
parameter WAIT_FOR_K        = 7'b0000010;
parameter RX_K              = 7'b0000100;
parameter IDLE_D            = 7'b0001000;
parameter START_OF_PACKET   = 7'b0010000;
parameter RECEIVE           = 7'b0100000;
parameter TRI_RRI           = 7'b1000000;


// ** Variables internas **
parameter FAIL = 1'b0; // Para el estado de LINKED_FAILED
//Como vamos a trabajar con datos que estan en TRUE o FALSE es mejor definir un parametro para no estar colocando
// ceros o unos que pueden llegar a provocar futuros errores
parameter TRUE = 1'b1; 
parameter FALSE = 1'b0;
reg [7:0] state,next_state; // transicion de estados
reg receiving;
reg rx_lpi_active; // Solo se usa en un estado, pero no afecta en nada el comportamiento
reg [1:0] check_end; // Para la transicion check_end = T/R/K28.5

//Logica secuencial
//Usar negedge para evitar conflictos
always @(negedge RX_CLK) begin
  if (mr_main_reset == TRUE)begin
    state <= WAIT_FOR_K;
  end else begin 
    state <= next_state;
  end
end

always @(posedge RX_CLK)begin
  if (code_sync_status == FAIL && SUDI)begin
    state <= LINK_FAILED;
  end
end
// Logica combinacional
always @(*)begin
  next_state = state; //Transicion como FF
  RX_DV = 0;
  RX_ER = 0;
  receiving = 0;
  case(state)
    LINK_FAILED:begin                           // [1]
      rx_lpi_active =  FALSE;
      if (receiving == TRUE)begin
        receiving = FALSE;
        RX_ER = TRUE;
      end else begin
        RX_DV = FALSE;
        RX_ER = FALSE;
      end
      if (SUDI && code_sync_status != FAIL) begin
        next_state = WAIT_FOR_K;
      end
    end
    WAIT_FOR_K:begin                           // [2]
      receiving = FALSE;
      RX_DV = FALSE;
      RX_ER = FALSE;
      if ((SUDI == `K28_5_10P || SUDI== `K28_5_10N)  && rx_even == TRUE)begin 
        next_state = RX_K;
      end
    end
    RX_K: begin                               // [4]
      receiving = FALSE;
      RX_DV = FALSE;
      RX_ER = FALSE;
      if (SUDI != `D21_5_10N && SUDI != `D21_5_10P && SUDI != `D2_2_10N && SUDI != `D2_2_10P)begin
        next_state = IDLE_D;
      end
    end
    //Se combina IDLE_D con CARRIER_DETECT
    IDLE_D:begin                              // [8]
      receiving = FALSE;
      RX_DV = FALSE;
      RX_ER = FALSE;
      rx_lpi_active = FALSE;
      // Si detecta comas (K28.5) vuelve a RX_K
      if ((SUDI == `K28_5_10N && rx_even == FALSE) || (SUDI == `K28_5_10P && rx_even == TRUE))begin
        next_state = RX_K;
      end
      // Si detecta a /S/ pasa al START_OF_PACKET
      else if((SUDI == `K27_7_10N && rx_even == FALSE) || (SUDI == `K27_7_10P && rx_even == TRUE))begin
        next_state = START_OF_PACKET;
      end
    end
    START_OF_PACKET: begin                    // [16]
      RX_DV = TRUE;
      RX_ER = FALSE;
      receiving = TRUE; // Lo mantenemos activo
      RXD = `K27_7;// Asignamos /S/
      if (SUDI) begin
        next_state = RECEIVE;
      end
    end

    RECEIVE:begin                             // [32]
      receiving = TRUE;
      RX_DV = TRUE;      
      //Condicion de transicion /T/R/K28.5/
      if (SUDI == `K29_7_10N || SUDI == `K29_7_10P)begin
        check_end = 2'b01;
      end
      if(SUDI == `K23_7_10N || SUDI == `K23_7_10P)begin
        if(check_end == 2'b01)begin
          check_end = 2'b10;
        end else begin
          check_end = 2'b00;
        end
      end
      if(SUDI == `K28_5_10N || SUDI == `K28_5_10P) begin
        if(check_end == 2'b10)begin
          check_end = 2'b11;
          next_state = TRI_RRI; 
        end else begin
          check_end = 2'b00;
        end
      end
    //Condicion de transicion /D/
    if (`DataReceptor(SUDI)) begin
      if ((SUDI == `D5_6_10N) || (SUDI == `D5_6_10P)) begin
        RXD = `D5_6;
      end
      if((SUDI == `D16_2_10N) || (SUDI == `D16_2_10P))begin
        RXD = `D16_2;
      end
      if ((SUDI == `D0_0_10N) || (SUDI == `D0_0_10P))begin
        RXD = `D0_0;
      end
      if(SUDI == `D0_1_10N || SUDI == `D0_1_10P)begin
        RXD = `D0_1;
      end
      if(SUDI == `D16_1_10N || SUDI == `D16_1_10P)begin
        RXD = `D16_1;
      end
      if(SUDI == `D0_2_10N || SUDI == `D0_2_10P) begin
        RXD = `D0_2;
      end
      if (SUDI == `D0_3_10N || SUDI == `D0_3_10P)begin
        RXD = `D0_3;
      end
      if (SUDI == `D16_3_10N || SUDI == `D16_3_10P)begin
        RXD = `D16_3;
      end
      if(SUDI == `D0_4_10N || SUDI == `D0_4_10P)begin
        RXD = `D0_4;
      end
     end
    end

    TRI_RRI: begin                                        // [64]
      receiving = FALSE;
      RX_DV = FALSE;
      RX_ER = FALSE;
      if ((SUDI == `K28_5_10N) || (SUDI == `K28_5_10P)) begin
        check_end = 2'b00;
        next_state = RX_K;
      end
    end

    
  endcase
end


endmodule