all: calc

calc: calc.l calc.y instr.cc instr.h
	flex -o calc.yy.c calc.l
	bison -d calc.y
	g++ calc.tab.c calc.yy.c instr.cc -o calc

.PHONY: clean

clean:
	@rm -f calc.tab.* calc.yy.c calc
