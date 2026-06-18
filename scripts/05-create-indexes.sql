-- ============================================================
-- TP: Optimización de Consultas SQL
-- Materia: Base de Datos - Cátedra Merlino - 1C 2026
-- Script: Creación de índices
-- ============================================================

CREATE INDEX idx_fecha_pedido  ON pedidos        (fecha_pedido);
CREATE INDEX idx_id_cliente    ON pedidos        (id_cliente);
CREATE INDEX idx_id_pedido     ON detalle_pedido (id_pedido);
CREATE INDEX idx_id_producto   ON detalle_pedido (id_producto);
CREATE INDEX idx_id_categoria  ON productos      (id_categoria);
