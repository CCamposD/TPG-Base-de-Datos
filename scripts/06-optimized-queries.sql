-- ============================================================
-- TP: Optimización de Consultas SQL
-- Materia: Base de Datos - Cátedra Merlino - 1C 2026
-- Script: Consultas optimizadas y planes de ejecución
-- Ejecutar después de 05-create-indexes.sql
-- ============================================================

-- Se agrupa antes de unir con productos
\echo 'Consulta 1 - optimizada: productos más vendidos por fecha'
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
WITH ventas_por_producto AS (
    SELECT dp.id_producto, SUM(dp.cantidad) AS total_vendido
    FROM pedidos ped
    JOIN detalle_pedido dp ON dp.id_pedido = ped.id_pedido
    WHERE ped.fecha_pedido >= DATE '2022-01-01'
      AND ped.fecha_pedido <  DATE '2022-02-01'
    GROUP BY dp.id_producto
)
SELECT p.nombre_producto, vpp.total_vendido
FROM productos p
JOIN ventas_por_producto vpp ON vpp.id_producto = p.id_producto
ORDER BY vpp.total_vendido DESC;

-- El join con productos no aporta datos ni filtros
\echo 'Consulta 2 - optimizada: total vendido por mes'
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes, SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM detalle_pedido dp
JOIN pedidos ped ON dp.id_pedido = ped.id_pedido
GROUP BY mes
ORDER BY mes;

\echo 'Consulta 3 - optimizada: pedidos de un cliente'
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT ped.id_pedido, ped.fecha_pedido, p.nombre_producto, dp.cantidad
FROM pedidos ped
JOIN detalle_pedido dp ON ped.id_pedido = dp.id_pedido
JOIN productos p ON dp.id_producto = p.id_producto
WHERE ped.id_cliente = 1;

-- Se agrupan los detalles antes de unir productos y categorías
\echo 'Consulta 4 - optimizada: ventas por categoría'
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
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
