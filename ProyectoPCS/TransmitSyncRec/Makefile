all: testbench.v
	iverilog -o testbench testbench.v
	vvp testbench
	gtkwave resultados.vcd default.gtkw 

clean: 
	rm -f *.vcd testbench