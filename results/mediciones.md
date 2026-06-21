# Mediciones antes y después de optimizar

## Entorno

- Motor: PostgreSQL 16.14, 64 bits.
- Datos: 10.000 clientes, 200.000 pedidos y 2.000.000 de detalles.
- Datos generados de forma determinística por `scripts/02-load-data.sql`.
- Estadísticas actualizadas con `ANALYZE`.
- Cada conjunto de consultas se ejecutó una vez para estabilizar la caché y una
  segunda vez para registrar los resultados.
- Medición: `EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)`.
- Se compararon los resultados con `EXCEPT` en ambos sentidos: las cuatro
  consultas optimizadas produjeron cero diferencias respecto de las originales.

Los planes completos registrados están disponibles en:

- [`explain-before.txt`](./explain-before.txt)
- [`explain-after.txt`](./explain-after.txt)

## Comparación

| Consulta | Tiempo antes | Problema detectado | Optimización aplicada | Tiempo después | Mejora |
| --- | ---: | --- | --- | ---: | ---: |
| 1. Productos más vendidos por fecha | 364,447 ms | `Seq Scan` sobre 2.000.000 de detalles y sobre todos los pedidos | Índices por fecha y pedido, filtro con intervalo semiabierto y agregación previa por producto | 61,458 ms | 83,14 % |
| 2. Total vendido por mes | 1706,348 ms | Join innecesario con `productos`; deben recorrerse todos los detalles para calcular el total | Eliminación del join que no aportaba columnas ni filtros | 1300,889 ms | 23,76 % |
| 3. Pedidos de un cliente | 309,181 ms | `Seq Scan` completo en `pedidos` y `detalle_pedido` para devolver solamente 200 filas | Índices cubrientes sobre cliente, pedido y detalle | 0,377 ms | 99,88 % |
| 4. Ventas por categoría | 1330,589 ms | Los 2.000.000 de detalles se unían con productos y categorías antes de agregarse | Agregación por producto antes de los joins con las tablas pequeñas | 631,670 ms | 52,53 % |

La mejora porcentual se calculó como:

```text
((tiempo_antes - tiempo_despues) / tiempo_antes) * 100
```

## Cambios observados en los planes

### Consulta 1

Antes se utilizaron `Parallel Seq Scan` sobre `detalle_pedido` y `pedidos`.
Después, el filtro de fecha utiliza `Bitmap Index Scan` sobre
`idx_pedidos_fecha_id`, y el acceso a los detalles utiliza `Index Only Scan`
sobre `idx_detalle_pedido_cubriendo`.

### Consulta 2

Continúa siendo necesario recorrer `detalle_pedido`, porque el total mensual
usa todas sus filas. La mejora proviene de eliminar el `Hash Join` con
`productos`; por eso es menor que en las consultas selectivas.

### Consulta 3

Los recorridos secuenciales fueron reemplazados por `Index Only Scan` sobre
`idx_pedidos_cliente_id` e `idx_detalle_pedido_cubriendo`. Es la mejora más
grande porque el filtro devuelve una proporción muy pequeña de la tabla.

### Consulta 4

El recorrido completo de `detalle_pedido` sigue siendo necesario, pero ahora
la tabla se reduce a veinte totales por producto antes de unirla con
`productos` y `categorias`.

## Interpretación

Los índices producen el mayor beneficio cuando existe un filtro selectivo,
como fecha o cliente. En las consultas que procesan todas las ventas, un índice
no evita leer la tabla completa; allí la mejora depende principalmente de
eliminar joins innecesarios o reducir las filas mediante agregación temprana.
