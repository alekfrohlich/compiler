lexer: xpp.l
	flex xpp.l
	gcc lex.yy.c -o lexer

.PHONY: clean
clean:
	@rm -f lexer lex.yy.c 