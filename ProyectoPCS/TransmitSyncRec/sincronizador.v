`include "lookup.v"

module sincronizador (

    // El sincronizador posee tres entradas: clock, reset y PUDI
    // Para efectos de este proyecto, PUDI equivale a rx_code-group

	input clock,
	input reset,
	input [9:0] rx_code_group,

    // Además, posee tres salidas: SUDI, code_sync_status y rx_even

	output reg [9:0] SUDI,
	output reg code_sync_status,
	output reg rx_even
);

// Declaración de estados

parameter LOSS_OF_SYNC = 9'b0_0000_0001; // 1
parameter COMMA_DETECT_1 = 9'b0_0000_0010; // 2
parameter ACQUIRE_SYNC_1 = 9'b0_0000_0100; // 4
parameter COMMA_DETECT_2 = 9'b0_0000_1000; // 8
parameter ACQUIRE_SYNC_2 = 9'b0_0001_0000; // 16
parameter COMMA_DETECT_3 = 9'b0_0010_0000; // 32
parameter SYNC_ACQUIRED_1 = 9'b0_0100_0000; // 64
parameter SYNC_ACQUIRED_2 = 9'b0_1000_0000; // 128
parameter SYNC_ACQUIRED_2A = 9'b1_0000_0000; // 256

// Variables internas

reg [8:0] current_state, next_state;
reg [1:0] good_cgs, next_good_cgs;
reg next_rx_even; 
// next_rx_even resuelve el problema de transicionar de ACQUIRE_SYNC_1 a COMMA_DETECT_2
// Además, next_good_cgs resuelve el problema del contador good_cgs,
// el cual pasaba de 1 a 3.



// Bloque de lógica secuencial

always @(posedge clock) begin
	if (!reset) begin
		current_state <= LOSS_OF_SYNC;
		code_sync_status <= 0;
		good_cgs <= 0;
		rx_even <= 0;
	end
	else begin
		SUDI <= rx_code_group;
		current_state <= next_state;
		rx_even <= next_rx_even;
		good_cgs <= next_good_cgs;
		
		/*
		En vez de invertir el valor con una negación, se ingresa el siguiente valor
		de rx_even. Esto permite controlar en qué estados debe invertirse, y en
		qué estados debe ponerse en 1.
		*/
	end
end



// Bloque de lógica combinacional

always @(*) begin

next_state = current_state;
next_rx_even = !rx_even;
next_good_cgs = good_cgs;

case(current_state)



LOSS_OF_SYNC: begin

// En este estado, el estado de sincronización siempre debe ser 0.
code_sync_status = 0;

/*
Si se detecta un coma, se pasa al estado COMMA_DETECT_1.
En el estado COMMA_DETECT_1, rx_even debe ser 1, por lo que se pone next_rx_even en 1.
Mientras no se detecte un coma, el sincronizador se mantiene en este estado.
*/

if (`IsComma(rx_code_group)) begin
	next_state = COMMA_DETECT_1;
	next_rx_even = 1;
end
else begin
	next_state = LOSS_OF_SYNC;
	// next_rx_even = !rx_even;
end

end



COMMA_DETECT_1: begin

/*
Si después del coma se detecta un dato, el sincronizador pasa al estado ACQUIRE_SYNC_1.
Para efectos de este proyecto, el dato recibido los estados COMMA_DETECT es D16.2.
Si no se recibe un dato válido, se pierde la sincronización.
*/

// next_rx_even = !rx_even;

if (`IsData(rx_code_group)) begin
	next_state = ACQUIRE_SYNC_1;
end else begin
	next_state = LOSS_OF_SYNC;
end

end



ACQUIRE_SYNC_1: begin

/*
En este estado, pueden ocurrir tres escenarios: pasar al siguiente estado,
mantenerse en este estado, o perder la sincronización.
Para pasar al siguiente estado, se deben cumplir dos condiciones: rx_even está en 0,
y se recibe un coma.
Si no recibe un coma, pero el dato es válido, entonces se mantiene en el estado actual.
Si el se recibe una condición cgbad, se pierde la sincronización.
*/

if ((!rx_even) && (`IsComma(rx_code_group))) begin
	next_state = COMMA_DETECT_2;
	next_rx_even = 1;
