-- ============================================================
-- TP: Optimización de Consultas SQL
-- Materia: Base de Datos - Cátedra Merlino - 1C 2026
-- Script: Creación de índices
-- Ejecutar después de 04-explain-original.sql
-- ============================================================

-- Búsqueda de pedidos por fecha
CREATE INDEX idx_pedidos_fecha_id
    ON pedidos (fecha_pedido, id_pedido);

-- Búsqueda de pedidos por cliente
CREATE INDEX idx_pedidos_cliente_id
    ON pedidos (id_cliente, id_pedido)
    INCLUDE (fecha_pedido);

-- Evita volver a la tabla para obtener cantidad y precio
CREATE INDEX idx_detalle_pedido_cubriendo
    ON detalle_pedido (id_pedido, id_producto)
    INCLUDE (cantidad, precio_unitario);

CREATE INDEX idx_productos_categoria
    ON productos (id_categoria, id_producto);

ANALYZE;
