lexer: xpp.l xpp.y
	flex xpp.l
	bison -d xpp.y
	gcc xpp.tab.c lex.yy.c -o lexer

.PHONY: clean
clean:
	@rm -f lexer lex.yy.c 
	@rm -f xpp.tab.c xpp.tab.h