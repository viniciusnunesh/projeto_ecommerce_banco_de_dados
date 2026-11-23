-- ============================================================
-- PROJETO INTEGRADOR - BANCO DE DADOS - E-COMMERCE
-- ETAPA 5 - CONSULTAS SQL
-- SGBD: MySQL 8.0+
-- Banco: ecommerce (implementado na Etapa 4 - ecommerce_etapa4.sql)
-- ============================================================
-- Pre-requisito: executar antes o script da Etapa 4 (cria e popula o banco).
--
-- Observacao tecnica: as colunas de valores monetarios (valor, frete,
-- salario) foram criadas como FLOAT na Etapa 4. Em somas e medias o MySQL
-- pode exibir casas decimais residuais (ex.: 249.8999938964844).
-- Por isso, os resultados monetarios usam ROUND(..., 2).
-- ============================================================

USE ecommerce;


-- ============================================================
-- CONSULTA 1 - JOIN
-- ============================================================
-- PERGUNTA DE NEGOCIO:
--   O que cada cliente comprou em cada venda, de qual vendedor, por qual
--   transportadora, e quanto cada item custou no total?
--
-- RECURSOS SQL: INNER JOIN em 5 tabelas (venda, cliente, vendedor,
--   transportadora, item_venda, produto).
--
-- LOGICA:
--   JOIN combina linhas de duas tabelas quando a condicao do ON e
--   verdadeira. Aqui a condicao sempre liga uma chave estrangeira a chave
--   primaria que ela referencia:
--     venda.id_cliente         -> cliente.id          (N:1)
--     venda.id_vendedor        -> vendedor.id         (N:1)
--     venda.id_transportadora  -> transportadora.id   (N:1)
--     item_venda.id_venda      -> venda.id            (1:N)
--     item_venda.id_produto    -> produto.id          (N:1)
--   A tabela item_venda resolve o relacionamento N:N entre VENDA e PRODUTO.
--   Por isso o resultado tem UMA LINHA POR ITEM (nao por venda): uma venda
--   com 2 produtos aparece em 2 linhas. Isso nao e duplicidade indevida,
--   e a multiplicidade 1:N entre venda e item_venda.
--   O subtotal = quantidade * valor do produto.
--
-- RESULTADO ESPERADO:
--   24 linhas (12 vendas x 2 itens cada), uma por item vendido, com cliente,
--   vendedor, transportadora, produto, quantidade e subtotal.
--   Exemplo: venda 1 -> Ana Souza comprou 1 Teclado Mecanico (249.90) e
--   2 Mouse Gamer (259.80) de Tech Recife, entregues pela Entrega Rapida.
-- ============================================================
SELECT
    v.id                              AS id_venda,
    v.data,
    c.nome                            AS cliente,
    vd.nome                           AS vendedor,
    t.nome                            AS transportadora,
    p.nome                            AS produto,
    iv.quantidade,
    ROUND(p.valor, 2)                 AS valor_unitario,
    ROUND(iv.quantidade * p.valor, 2) AS subtotal
FROM venda v
JOIN cliente c        ON c.id = v.id_cliente
JOIN vendedor vd      ON vd.id = v.id_vendedor
JOIN transportadora t ON t.id = v.id_transportadora
JOIN item_venda iv    ON iv.id_venda = v.id
JOIN produto p        ON p.id = iv.id_produto
ORDER BY v.id, p.id;


-- ------------------------------------------------------------
-- CONSULTA 1B - LEFT JOIN (complemento da consulta 1)
-- ------------------------------------------------------------
-- PERGUNTA DE NEGOCIO:
--   Quais clientes sao "especiais" (possuem cashback) e quais sao comuns?
--
-- RECURSOS SQL: LEFT JOIN, CASE.
--
-- LOGICA:
--   CLIENTE_ESPECIAL e uma especializacao de CLIENTE (relacionamento 1:0..1):
--   nem todo cliente tem linha nela. Um INNER JOIN mostraria apenas os
--   especiais e esconderia os demais. O LEFT JOIN mantem TODOS os clientes
--   e preenche cashback com NULL quando nao ha correspondencia. Como
--   id_cliente e PK de cliente_especial, cada cliente casa com no maximo
--   uma linha, entao o JOIN nao gera duplicidade.
--
-- RESULTADO ESPERADO:
--   10 linhas (todos os clientes). Especiais: Ana (42.50), Mariana (95.00),
--   Lucas (110.25) e Fernanda (58.70). Os outros 6 aparecem com cashback
--   NULL e categoria 'Comum'.
-- ------------------------------------------------------------
SELECT
    c.id,
    c.nome,
    ce.cashback,
    CASE
        WHEN ce.id_cliente IS NULL THEN 'Comum'
        ELSE 'Especial'
    END AS categoria
