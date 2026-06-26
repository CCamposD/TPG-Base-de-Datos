# Optimización de Consultas SQL en una Base de Datos de Ventas y Pedidos

**Materia:** Base de Datos — Cátedra Merlino  
**Cuatrimestre:** 1er cuatrimestre 2026

---

## Integrantes

| Nombre | Legajo |
| --- | --- |
| Camilo Ignacio Campos Durán | 109 368 |
| Cristina Machasilla | 112 594 |
| Carolina Aramayo | 106 260 |
| Brero Joaquin | 110 916 |
| Víctor Andre Oliva Montaño | 112 748 |

---

## Checklist de entregables

| # | Entregable | Estado | Archivo |
| --- | --- | --- | --- |
| 1 | Descripción del problema | [**LISTO**](./document/problema.md) | `document/problema.md` |
| 2 | Modelo de datos / Diagrama ER | [**LISTO**](./imgs/diagrama_er_clasico_ventas_v2.png) | `imgs/diagrama_er_clasico_ventas_v2.png` |
| 3 | Script de creación de tablas | [**LISTO**](./scripts/01-create-tables.sql) | `scripts/01-create-tables.sql` |
| 4 | Script de carga de datos | [**LISTO**](./scripts/02-load-data.sql) | `scripts/02-load-data.sql` |
| 5 | Consultas originales | [**LISTO**](./scripts/03-original-queries.sql) | `scripts/03-original-queries.sql` |
| 6 | Planes de ejecución / mediciones iniciales | [**LISTO**](./results/explain-before.txt) | `results/explain-before.txt` |
| 7 | Consultas optimizadas | [**LISTO**](./scripts/06-optimized-queries.sql) | `scripts/06-optimized-queries.sql` |
| 8 | Comparación de tiempos antes y después | [**LISTO**](./results/mediciones.md) | `results/mediciones.md` |
| 9 | Conclusiones sobre las mejoras aplicadas | [**LISTO**](./document/conclusiones.md) | `document/conclusiones.md` |

---

## Datos utilizados

La carga de prueba genera datos determinísticos para que las mediciones puedan
repetirse:

- 10.000 clientes.
- 200.000 pedidos.
- 2.000.000 de detalles de pedido.

Después de la carga y de la creación de índices se ejecuta `ANALYZE` para
actualizar las estadísticas del optimizador.

## Resultados

Las mediciones se realizaron con PostgreSQL 16.14 mediante
`EXPLAIN (ANALYZE, BUFFERS)`.

| Consulta | Antes | Después | Mejora |
| --- | ---: | ---: | ---: |
| Productos más vendidos por fecha | 364,447 ms | 61,458 ms | 83,14 % |
| Total vendido por mes | 1706,348 ms | 1300,889 ms | 23,76 % |
| Pedidos de un cliente | 309,181 ms | 0,377 ms | 99,88 % |
| Ventas por categoría | 1330,589 ms | 631,670 ms | 52,53 % |

El detalle de cada problema, la optimización aplicada y los cambios en los
planes está en [`results/mediciones.md`](./results/mediciones.md).

---

## Estructura del proyecto

``` md
TP_Base_de_Datos/
├── README.md
├── document/
│   ├── propuesta.pdf
│   └── informe.pdf (generado desde ../main.tex)
├── imgs/
│   └── diagrama_er_clasico_ventas_v2.png
├── results/
│   ├── explain-before.txt
│   ├── explain-after.txt
│   └── mediciones.md
└── scripts/
    ├── 00-reset.sql
    ├── 01-create-tables.sql
    ├── 02-load-data.sql
    ├── 03-original-queries.sql
    ├── 04-explain-original.sql
    ├── 05-create-indexes.sql
    ├── 06-optimized-queries.sql
    ├── 07-verify-results.sql
    └── script-completo.sql
```

---

## Orden de ejecución de los scripts

```bash
psql -U usuario -d base_de_datos -f scripts/01-create-tables.sql
psql -U usuario -d base_de_datos -f scripts/02-load-data.sql
psql -U usuario -d base_de_datos -f scripts/03-original-queries.sql
psql -U usuario -d base_de_datos -f scripts/04-explain-original.sql
psql -U usuario -d base_de_datos -f scripts/05-create-indexes.sql
psql -U usuario -d base_de_datos -f scripts/06-optimized-queries.sql
```

También se puede crear, cargar y medir todo con un único archivo:

```bash
psql -U usuario -d base_de_datos -f scripts/script-completo.sql
```

El orquestador activa `ON_ERROR_STOP`, reconstruye el esquema y al final
ejecuta `07-verify-results.sql`. Este último compara cada consulta original
contra su versión optimizada mediante `EXCEPT` en ambos sentidos y aborta si
detecta diferencias.

## Ejecución reproducible

Para simplificar el uso durante la corrección también se incluyó un `Makefile`:

```bash
make all DB=base_de_datos USER=usuario
```

Los targets `reset`, `schema`, `load`, `before`, `indexes`, `after` y `verify`
permiten ejecutar cada etapa por separado. `reset` y `all` eliminan las tablas
del experimento, por lo que deben utilizarse únicamente en la base destinada
al TP.
