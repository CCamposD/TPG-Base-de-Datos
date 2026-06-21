-- ============================================================
-- TP: Optimización de Consultas SQL
-- Materia: Base de Datos - Cátedra Merlino - 1C 2026
-- Script: Carga de datos de prueba
-- Ejecutar después de 01-create-tables.sql
-- ============================================================

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
