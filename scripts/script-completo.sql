-- ============================================================
-- TP: Optimización de Consultas SQL
-- Orquestador de ejecución reproducible
-- ============================================================
-- Ejecutar desde cualquier directorio:
-- psql -v ON_ERROR_STOP=1 -U usuario -d base_de_datos -f scripts/script-completo.sql

\set ON_ERROR_STOP on

\echo '==> Reiniciando esquema'
\ir 00-reset.sql
\echo '==> Creando tablas'
\ir 01-create-tables.sql
\echo '==> Cargando datos determinísticos'
\ir 02-load-data.sql
\echo '==> Midiendo consultas originales'
\ir 04-explain-original.sql
\echo '==> Creando índices'
\ir 05-create-indexes.sql
\echo '==> Midiendo consultas optimizadas'
\ir 06-optimized-queries.sql
\echo '==> Verificando equivalencia de resultados'
\ir 07-verify-results.sql

\echo '==> Experimento finalizado correctamente'
