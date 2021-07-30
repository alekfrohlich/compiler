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

Os três programas testes escritos na linguagem LCC-2021-1 são test_lex1.xpp, test_lex2.xpp, test_lex3.xpp
O novo programa para testar a análise sintática é o arquivo test_syn1.xpp.

Além da análise sintática, estamos fazendo a checagem de nomes de variáveis por escopo e, também, a checagem se os breaks estão dentro de algum for. Para a checagem de nome de variáveis, estamos printando as variáveis em cada escopo a cada vez que fechamos algum escopo. 

## Docs

Documentation for [Flex](https://github.com/westes/flex) and [Bison](https://www.gnu.org/software/bison/manual/bison.pdf)

## Debug
Para analisar em detalhes algum erro sintático deve-se usar o comando:

```sh
make debug
```

e em seguida deve-se, por exemplo, executar:

```sh
./compiler < programs/test_lex1.xpp
```
