-- ============================================================
-- PROJETO DE BANCO DE DADOS - E-COMMERCE
-- ETAPA 4 - IMPLEMENTACAO DO MODELO RELACIONAL NORMALIZADO
-- SGBD: MySQL 8.0+
-- ============================================================
-- Este script implementa o modelo normalizado desenvolvido na Etapa 3.
-- Estrutura principal:
-- CLIENTE, CLIENTE_ESPECIAL, VENDEDOR, FUNCIONARIO_ESPECIAL,
-- PRODUTO, TRANSPORTADORA, VENDA e ITEM_VENDA.
--
-- Observacao de normalizacao:
-- O atributo "idade" NAO e armazenado em CLIENTE, pois pode ser
-- calculado a partir de "nascimento", evitando redundancia.
-- ============================================================


-- ============================================================
-- 1. CRIACAO DO BANCO DE DADOS
-- ============================================================

DROP DATABASE IF EXISTS ecommerce;

CREATE DATABASE ecommerce
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ecommerce;


-- ============================================================
-- 2. SCRIPT DDL - CRIACAO DAS TABELAS
-- A ordem respeita as dependencias entre as chaves estrangeiras.
-- ============================================================


-- ------------------------------------------------------------
-- TABELA: CLIENTE
-- ------------------------------------------------------------
CREATE TABLE cliente (
    id INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    sexo CHAR(1) NOT NULL,
    nascimento DATE NOT NULL,

    CONSTRAINT pk_cliente PRIMARY KEY (id),
    CONSTRAINT ck_cliente_sexo
        CHECK (sexo IN ('M', 'F', 'O'))
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: VENDEDOR
-- ------------------------------------------------------------
CREATE TABLE vendedor (
    id INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    causa_social VARCHAR(150) NOT NULL,
    tipo VARCHAR(2) NOT NULL,
    salario FLOAT NOT NULL DEFAULT 0,
    media FLOAT DEFAULT 0,

    CONSTRAINT pk_vendedor PRIMARY KEY (id),
    CONSTRAINT uq_vendedor_causa_social UNIQUE (causa_social),
    CONSTRAINT ck_vendedor_tipo
        CHECK (tipo IN ('PF', 'PJ')),
    CONSTRAINT ck_vendedor_salario
        CHECK (salario >= 0),
    CONSTRAINT ck_vendedor_media
        CHECK (media >= 0 AND media <= 5)
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: TRANSPORTADORA
-- ------------------------------------------------------------
CREATE TABLE transportadora (
    id INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,

    CONSTRAINT pk_transportadora PRIMARY KEY (id)
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: PRODUTO
-- Cada produto esta associado a um vendedor.
-- ------------------------------------------------------------
CREATE TABLE produto (
    id INT AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    estoque INT NOT NULL DEFAULT 0,
    valor FLOAT NOT NULL,
    observacoes VARCHAR(255),
    id_vendedor INT NOT NULL,

    CONSTRAINT pk_produto PRIMARY KEY (id),
    CONSTRAINT ck_produto_estoque
        CHECK (estoque >= 0),
    CONSTRAINT ck_produto_valor
        CHECK (valor >= 0),

    CONSTRAINT fk_produto_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: VENDA
-- Cada venda referencia exatamente um cliente, um vendedor
-- e uma transportadora.
-- ------------------------------------------------------------
CREATE TABLE venda (
    id INT AUTO_INCREMENT,
    destino VARCHAR(150) NOT NULL,
    data DATE NOT NULL,
    hora TIME NOT NULL,
    frete FLOAT NOT NULL DEFAULT 0,
    id_cliente INT NOT NULL,
    id_vendedor INT NOT NULL,
    id_transportadora INT NOT NULL,

    CONSTRAINT pk_venda PRIMARY KEY (id),
    CONSTRAINT ck_venda_frete
        CHECK (frete >= 0),

    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_venda_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_venda_transportadora
        FOREIGN KEY (id_transportadora)
        REFERENCES transportadora(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: ITEM_VENDA
-- Entidade associativa que resolve o relacionamento N:N
-- entre VENDA e PRODUTO.
-- A PK e composta por id_venda + id_produto.
-- ------------------------------------------------------------
CREATE TABLE item_venda (
    id_venda INT NOT NULL,
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,

    CONSTRAINT pk_item_venda
        PRIMARY KEY (id_venda, id_produto),

    CONSTRAINT ck_item_venda_quantidade
        CHECK (quantidade > 0),

    CONSTRAINT fk_item_venda_venda
        FOREIGN KEY (id_venda)
        REFERENCES venda(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_item_venda_produto
        FOREIGN KEY (id_produto)
        REFERENCES produto(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: CLIENTE_ESPECIAL
-- Especializacao de CLIENTE.
-- id_cliente e simultaneamente PK e FK.
-- ------------------------------------------------------------
CREATE TABLE cliente_especial (
    id_cliente INT,
    cashback FLOAT NOT NULL DEFAULT 0,

    CONSTRAINT pk_cliente_especial PRIMARY KEY (id_cliente),
    CONSTRAINT ck_cliente_especial_cashback
        CHECK (cashback >= 0),

    CONSTRAINT fk_cliente_especial_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES cliente(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;


-- ------------------------------------------------------------
-- TABELA: FUNCIONARIO_ESPECIAL
-- Especializacao de VENDEDOR.
-- id_vendedor e simultaneamente PK e FK.
-- ------------------------------------------------------------
CREATE TABLE funcionario_especial (
    id_vendedor INT,
    bonus FLOAT NOT NULL DEFAULT 0,

    CONSTRAINT pk_funcionario_especial PRIMARY KEY (id_vendedor),
    CONSTRAINT ck_funcionario_especial_bonus
        CHECK (bonus >= 0),

    CONSTRAINT fk_funcionario_especial_vendedor
        FOREIGN KEY (id_vendedor)
        REFERENCES vendedor(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE = InnoDB;


-- ============================================================
-- 3. SCRIPT DML - DADOS INICIAIS
-- Os dados foram variados para permitir consultas futuras.
-- ============================================================


-- ------------------------------------------------------------
-- CLIENTES
-- ------------------------------------------------------------
INSERT INTO cliente (nome, sexo, nascimento) VALUES
('Ana Souza',        'F', '1999-03-15'),
('Carlos Lima',      'M', '1988-07-22'),
('Mariana Alves',    'F', '2001-11-03'),
('Joao Pereira',     'M', '1995-01-28'),
('Beatriz Santos',   'F', '1992-06-12'),
('Lucas Oliveira',   'M', '2003-09-19'),
('Fernanda Costa',   'F', '1985-12-01'),
('Rafael Martins',   'M', '1998-04-09'),
('Camila Rocha',     'F', '2000-08-30'),
('Gabriel Ferreira', 'M', '1990-02-17');


-- ------------------------------------------------------------
-- VENDEDORES
-- ------------------------------------------------------------
INSERT INTO vendedor (nome, causa_social, tipo, salario, media) VALUES
('Tech Recife',       'Tech Recife Comercio LTDA',       'PJ', 6500.00, 4.80),
('Mundo Digital',      'Mundo Digital Eletronicos LTDA',  'PJ', 7200.00, 4.60),
('Paulo Mendes',       'Paulo Mendes',                    'PF', 3500.00, 4.20),
('Smart Solutions',    'Smart Solutions LTDA',            'PJ', 8000.00, 4.90),
('Juliana Nascimento', 'Juliana Nascimento',              'PF', 3800.00, 4.50);


-- ------------------------------------------------------------
-- TRANSPORTADORAS
-- ------------------------------------------------------------
INSERT INTO transportadora (nome, cidade) VALUES
('Entrega Rapida',     'Recife'),
('Nordeste Express',   'Olinda'),
('LogMais',            'Jaboatao dos Guararapes'),
('Rota Segura',        'Paulista'),
('Pernambuco Cargas',  'Caruaru');


-- ------------------------------------------------------------
-- PRODUTOS
-- ------------------------------------------------------------
INSERT INTO produto
(nome, descricao, estoque, valor, observacoes, id_vendedor)
VALUES
('Teclado Mecanico',  'Teclado mecanico com iluminacao RGB',        40, 249.90, 'Switch azul',                 1),
('Mouse Gamer',        'Mouse optico com 6 botoes programaveis',     65, 129.90, 'DPI ajustavel',               1),
('Monitor 24',         'Monitor Full HD de 24 polegadas',            22, 899.90, 'Painel IPS',                   2),
('Headset USB',        'Headset com microfone e conexao USB',        35, 199.90, NULL,                           2),
('SSD 1TB',            'SSD NVMe M.2 com capacidade de 1TB',         30, 449.90, 'Leitura de alta velocidade',   3),
('Memoria RAM 16GB',   'Modulo DDR4 de 16GB',                        55, 279.90, '3200 MHz',                      3),
('Webcam Full HD',     'Webcam 1080p com microfone integrado',       28, 219.90, NULL,                           4),
('Notebook Pro 15',    'Notebook 15 polegadas para uso profissional',12, 4299.90,'16GB RAM e SSD 512GB',         4),
('Cadeira Gamer',      'Cadeira ergonomica com ajuste de altura',    15, 1199.90,'Suporta ate 120 kg',           5),
('Hub USB-C',          'Hub USB-C com HDMI e portas USB 3.0',        45, 189.90, 'Compativel com notebooks',      5),
('Microfone USB',      'Microfone condensador para streaming',       18, 379.90, 'Inclui suporte de mesa',        1),
('Suporte Monitor',    'Suporte articulado para monitor',            25, 159.90, 'Padrao VESA',                  2);


-- ------------------------------------------------------------
-- VENDAS
-- ------------------------------------------------------------
INSERT INTO venda
(destino, data, hora, frete, id_cliente, id_vendedor, id_transportadora)
VALUES
('Recife - Boa Viagem',            '2026-10-01', '09:15:00', 18.00,  1, 1, 1),
('Olinda - Bairro Novo',            '2026-10-02', '10:40:00', 22.50,  2, 2, 2),
('Recife - Casa Forte',             '2026-10-03', '14:20:00', 20.00,  3, 4, 1),
('Jaboatao - Piedade',              '2026-10-04', '16:05:00', 25.00,  1, 3, 3),
('Paulista - Centro',               '2026-10-05', '11:30:00', 27.50,  4, 5, 4),
('Recife - Madalena',               '2026-10-07', '13:10:00', 18.00,  5, 1, 1),
('Caruaru - Maurício de Nassau',    '2026-10-09', '15:45:00', 35.00,  6, 4, 5),
('Olinda - Casa Caiada',            '2026-10-12', '08:50:00', 22.50,  7, 2, 2),
('Recife - Várzea',                 '2026-10-15', '17:25:00', 19.50,  8, 3, 1),
('Jaboatao - Candeias',             '2026-10-18', '12:00:00', 25.00,  9, 5, 3),
('Recife - Espinheiro',             '2026-11-01', '10:10:00', 18.00, 10, 1, 1),
('Paulista - Janga',                '2026-11-05', '14:35:00', 28.00,  2, 4, 4);


-- ------------------------------------------------------------
-- ITENS DAS VENDAS
-- Cada venda possui um ou mais produtos.
-- ------------------------------------------------------------
INSERT INTO item_venda (id_venda, id_produto, quantidade) VALUES
(1,  1, 1),
(1,  2, 2),
(2,  3, 1),
(2,  4, 1),
(3,  8, 1),
(3,  7, 1),
(4,  5, 2),
(4,  6, 1),
(5,  9, 1),
(5, 10, 2),
(6,  1, 1),
(6, 11, 1),
(7,  8, 1),
(7,  7, 2),
(8,  3, 2),
(8, 12, 1),
(9,  5, 1),
(9,  6, 2),
(10, 9, 1),
(10,10, 1),
(11, 2, 1),
(11,11, 1),
(12, 8, 1),
(12, 7, 1);


-- ------------------------------------------------------------
-- CLIENTES ESPECIAIS
-- Especializacao: somente alguns clientes possuem cashback.
-- ------------------------------------------------------------
INSERT INTO cliente_especial (id_cliente, cashback) VALUES
(1,  42.50),
(3,  95.00),
(6, 110.25),
(7,  58.70);


-- ------------------------------------------------------------
-- FUNCIONARIOS ESPECIAIS
-- Especializacao: somente alguns vendedores possuem bonus.
-- ------------------------------------------------------------
INSERT INTO funcionario_especial (id_vendedor, bonus) VALUES
(1, 350.00),
(2, 420.00),
(4, 600.00);


-- ============================================================
-- 4. VALIDACAO DA IMPLEMENTACAO
-- Estes comandos podem ser executados para verificar a estrutura
-- e os dados inseridos.
-- ============================================================

-- Lista todas as tabelas criadas.
SHOW TABLES;

-- Exibe as definicoes das tabelas e suas constraints.
SHOW CREATE TABLE cliente;
SHOW CREATE TABLE vendedor;
SHOW CREATE TABLE transportadora;
SHOW CREATE TABLE produto;
SHOW CREATE TABLE venda;
SHOW CREATE TABLE item_venda;
SHOW CREATE TABLE cliente_especial;
SHOW CREATE TABLE funcionario_especial;

-- Quantidade de registros inseridos em cada tabela.
SELECT 'cliente' AS tabela, COUNT(*) AS registros FROM cliente
UNION ALL
SELECT 'vendedor', COUNT(*) FROM vendedor
UNION ALL
SELECT 'transportadora', COUNT(*) FROM transportadora
UNION ALL
SELECT 'produto', COUNT(*) FROM produto
UNION ALL
SELECT 'venda', COUNT(*) FROM venda
UNION ALL
SELECT 'item_venda', COUNT(*) FROM item_venda
UNION ALL
SELECT 'cliente_especial', COUNT(*) FROM cliente_especial
UNION ALL
SELECT 'funcionario_especial', COUNT(*) FROM funcionario_especial;


-- Consulta de validacao dos relacionamentos.
SELECT
    v.id AS id_venda,
    v.data,
    c.nome AS cliente,
    vd.nome AS vendedor,
    t.nome AS transportadora,
    p.nome AS produto,
    iv.quantidade,
    p.valor,
    (iv.quantidade * p.valor) AS subtotal
FROM venda v
JOIN cliente c
    ON c.id = v.id_cliente
JOIN vendedor vd
    ON vd.id = v.id_vendedor
JOIN transportadora t
    ON t.id = v.id_transportadora
JOIN item_venda iv
    ON iv.id_venda = v.id
JOIN produto p
    ON p.id = iv.id_produto
ORDER BY v.id, p.id;


-- Total de cada venda.
SELECT
    v.id AS id_venda,
    c.nome AS cliente,
    SUM(iv.quantidade * p.valor) AS total_produtos,
    v.frete,
    SUM(iv.quantidade * p.valor) + v.frete AS total_venda
FROM venda v
JOIN cliente c
    ON c.id = v.id_cliente
JOIN item_venda iv
    ON iv.id_venda = v.id
JOIN produto p
    ON p.id = iv.id_produto
GROUP BY v.id, c.nome, v.frete
ORDER BY v.id;


-- ============================================================
-- 5. TESTES DE INTEGRIDADE REFERENCIAL
-- ============================================================
-- Os testes que DEVEM produzir erro ficam comentados para que
-- a execucao completa do arquivo nao seja interrompida.
-- Para testar, execute cada comando separadamente.


-- ------------------------------------------------------------
-- TESTE 1 - REFERENCIA VALIDA
-- Deve funcionar, pois cliente 1, vendedor 1 e transportadora 1 existem.
-- A transacao e revertida para nao alterar os dados da carga inicial.
-- ------------------------------------------------------------
START TRANSACTION;

INSERT INTO venda
(destino, data, hora, frete, id_cliente, id_vendedor, id_transportadora)
VALUES
('Recife - Teste de Integridade', '2026-11-16', '10:00:00', 15.00, 1, 1, 1);

ROLLBACK;


-- ------------------------------------------------------------
-- TESTE 2 - REFERENCIA INEXISTENTE
-- RESULTADO ESPERADO: ERRO DE CHAVE ESTRANGEIRA.
-- O cliente 9999 nao existe.
-- Descomente apenas para realizar o teste.
-- ------------------------------------------------------------
/*
INSERT INTO venda
(destino, data, hora, frete, id_cliente, id_vendedor, id_transportadora)
VALUES
('Destino Invalido', '2026-11-16', '11:00:00', 10.00, 9999, 1, 1);
*/


-- ------------------------------------------------------------
-- TESTE 3 - CHECK DE QUANTIDADE
-- RESULTADO ESPERADO: ERRO, pois quantidade deve ser maior que zero.
-- ------------------------------------------------------------
/*
INSERT INTO item_venda (id_venda, id_produto, quantidade)
VALUES (1, 3, 0);
*/


-- ------------------------------------------------------------
-- TESTE 4 - CHECK DE ESTOQUE
-- RESULTADO ESPERADO: ERRO, pois estoque nao pode ser negativo.
-- ------------------------------------------------------------
/*
UPDATE produto
SET estoque = -1
WHERE id = 1;
*/


-- ------------------------------------------------------------
-- TESTE 5 - ON DELETE RESTRICT
-- RESULTADO ESPERADO: ERRO ao tentar remover vendedor que possui
-- produtos ou vendas relacionados.
-- ------------------------------------------------------------
/*
DELETE FROM vendedor
WHERE id = 1;
*/


-- ------------------------------------------------------------
-- TESTE 6 - ON DELETE CASCADE DE VENDA -> ITEM_VENDA
-- Dentro da transacao, a venda 12 e removida e seus itens tambem.
-- O ROLLBACK restaura tudo ao final.
-- ------------------------------------------------------------
START TRANSACTION;

SELECT *
FROM item_venda
WHERE id_venda = 12;

DELETE FROM venda
WHERE id = 12;

SELECT *
FROM item_venda
WHERE id_venda = 12;

ROLLBACK;


-- ------------------------------------------------------------
-- TESTE 7 - ON UPDATE CASCADE
-- Alterar temporariamente a PK do cliente 10 deve atualizar a FK
-- em VENDA e depois o ROLLBACK desfaz a operacao.
-- ------------------------------------------------------------
START TRANSACTION;

UPDATE cliente
SET id = 110
WHERE id = 10;

SELECT id, id_cliente
FROM venda
WHERE id_cliente = 110;

ROLLBACK;


-- ============================================================
-- 6. CONSULTAS FINAIS DE CONFERENCIA
-- ============================================================

SELECT * FROM cliente ORDER BY id;
SELECT * FROM vendedor ORDER BY id;
SELECT * FROM transportadora ORDER BY id;
SELECT * FROM produto ORDER BY id;
SELECT * FROM venda ORDER BY id;
SELECT * FROM item_venda ORDER BY id_venda, id_produto;
SELECT * FROM cliente_especial ORDER BY id_cliente;
SELECT * FROM funcionario_especial ORDER BY id_vendedor;

-- ============================================================
-- FIM DO SCRIPT
-- ============================================================
