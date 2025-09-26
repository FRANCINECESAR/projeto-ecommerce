-- 🔹 Criar um banco limpo para e-commerce

-- Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    tipo_cliente TEXT CHECK(tipo_cliente IN ('PF','PJ')),
    email TEXT
);

INSERT INTO clientes (nome, tipo_cliente, email) VALUES
('João Pereira', 'PF', 'joao@email.com'),
('Empresa ABC', 'PJ', 'contato@abc.com'),
('Ana Costa', 'PF', 'ana@email.com');

-- Fornecedores
CREATE TABLE IF NOT EXISTS fornecedores (
    id_fornecedor INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    contato TEXT
);

INSERT INTO fornecedores (nome, contato) VALUES
('Fornecedor X', 'fornecedorx@email.com'),
('Fornecedor Y', 'fornecedory@email.com');

-- Produtos
CREATE TABLE IF NOT EXISTS produtos (
    id_produto INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    preco REAL NOT NULL,
    estoque INTEGER DEFAULT 0,
    fornecedor_id INTEGER,
    FOREIGN KEY(fornecedor_id) REFERENCES fornecedores(id_fornecedor)
);

INSERT INTO produtos (nome, preco, estoque, fornecedor_id) VALUES
('Notebook', 2500.00, 15, 1),
('Teclado Mecânico', 350.00, 50, 2),
('Mouse Gamer', 200.00, 30, 2);

-- Pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente INTEGER,
    data_pedido DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'Pendente',
    FOREIGN KEY(id_cliente) REFERENCES clientes(id_cliente)
);

INSERT INTO pedidos (id_cliente, status) VALUES
(1, 'Entregue'),
(2, 'Pendente'),
(3, 'Em transporte');

-- Itens do Pedido
CREATE TABLE IF NOT EXISTS itens_pedido (
    id_item INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pedido INTEGER,
    id_produto INTEGER,
    quantidade INTEGER,
    preco_unitario REAL,
    FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY(id_produto) REFERENCES produtos(id_produto)
);

INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 2500.00),
(1, 2, 2, 350.00),
(2, 3, 1, 200.00),
(3, 1, 1, 2500.00);

-- Pagamentos
CREATE TABLE IF NOT EXISTS pagamentos (
    id_pagamento INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pedido INTEGER,
    tipo_pagamento TEXT,
    valor REAL,
    FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido)
);

INSERT INTO pagamentos (id_pedido, tipo_pagamento, valor) VALUES
(1, 'Cartão de Crédito', 3200.00),
(2, 'Boleto', 200.00),
(3, 'Pix', 2500.00);

-- Entregas
CREATE TABLE IF NOT EXISTS entregas (
    id_entrega INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pedido INTEGER,
    status TEXT DEFAULT 'Em transporte',
    codigo_rastreio TEXT,
    FOREIGN KEY(id_pedido) REFERENCES pedidos(id_pedido)
);

INSERT INTO entregas (id_pedido, status, codigo_rastreio) VALUES
(1, 'Entregue', 'TRK12345'),
(2, 'Em transporte', 'TRK67890'),
(3, 'Em transporte', 'TRK54321');

-- ✅ Conferir clientes
SELECT * FROM clientes;

-- ✅ Conferir fornecedores
SELECT * FROM fornecedores;

-- ✅ Conferir produtos
SELECT * FROM produtos;

-- ✅ Conferir pedidos
SELECT * FROM pedidos;
-- Quantos pedidos cada cliente fez?
SELECT c.nome, COUNT(p.id_pedido) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome;

-- Relação de produtos e fornecedores
SELECT p.nome AS produto, f.nome AS fornecedor, p.estoque
FROM produtos p
JOIN fornecedores f ON p.fornecedor_id = f.id_fornecedor
ORDER BY f.nome, p.nome;

-- Valor total de cada pedido
SELECT p.id_pedido, SUM(i.quantidade * i.preco_unitario) AS valor_total
FROM pedidos p
JOIN itens_pedido i ON p.id_pedido = i.id_pedido
GROUP BY p.id_pedido;

-- Entregas e códigos de rastreio
SELECT p.id_pedido, e.status, e.codigo_rastreio
FROM pedidos p
JOIN entregas e ON p.id_pedido = e.id_pedido;
-- 1️⃣ Quantos pedidos cada cliente fez
SELECT 
    c.nome AS cliente, 
    COUNT(p.id_pedido) AS total_pedidos
FROM clientes c
LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
GROUP BY c.id_cliente, c.nome
ORDER BY total_pedidos DESC;

-- 2️⃣ Valor total de cada pedido
SELECT 
    p.id_pedido, 
    c.nome AS cliente,
    SUM(i.quantidade * i.preco_unitario) AS valor_total
FROM pedidos p
JOIN itens_pedido i ON p.id_pedido = i.id_pedido
JOIN clientes c ON p.id_cliente = c.id_cliente
GROUP BY p.id_pedido, c.nome
ORDER BY valor_total DESC;

-- 3️⃣ Produtos e fornecedores
SELECT 
    p.nome AS produto, 
    f.nome AS fornecedor, 
    p.estoque
FROM produtos p
JOIN fornecedores f ON p.fornecedor_id = f.id_fornecedor
ORDER BY f.nome, p.nome;

-- 4️⃣ Entregas e status dos pedidos
SELECT 
    p.id_pedido, 
    c.nome AS cliente,
    e.status AS status_entrega, 
    e.codigo_rastreio
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN entregas e ON p.id_pedido = e.id_pedido
ORDER BY p.id_pedido;

-- 5️⃣ Pedidos com valor acima de 2000
SELECT 
    p.id_pedido, 
    c.nome AS cliente,
    SUM(i.quantidade * i.preco_unitario) AS valor_total
FROM pedidos p
JOIN itens_pedido i ON p.id_pedido = i.id_pedido
JOIN clientes c ON p.id_cliente = c.id_cliente
GROUP BY p.id_pedido, c.nome
HAVING valor_total > 2000
ORDER BY valor_total DESC;

-- 6️⃣ Clientes PF vs PJ
SELECT 
    tipo_cliente, 
    COUNT(*) AS total_clientes
FROM clientes
GROUP BY tipo_cliente;

-- 7️⃣ Algum vendedor também é fornecedor? (se houver tabela de vendedores)
-- Como não temos vendedores ainda, vou deixar exemplo de junção futura:
-- SELECT v.nome AS vendedor, f.nome AS fornecedor
-- FROM vendedores v
-- JOIN fornecedores f ON v.nome = f.nome;

-- 8️⃣ Relação de produtos por pedido
SELECT 
    p.id_pedido, 
    c.nome AS cliente, 
    pr.nome AS produto, 
    i.quantidade, 
    i.preco_unitario,
    (i.quantidade * i.preco_unitario) AS subtotal
FROM pedidos p
JOIN clientes c ON p.id_cliente = c.id_cliente
JOIN itens_pedido i ON p.id_pedido = i.id_pedido
JOIN produtos pr ON i.id_produto = pr.id_produto
ORDER BY p.id_pedido, pr.nome;

