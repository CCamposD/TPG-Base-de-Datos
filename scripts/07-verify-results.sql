-- ============================================================
-- TP: Optimización de Consultas SQL
-- Script: Verificación de equivalencia semántica
-- ============================================================
-- Cada par de tablas temporales contiene el resultado de la versión
-- original y de la optimizada. EXCEPT en ambos sentidos garantiza que
-- no existan filas agregadas, quitadas ni modificadas por la optimización.

\set ON_ERROR_STOP on

CREATE TEMP TABLE q1_original AS
SELECT p.nombre_producto, SUM(dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON dp.id_producto = p.id_producto
JOIN pedidos ped ON ped.id_pedido = dp.id_pedido
WHERE ped.fecha_pedido BETWEEN DATE '2022-01-01' AND DATE '2022-01-31'
GROUP BY p.nombre_producto;

CREATE TEMP TABLE q1_optimizada AS
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
JOIN ventas_por_producto vpp ON vpp.id_producto = p.id_producto;

CREATE TEMP TABLE q2_original AS
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes,
       SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM productos p
JOIN detalle_pedido dp ON dp.id_producto = p.id_producto
JOIN pedidos ped ON ped.id_pedido = dp.id_pedido
GROUP BY mes;

CREATE TEMP TABLE q2_optimizada AS
SELECT EXTRACT(MONTH FROM ped.fecha_pedido) AS mes,
       SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM detalle_pedido dp
JOIN pedidos ped ON ped.id_pedido = dp.id_pedido
GROUP BY mes;

CREATE TEMP TABLE q3_original AS
SELECT ped.id_pedido, ped.fecha_pedido, p.nombre_producto, dp.cantidad
FROM pedidos ped
JOIN detalle_pedido dp ON dp.id_pedido = ped.id_pedido
JOIN productos p ON p.id_producto = dp.id_producto
WHERE ped.id_cliente = 1;

CREATE TEMP TABLE q3_optimizada AS
SELECT ped.id_pedido, ped.fecha_pedido, p.nombre_producto, dp.cantidad
FROM pedidos ped
JOIN detalle_pedido dp ON dp.id_pedido = ped.id_pedido
JOIN productos p ON p.id_producto = dp.id_producto
WHERE ped.id_cliente = 1;

CREATE TEMP TABLE q4_original AS
SELECT c.nombre_categoria,
       SUM(dp.precio_unitario * dp.cantidad) AS total_vendido
FROM categorias c
JOIN productos p ON p.id_categoria = c.id_categoria
JOIN detalle_pedido dp ON dp.id_producto = p.id_producto
GROUP BY c.nombre_categoria;

CREATE TEMP TABLE q4_optimizada AS
WITH ventas_por_producto AS (
    SELECT id_producto,
           SUM(precio_unitario * cantidad) AS total_vendido
    FROM detalle_pedido
    GROUP BY id_producto
)
SELECT c.nombre_categoria, SUM(vpp.total_vendido) AS total_vendido
FROM categorias c
JOIN productos p ON p.id_categoria = c.id_categoria
JOIN ventas_por_producto vpp ON vpp.id_producto = p.id_producto
GROUP BY c.id_categoria, c.nombre_categoria;

DO $$
DECLARE
    diferencias bigint;
BEGIN
    SELECT
        (SELECT COUNT(*) FROM (SELECT * FROM q1_original EXCEPT SELECT * FROM q1_optimizada) AS d1a) +
        (SELECT COUNT(*) FROM (SELECT * FROM q1_optimizada EXCEPT SELECT * FROM q1_original) AS d1b) +
        (SELECT COUNT(*) FROM (SELECT * FROM q2_original EXCEPT SELECT * FROM q2_optimizada) AS d2a) +
        (SELECT COUNT(*) FROM (SELECT * FROM q2_optimizada EXCEPT SELECT * FROM q2_original) AS d2b) +
        (SELECT COUNT(*) FROM (SELECT * FROM q3_original EXCEPT SELECT * FROM q3_optimizada) AS d3a) +
        (SELECT COUNT(*) FROM (SELECT * FROM q3_optimizada EXCEPT SELECT * FROM q3_original) AS d3b) +
        (SELECT COUNT(*) FROM (SELECT * FROM q4_original EXCEPT SELECT * FROM q4_optimizada) AS d4a) +
        (SELECT COUNT(*) FROM (SELECT * FROM q4_optimizada EXCEPT SELECT * FROM q4_original) AS d4b)
    INTO diferencias;

    IF diferencias <> 0 THEN
        RAISE EXCEPTION 'La verificación falló: se detectaron % diferencias.', diferencias;
    END IF;
END;
$$;

\echo 'Verificación completada: las cuatro consultas optimizadas preservan los resultados.'
