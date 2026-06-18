# Promps

## Primer prompt

```md
Soy estudiante de Base de Datos. Tengo que hacer un TP sobre optimización de consultas SQL
en una base de datos de ventas y pedidos. La base tiene 5 tablas: clientes, pedidos,
productos, categorias y detalle_pedido.

Necesito que me des una base sólida y completa para arrancar el TP, que incluya:

1. El script SQL para crear las 5 tablas con claves primarias y foráneas (usa PostgreSQL).
2. Un script para cargar datos de prueba realistas (al menos 1000 filas en detalle_pedido
   para que se noten diferencias de rendimiento).
3. Cuatro consultas SQL sin optimizar que simulen reportes reales: productos más vendidos
   en un rango de fechas, total vendido por mes, pedidos de un cliente específico,
   y ventas agrupadas por categoría.
4. Para cada consulta, el comando EXPLAIN ANALYZE para ver el plan de ejecución.
5. Las versiones optimizadas de cada consulta con sus índices correspondientes.
6. Una tabla comparativa mostrando qué problema tenía cada consulta y qué mejora se aplicó.

Explicá brevemente cada sección para que pueda entender qué estoy haciendo y por qué.
Usá comentarios en el código SQL.

```
