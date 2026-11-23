# Projeto de Banco de Dados — E-Commerce

Projeto acadêmico de Banco de Dados desenvolvido a partir da modelagem de um sistema de e-commerce.

## Estrutura do repositório

```text
Projeto_Banco_De_Dados_Ecommerce/
├── modelos/
│   ├── modelo_conceitual.pdf
│   └── modelo_logico_relacional.pdf
├── sql/
│   ├── 01_estrutura_e_dados.sql
│   └── 02_consultas.sql
└── README.md
```

## Arquivos

### `modelos/modelo_conceitual.pdf`
Modelo conceitual desenvolvido no BRModelo Web, contendo as entidades, atributos, relacionamentos, cardinalidades e especializações do domínio.

### `modelos/modelo_logico_relacional.pdf`
Modelo lógico/relacional desenvolvido no BRModelo Web, contendo tabelas, atributos, chaves primárias e estrangeiras e relacionamentos.

### `sql/01_estrutura_e_dados.sql`
Script da Etapa 4. Responsável por:
- criação do banco de dados;
- criação das tabelas;
- definição de PKs e FKs;
- restrições de integridade;
- inserção dos dados iniciais;
- testes e consultas de validação.

### `sql/02_consultas.sql`
Script da Etapa 5, contendo consultas com:
- JOIN;
- LEFT JOIN;
- GROUP BY;
- HAVING;
- subconsulta;
- NOT EXISTS;
- consultas de validação.

## SGBD

MySQL 8.0+

## Ordem de execução

1. Execute `sql/01_estrutura_e_dados.sql`.
2. Depois execute `sql/02_consultas.sql`.

## Modelo principal

O projeto utiliza as relações:
- Cliente
- Cliente_Especial
- Vendedor
- Funcionario_Especial
- Produto
- Transportadora
- Venda
- Item_Venda

`Item_Venda` funciona como entidade associativa entre `Venda` e `Produto`.
