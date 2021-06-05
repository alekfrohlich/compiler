
run: xpp.l xpp.y
	flex xpp.l
	bison -d xpp.y
	gcc xpp.tab.c lex.yy.c -o compiler

debug: xpp.l xpp.y
	flex xpp.l
	bison -d --debug xpp.y
	gcc xpp.tab.c lex.yy.c -o compiler

.PHONY: clean
clean:
	@rm -f compiler lex.yy.c 
	@rm -f xpp.tab.c xpp.tab.h