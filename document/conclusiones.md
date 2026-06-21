# Conclusiones sobre las mejoras aplicadas

## Resumen general

El trabajo demostró que una consulta SQL puede ser lógicamente correcta y
producir resultados exactos, pero consumir un tiempo de ejecución muy superior
al necesario cuando el motor no dispone de la información estructural adecuada.
Las cuatro consultas analizadas ilustran ese principio desde ángulos diferentes:
acceso selectivo por fecha, agregación total, filtro por clave foránea y
agrupamiento por jerarquía de categorías.

Las mejoras aplicadas se agruparon en dos estrategias complementarias:

- **Creación de índices**: para eliminar recorridos secuenciales en columnas
  usadas en cláusulas `WHERE` y en condiciones de `JOIN`.
- **Reescritura de consultas**: para reducir el volumen de filas que participan
  en los joins y eliminar joins que no aportaban columnas ni filtros.

La combinación de ambas estrategias produjo una reducción global de los tiempos
de ejecución, con mejoras que van desde el 23 % hasta el 99 % según la
selectividad de cada consulta.

---

## Análisis por consulta

### Consulta 1 — Productos más vendidos en un rango de fechas

**Mejora:** 364,447 ms → 61,458 ms **(−83 %)**

La versión original realizaba un `Parallel Seq Scan` sobre los 2.000.000 de
registros de `detalle_pedido` y sobre los 200.000 registros de `pedidos`,
filtrando por fecha recién después del join. Esto significaba que el motor
procesaba toda la tabla antes de descartar las filas fuera del rango.

Se aplicaron dos cambios:

1. **Índice compuesto `idx_pedidos_fecha_id (fecha_pedido, id_pedido)`**: permite
   al motor localizar sólo los pedidos del período con un `Bitmap Index Scan`,
   reduciendo las filas accedidas de ~200.000 a ~8.500.
2. **Índice cubriente `idx_detalle_pedido_cubriendo (id_pedido, id_producto)
   INCLUDE (cantidad, precio_unitario)`**: convirtió el acceso a `detalle_pedido`
   en un `Index Only Scan`, evitando visitas al heap.
3. **Reescritura con CTE**: la agregación se realiza sobre `id_producto` antes
   de unirse con la tabla `productos`, reduciendo el número de filas que
   participan en el join final a solo 20.

Esta consulta fue la que más se benefició de combinar índices selectivos con
una reestructuración del orden de las operaciones.

---

### Consulta 2 — Total vendido por mes

**Mejora:** 1.706,348 ms → 1.300,889 ms **(−24 %)**

Esta consulta es inherentemente costosa porque necesita recorrer los 2.000.000
de registros de `detalle_pedido` para calcular los totales mensuales; ningún
índice puede evitar ese acceso completo.

Sin embargo, la versión original incluía un `JOIN` innecesario con la tabla
`productos`: esa tabla no aportaba ninguna columna al resultado ni servía como
filtro. El optimizador la incorporaba igual al plan, generando un `Hash Join`
adicional que procesaba todos los detalles una vez más.

La mejora consistió exclusivamente en **eliminar ese join**, reduciendo el
número de joins de tres tablas a dos. El plan resultante mantiene el
`Parallel Seq Scan` sobre `detalle_pedido` (inevitable), pero elimina el
`Hash Join` superfluo con `productos`.

La mejora es menor que en las demás consultas porque la operación dominante
—leer toda la tabla— no puede evitarse con índices.

---

### Consulta 3 — Pedidos de un cliente específico

**Mejora:** 309,181 ms → 0,377 ms **(−99,9 %)**

Esta fue la mejora más espectacular. La versión original realizaba:

- `Parallel Seq Scan` completo sobre `pedidos` (200.000 filas) para encontrar
  los 20 pedidos del cliente 1.
- `Parallel Seq Scan` completo sobre `detalle_pedido` (2.000.000 filas) para
  encontrar los 200 detalles correspondientes.

El filtro era extremadamente selectivo (el 0,01 % de las filas), pero sin un
índice el motor no tenía forma de saberlo de antemano.

Se crearon dos índices cubrientes:

1. **`idx_pedidos_cliente_id (id_cliente, id_pedido) INCLUDE (fecha_pedido)`**:
   permite localizar los 20 pedidos del cliente con un `Index Only Scan` sin
   tocar el heap.
2. **`idx_detalle_pedido_cubriendo (id_pedido, id_producto) INCLUDE (cantidad,
   precio_unitario)`**: resuelve la búsqueda de los detalles también con
   `Index Only Scan`.

La palabra clave aquí es **selectividad**: cuando un filtro devuelve una
fracción muy pequeña de la tabla, un índice adecuado elimina casi por completo
el costo de la consulta.

---

### Consulta 4 — Ventas agrupadas por categoría

**Mejora:** 1.330,589 ms → 631,670 ms **(−53 %)**

La versión original unía primero `detalle_pedido` (2.000.000 filas) con
`productos` y luego con `categorias`, acumulando un conjunto de filas enorme
antes de agregar. Cada una de las 2.000.000 filas participaba en los joins con
las tablas de referencia.

La reescritura con CTE invirtió el orden lógico:

1. Se agrupan los 2.000.000 de detalles por `id_producto`, obteniendo 20 filas.
2. Esas 20 filas se unen con `productos` (20 filas) y luego con `categorias`
   (5 filas).

Esto significa que los joins costosos se hacen sobre conjuntos mínimos, no
sobre millones de filas. El recorrido completo de `detalle_pedido` sigue siendo
necesario para la agregación inicial, pero el resto del plan opera sobre datos
ya reducidos.

---

## Lecciones aprendidas

**Los índices son más útiles cuando el filtro es selectivo.** En las consultas 1
y 3, donde el `WHERE` descartaba más del 99 % de las filas, el impacto fue
enorme. En la consulta 2, donde había que procesar todo, el índice no hubiera
aportado nada.

**Un JOIN extra tiene costo aunque no aporte datos.** La consulta 2 incluía la
tabla `productos` sin necesidad; eliminarla redujo el tiempo en un 24 % sin
tocar ningún índice.

**El orden de las operaciones importa.** Agregar antes de unir —usando CTEs—
reduce drásticamente el volumen de filas que participan en los joins
posteriores. Esto fue determinante en las consultas 1 y 4.

**Los índices cubrientes eliminan accesos al heap.** Al incluir en el índice
todas las columnas que necesita la consulta (`INCLUDE`), el motor puede
resolver la búsqueda íntegramente desde el índice, sin leer las páginas de
datos. Eso fue clave en las consultas 1 y 3.

**`EXPLAIN ANALYZE` es la herramienta indispensable.** Sin leer el plan de
ejecución no habría sido posible detectar los `Seq Scan` innecesarios, los
joins superfluos ni el orden subóptimo de las operaciones. La optimización sin
medición es solo intuición.

---

## Posibles mejoras futuras

Dentro del alcance de este trabajo no se implementaron las siguientes
técnicas, que podrían mejorar aún más el rendimiento en escenarios de mayor
escala:

- **Vistas materializadas** para los totales por mes o por categoría, que se
  recalcularían periódicamente en lugar de computarse en cada consulta.
- **Particionamiento de tablas** por rango de fechas en `pedidos` y
  `detalle_pedido`, lo que permitiría al motor descartar particiones completas
  al filtrar por período.
- **Procedimientos almacenados** para encapsular las consultas frecuentes y
  reutilizar planes de ejecución cacheados.
- **Columnas calculadas persistidas** como el total de cada detalle
  (`precio_unitario * cantidad`), para evitar recalcularlo en cada ejecución
  de las consultas 2 y 4.