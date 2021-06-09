
CPP		:= env.cc
LY		:= xpp.l xpp.y 
DEPS 	:= $(CPP) $(LY) 

run: $(DEPS)
	flex xpp.l
	bison -d xpp.y
	g++ xpp.tab.c lex.yy.c $(CPP) -o compiler

debug: $(DEPS)
	flex xpp.l
	bison -d --debug xpp.y
	g++ xpp.tab.c lex.yy.c $(CPP) -o compiler

.PHONY: clean
clean:
	@rm -f compiler lex.yy.c 
	@rm -f xpp.tab.c xpp.tab.h