end else if ((!`IsComma(rx_code_group)) && (`IsValid(rx_code_group))) begin
	next_state = ACQUIRE_SYNC_1;
	// next_rx_even = !rx_even;
end else if (`cgbad(rx_code_group, rx_even)) begin
	next_state = LOSS_OF_SYNC;
	// next_rx_even = !rx_even;
end

end



COMMA_DETECT_2: begin

/*
El estado COMMA_DETECT_2 funciona de modo similar al estado COMMA_DETECT_1.
*/

// next_rx_even = !rx_even;

if (`IsData(rx_code_group)) begin
	next_state = ACQUIRE_SYNC_2;
end else begin
	next_state = LOSS_OF_SYNC;
end
    
end


    
ACQUIRE_SYNC_2: begin

/*
El estado ACQUIRE_SYNC_2 funciona de modo similar al estado ACQUIRE_SYNC_1.
*/
    
if (!(rx_even) && (`IsComma(rx_code_group))) begin
	next_state = COMMA_DETECT_3;
	next_rx_even = 1;
end else if (!(`IsComma(rx_code_group) && (`IsValid(rx_code_group)))) begin
	next_state = ACQUIRE_SYNC_2;
	// next_rx_even = !rx_even;
end else if (`cgbad(rx_code_group, rx_even)) begin
	next_state = LOSS_OF_SYNC;
	// next_rx_even = !rx_even;
end
    
end



COMMA_DETECT_3: begin

/*
En este estado, si se detecta un dato, se adquiere la sincronización.
De lo contrario, se pierde la sincronización.
*/

// next_rx_even = !rx_even;

if (`IsData(rx_code_group)) begin
	next_state = SYNC_ACQUIRED_1;
end else begin
	next_state = LOSS_OF_SYNC;
end

end



SYNC_ACQUIRED_1: begin // 64

// next_rx_even = !rx_even;

/*
Si se ha llegado a este estado, quiere decir que se han recibido tres IDLE seguidos,
i.e. tres sets seguidos de K28.5 y D16.2, por lo que el estado de sincronización
se pone en 1.
Si se recibe una condición cggood, entonces el sincronizador se mantiene en este estado.
Si se recibe una condición cgbad, pasa al estado SYNC_ACQUIRED_2.
*/

code_sync_status = 1;

if (`cggood(rx_code_group, rx_even)) begin
	next_state = SYNC_ACQUIRED_1;
end else begin
	next_state = SYNC_ACQUIRED_2;
end

end

SYNC_ACQUIRED_2: begin // 128

/*
Este estado representa un estado de tolerancia al error; entra en juego el contador
good_cgs, quien registra la cantidad de condiciones cggood seguidas recibidas.
Para efectos de este proyecto, si en este estado se vuelve a recibir una condición
cgbad, se pierde la sincronización.
Si en este estado se recibe una condición cggood, entonces el sincronizador pasa
al estado SYNC_ACQUIRED_2A.
*/

// next_rx_even = !rx_even;
good_cgs = 0;

if (`cggood(rx_code_group, rx_even)) begin
	next_state = SYNC_ACQUIRED_2A;
end else begin
	next_state = LOSS_OF_SYNC;
end
    
end

SYNC_ACQUIRED_2A: begin

/*
Si SYNC_ACQUIRED_2 representa un estado de tolerancia al error, entonces SYNC_ACQUIRED_2A
representa un estado de recuperación del error.
Para salir de este estado de recuperación, debe recibir tres condiciones cggood seguidas.
Para efectos de este proyecto, si el sincronizador no logra recuperarse en este estado,
se pierde la sincronización.
*/

// next_rx_even = !rx_even;

if (`cggood(rx_code_group, rx_even)) begin
	if (good_cgs == 3) begin
		next_state = SYNC_ACQUIRED_1;
	end else begin
		next_state = SYNC_ACQUIRED_2A;
		next_good_cgs = good_cgs + 1;
	end
end else begin
	next_state = LOSS_OF_SYNC;
end
        
end

endcase

end 

endmodule
