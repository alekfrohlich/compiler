# Compiler

## Instruções

Para rodar, primeiro gere o analisador léxico/sintático usando o comado:

```sh
make
```

Após os analisadores serem gerados execute o comando onde *test* é o programa de teste de entrada para o analisador, alguns programas exemplo podem ser achados no diretório programs:

```sh
./compiler < test
```

Por exemplo:

```sh
./compiler < programs/test_lex1.xpp
```
# Docs

Documentation for [Flex](https://github.com/westes/flex) and [Bison](https://www.gnu.org/software/bison/manual/bison.pdf)