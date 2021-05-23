all: calc fcalc

calc: calc.l calc.y
	flex -o calc.yy.c calc.l
	bison -d calc.y
	gcc calc.tab.c calc.yy.c -lfl -lm -o calc

fcalc: fcalc.l fcalc.y
	flex -o fcalc.yy.c fcalc.l
	bison -d fcalc.y
	gcc fcalc.tab.c fcalc.yy.c -lfl -lm -o fcalc

.PHONY: clean

clean:
	@rm -f calc.tab.* calc.yy.c calc
	@rm -f fcalc.tab* fcalc.yy.c fcalc
