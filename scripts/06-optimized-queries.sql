-- ============================================================
-- TP: Optimización de Consultas SQL
-- Materia: Base de Datos - Cátedra Merlino - 1C 2026
-- Script: Consultas optimizadas + planes de ejecución DESPUÉS de índices
-- Ejecutar DESPUÉS de 05-create-indexes.sql
-- ============================================================

-- Consulta 1 optimizada: Productos más vendidos en un rango de fechas
EXPLAIN ANALYZE
SELECT p.nombre_producto, SUM(dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
JOIN pedidos ped ON dp.id_pedido = ped.id_pedido
WHERE ped.fecha_pedido BETWEEN '2022-01-01' AND '2022-01-31'
GROUP BY p.nombre_producto
ORDER BY total_vendido DESC;

-- Consulta 2 optimizada: Total vendido por mes
EXPLAIN ANALYZE
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
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
SELECT c.nombre_categoria, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM categorias c
JOIN productos p ON c.id_categoria = p.id_categoria
JOIN detalle_pedido dp ON p.id_producto = dp.id_producto
GROUP BY c.nombre_categoria
ORDER BY total_vendido DESC;