FROM cliente c
LEFT JOIN cliente_especial ce ON ce.id_cliente = c.id
ORDER BY c.id;


-- ============================================================
-- CONSULTA 2 - GROUP BY
-- ============================================================
-- PERGUNTA DE NEGOCIO:
--   Quanto cada vendedor faturou com produtos e quantas vendas fez?
--   (ajuda a identificar os vendedores de maior desempenho)
--
-- RECURSOS SQL: JOIN, GROUP BY, COUNT(DISTINCT), SUM.
--
-- LOGICA:
--   GROUP BY agrupa as linhas que tem o mesmo valor nas colunas indicadas
--   e permite calcular uma funcao de agregacao por grupo. Aqui o grupo e o
--   vendedor. Depois do JOIN com item_venda, cada venda aparece uma vez por
--   item; por isso o numero de vendas usa COUNT(DISTINCT v.id) (contar
--   apenas COUNT(*) contaria itens, nao vendas). SUM(quantidade * valor)
--   soma o valor de todos os itens vendidos pelo vendedor. O frete nao
--   entra, pois pertence a venda e nao ao produto (somar junto aos itens
--   o repetiria a cada item).
--
-- RESULTADO ESPERADO (5 linhas, ordenadas por faturamento):
--   Smart Solutions     3 vendas   7 un.   13779.30
--   Mundo Digital       2 vendas   5 un.    3059.50
--   Juliana Nascimento  2 vendas   5 un.    2969.50
--   Paulo Mendes        2 vendas   6 un.    2189.40
--   Tech Recife         3 vendas   7 un.    1649.30
--   Smart Solutions lidera porque vende o Notebook Pro 15 (R$ 4.299,90).
-- ============================================================
SELECT
    vd.id                                  AS id_vendedor,
    vd.nome                                AS vendedor,
    COUNT(DISTINCT v.id)                   AS qtd_vendas,
    SUM(iv.quantidade)                     AS unidades_vendidas,
    ROUND(SUM(iv.quantidade * p.valor), 2) AS faturamento
FROM vendedor vd
JOIN venda v       ON v.id_vendedor = vd.id
JOIN item_venda iv ON iv.id_venda = v.id
JOIN produto p     ON p.id = iv.id_produto
GROUP BY vd.id, vd.nome
ORDER BY faturamento DESC;


-- ============================================================
-- CONSULTA 3 - HAVING
-- ============================================================
-- PERGUNTA DE NEGOCIO:
--   Quais sao os clientes recorrentes (2 ou mais compras) e quanto
--   gastaram no total em produtos?
--
-- RECURSOS SQL: JOIN, GROUP BY, COUNT(DISTINCT), SUM, HAVING.
--
-- LOGICA:
--   WHERE filtra linhas ANTES do agrupamento e nao pode usar funcoes de
--   agregacao. HAVING filtra grupos DEPOIS do agrupamento, entao e o
--   lugar correto para a condicao "numero de compras >= 2", que so existe
--   depois de COUNT. Como o JOIN com item_venda repete a venda por item,
--   usa-se COUNT(DISTINCT v.id) para contar compras (vendas) reais.
--
-- RESULTADO ESPERADO (2 linhas; os outros 8 clientes tem 1 compra e
-- sao eliminados pelo HAVING):
--   Carlos Lima   2 compras   5619.60  (vendas 2 e 12)
--   Ana Souza     2 compras   1689.40  (vendas 1 e 4)
-- ============================================================
SELECT
    c.id                                   AS id_cliente,
    c.nome                                 AS cliente,
    COUNT(DISTINCT v.id)                   AS qtd_compras,
    ROUND(SUM(iv.quantidade * p.valor), 2) AS total_gasto
FROM cliente c
JOIN venda v       ON v.id_cliente = c.id
JOIN item_venda iv ON iv.id_venda = v.id
JOIN produto p     ON p.id = iv.id_produto
GROUP BY c.id, c.nome
HAVING COUNT(DISTINCT v.id) >= 2
ORDER BY total_gasto DESC;


