-- ============================================================
-- TP: Optimización de Consultas SQL
-- Script: Reinicio seguro del esquema de trabajo
-- ============================================================
-- Se usa exclusivamente para reconstruir el ambiente de medición.
-- No ejecutar sobre una base que contenga información productiva.

DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS clientes CASCADE;
DROP TABLE IF EXISTS categorias CASCADE;
