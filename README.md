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
| 9 | Conclusiones sobre las mejoras aplicadas | [**FALTA**] | — |

---

## Estructura del proyecto

``` md
TP_Base_de_Datos/
├── README.md
├── document/
│   └── propuesta.pdf
├── imgs/
│   └── diagrama_er_clasico_ventas_v2.png
├── results/
│   ├── explain-before.txt
│   ├── explain-after.txt
│   └── mediciones.md
└── scripts/
    ├── 01-create-tables.sql
    ├── 02-load-data.sql
    ├── 03-original-queries.sql
    ├── 04-explain-original.sql
    ├── 05-create-indexes.sql
    └── 06-optimized-queries.sql
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