-- ============================================================
-- CONSULTA 4 - SUBCONSULTA (ESCALAR)
-- ============================================================
-- PERGUNTA DE NEGOCIO:
--   Quais produtos custam mais que a media de preco do catalogo?
--   (identifica os produtos "premium")
--
-- RECURSOS SQL: subconsulta escalar no WHERE, AVG, JOIN.
--
-- LOGICA:
--   Subconsulta escalar e uma consulta interna que devolve exatamente um
--   valor (uma linha, uma coluna), usado como se fosse uma constante pela
--   consulta externa. A consulta interna calcula AVG(valor) de todos os
--   produtos (721.57). A externa compara o valor de cada produto com esse
--   numero. A subconsulta e necessaria porque o WHERE nao aceita funcao de
--   agregacao diretamente (WHERE valor > AVG(valor) da erro). A interna
--   nao depende da externa, entao e executada uma unica vez.
--
-- RESULTADO ESPERADO (3 linhas; media = 721.57):
--   Notebook Pro 15  Smart Solutions      4299.90
--   Cadeira Gamer    Juliana Nascimento   1199.90
--   Monitor 24       Mundo Digital         899.90
-- ============================================================
SELECT
    p.id,
    p.nome                                    AS produto,
    vd.nome                                   AS vendedor,
    ROUND(p.valor, 2)                         AS valor,
    (SELECT ROUND(AVG(valor), 2) FROM produto) AS media_catalogo
FROM produto p
JOIN vendedor vd ON vd.id = p.id_vendedor
WHERE p.valor > (SELECT AVG(valor) FROM produto)
ORDER BY p.valor DESC;


-- ============================================================
-- CONSULTA 5 - NOT EXISTS
-- ============================================================
-- PERGUNTA DE NEGOCIO:
--   Quais clientes ainda NAO participam do programa de cashback
--   (nao sao clientes especiais)? (publico para uma campanha de adesao)
--
-- RECURSOS SQL: NOT EXISTS com subconsulta correlacionada.
--
-- LOGICA:
--   EXISTS devolve verdadeiro se a subconsulta retorna pelo menos uma
--   linha; NOT EXISTS devolve verdadeiro se ela nao retorna nenhuma.
--   A subconsulta e correlacionada: usa c.id da consulta externa e, para
--   cada cliente, procura sua linha em cliente_especial. Se nao achar,
--   o cliente e retornado. O SELECT 1 interno e apenas convencao: o
--   EXISTS so verifica se existe linha, nao importa o conteudo.
--   NOT EXISTS foi escolhido em vez de NOT IN porque e seguro mesmo se
--   houver NULL na subconsulta (NOT IN com NULL retorna vazio).
--
-- RESULTADO ESPERADO (6 linhas):
--   2 Carlos Lima, 4 Joao Pereira, 5 Beatriz Santos, 8 Rafael Martins,
--   9 Camila Rocha, 10 Gabriel Ferreira.
--   Os clientes 1, 3, 6 e 7 ficam de fora por terem cashback.
--   Conferencia cruzada: 6 (comuns) + 4 (especiais) = 10 clientes.
-- ============================================================
SELECT
    c.id,
    c.nome
FROM cliente c
WHERE NOT EXISTS (
    SELECT 1
    FROM cliente_especial ce
    WHERE ce.id_cliente = c.id
)
ORDER BY c.id;


-- ============================================================
-- VALIDACAO (conferencias de coerencia)
-- ============================================================

-- V1: o total de itens da consulta 1 deve ser igual a COUNT de item_venda (24).
SELECT COUNT(*) AS itens_consulta1
FROM venda v
JOIN cliente c        ON c.id = v.id_cliente
JOIN vendedor vd      ON vd.id = v.id_vendedor
JOIN transportadora t ON t.id = v.id_transportadora
JOIN item_venda iv    ON iv.id_venda = v.id
JOIN produto p        ON p.id = iv.id_produto;

SELECT COUNT(*) AS itens_na_tabela FROM item_venda;

-- V2: a soma do faturamento da consulta 2 deve ser igual ao total de
-- todos os itens vendidos (esperado: 23647.00).
SELECT ROUND(SUM(iv.quantidade * p.valor), 2) AS faturamento_total
FROM item_venda iv
JOIN produto p ON p.id = iv.id_produto;

-- V3: consulta 5 + clientes especiais deve fechar o total de clientes.
SELECT
    (SELECT COUNT(*) FROM cliente)          AS total_clientes,
    (SELECT COUNT(*) FROM cliente_especial) AS especiais;

-- V4: o vendedor da venda e o mesmo dono dos produtos vendidos?
-- Esperado: 0 linhas (dados da Etapa 4 sao consistentes nesse ponto).
SELECT v.id AS id_venda, p.id AS id_produto
FROM venda v
JOIN item_venda iv ON iv.id_venda = v.id
JOIN produto p     ON p.id = iv.id_produto
WHERE p.id_vendedor <> v.id_vendedor;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
