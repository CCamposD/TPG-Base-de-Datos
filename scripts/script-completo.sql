-- 1. CREACIÓN DE TABLAS

CREATE TABLE categorias (
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(255) NOT NULL
);

CREATE TABLE productos (
    id_producto SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(255) NOT NULL,
    id_categoria INTEGER NOT NULL,
    precio REAL NOT NULL,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);

CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre_cliente VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefono VARCHAR(20) NOT NULL
);

CREATE TABLE pedidos (
    id_pedido SERIAL PRIMARY KEY,
    fecha_pedido DATE NOT NULL,
    id_cliente INTEGER NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_pedido (
    id_detalle_pedido SERIAL PRIMARY KEY,
    id_pedido INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL,
    precio_unitario NUMERIC(10, 2) NOT NULL,  -- precio al momento de la compra
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- 2. CARGA DE DATOS DE PRUEBA

INSERT INTO categorias (nombre_categoria) VALUES
('Zapatos'),
('Ropa'),
('Electronica'),
('Herramientas'),
('Juguetes');

INSERT INTO productos (nombre_producto, id_categoria, precio) VALUES
('Nike', 1, 100.00),
('Puma', 1, 120.00),
('Adidas', 1, 110.00),
('Sudadera', 2, 30.00),
('Pantalon', 2, 40.00),
('Camisa', 2, 20.00),
('Samsung TV', 3, 800.00),
('Playstation', 3, 500.00),
('Xbox', 3, 600.00),
('Iphone', 3, 1000.00),
('Pala', 4, 20.00),
('Alicate', 4, 15.00),
('Llave', 4, 10.00),
('Muñeca', 5, 15.00),
('Peluche', 5, 10.00),
('Juguete', 5, 20.00),
('Balon', 5, 5.00),
('Raqueta', 5, 25.00),
('Bicicleta', 5, 100.00),
('Monopatines', 5, 50.00);

-- 10.000 clientes
INSERT INTO clientes (nombre_cliente, direccion, telefono)
SELECT
    'Cliente ' || i,
    'Direccion ' || i,
    '11111' || i
FROM generate_series(1, 10000) AS i;

-- 200.000 pedidos entre 2022 y 2023
INSERT INTO pedidos (fecha_pedido, id_cliente)
SELECT
    DATE '2022-01-01' + ((i - 1) % 730),
    ((i - 1) % 10000) + 1
FROM generate_series(1, 200000) AS i;

-- Diez detalles por pedido
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario)
SELECT
    ((i - 1) / 10) + 1,
    ((i - 1) % 20) + 1,
    ((i - 1) % 10) + 1,
    p.precio
FROM generate_series(1, 2000000) AS i
JOIN productos p ON p.id_producto = ((i - 1) % 20) + 1;

ANALYZE;

-- 3. CONSULTAS ORIGINALES SIN OPTIMIZAR + EXPLAIN ANALYZE

-- Consulta 1: Productos más vendidos en un rango de fechas
EXPLAIN ANALYZE
SELECT p.nombre_producto, SUM(dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
JOIN pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE ped.fecha_pedido BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.nombre_producto
ORDER BY total_vendido DESC;

-- Consulta 2: Total vendido por mes
EXPLAIN ANALYZE
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
JOIN pedidos ped ON dp.id_pedido = ped.id_pedido
GROUP BY mes
ORDER BY mes;

-- Consulta 3: Pedidos de un cliente específico
EXPLAIN ANALYZE
SELECT ped.id_pedido, ped.fecha_pedido, p.nombre_producto, dp.cantidad
FROM pedidos ped
JOIN detalle_pedido dp ON ped.id_pedido = dp.id_pedido
JOIN productos p ON dp.id_producto = p.id_producto
WHERE ped.id_cliente = 1;

-- Consulta 4: Ventas agrupadas por categoría
EXPLAIN ANALYZE
SELECT c.nombre_categoria, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM categorias c
JOIN productos p ON c.id_categoria = p.id_categoria
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
GROUP BY c.nombre_categoria
ORDER BY total_vendido DESC;

-- 4. CREACIÓN DE ÍNDICES

CREATE INDEX idx_pedidos_fecha_id
    ON pedidos (fecha_pedido, id_pedido);

CREATE INDEX idx_pedidos_cliente_id
    ON pedidos (id_cliente, id_pedido)
    INCLUDE (fecha_pedido);

CREATE INDEX idx_detalle_pedido_cubriendo
    ON detalle_pedido (id_pedido, id_producto)
    INCLUDE (cantidad, precio_unitario);

CREATE INDEX idx_productos_categoria
    ON productos (id_categoria, id_producto);

ANALYZE;

-- 5. CONSULTAS OPTIMIZADAS + EXPLAIN ANALYZE

-- Consulta 1 optimizada: Productos más vendidos en un rango de fechas
EXPLAIN ANALYZE
WITH ventas_por_producto AS (
    SELECT dp.id_producto, SUM(dp.cantidad) AS total_vendido
    FROM pedidos ped
    JOIN detalle_pedido dp ON dp.id_pedido = ped.id_pedido
    WHERE ped.fecha_pedido >= DATE '2022-01-01'
      AND ped.fecha_pedido < DATE '2022-02-01'
    GROUP BY dp.id_producto
)
SELECT p.nombre_producto, vpp.total_vendido
FROM productos p
JOIN ventas_por_producto vpp ON vpp.id_producto = p.id_producto
ORDER BY vpp.total_vendido DESC;

-- Consulta 2 optimizada: Total vendido por mes
EXPLAIN ANALYZE
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM detalle_pedido dp
JOIN pedidos ped ON dp.id_pedido = ped.id_pedido
GROUP BY mes
ORDER BY mes;

-- Consulta 3 optimizada: Pedidos de un cliente específico
EXPLAIN ANALYZE
SELECT ped.id_pedido, ped.fecha_pedido, p.nombre_producto, dp.cantidad
FROM pedidos ped
JOIN detalle_pedido dp ON ped.id_pedido = dp.id_pedido
JOIN productos p ON dp.id_producto = p.id_producto
WHERE ped.id_cliente = 1;

-- Consulta 4 optimizada: Ventas agrupadas por categoría
EXPLAIN ANALYZE
WITH ventas_por_producto AS (
    SELECT id_producto,
           SUM(precio_unitario * cantidad) AS total_vendido
    FROM detalle_pedido
    GROUP BY id_producto
)
SELECT c.nombre_categoria, SUM(vpp.total_vendido) AS total_vendido
FROM categorias c
JOIN productos p ON c.id_categoria = p.id_categoria
JOIN ventas_por_producto vpp ON p.id_producto = vpp.id_producto
GROUP BY c.id_categoria, c.nombre_categoria
ORDER BY total_vendido DESC;

-- Resultados y comparación:
-- results/mediciones.md
-- results/explain-before.txt
-- results/explain-after.txt
