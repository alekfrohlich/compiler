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
./compiler < programs/tests/test_lex1.xpp
```

Temos vários programas testes escritos na linguagem LCC-2021-1, os programas testes estão na pasta "programs".


## Docs

Documentation for [Flex](https://github.com/westes/flex) and [Bison](https://www.gnu.org/software/bison/manual/bison.pdf)

## Debug
Para analisar em detalhes algum erro sintático deve-se usar o comando:

```sh
make debug
```

e em seguida deve-se, por exemplo, executar:

```sh
./compiler < programs/tests/test_lex1.xpp
```
