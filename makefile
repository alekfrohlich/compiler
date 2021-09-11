
CPP		:= env.cc instr.cc
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

.PHONY: clean tests
clean:
	@rm -f compiler lex.yy.c
	@rm -f xpp.tab.c xpp.tab.h

tests: run
	./compiler < programs/tests/tests.xpp | grep --quiet --ignore-case "error" || true
	./compiler < programs/tests/test_lex1.xpp | grep --quiet --ignore-case "error" || true
	./compiler < programs/tests/test_syn1.xpp | grep --quiet --ignore-case "error" || true
	./compiler < programs/zinho/testBreakErrado.ccc | grep --quiet --ignore-case "error" || true