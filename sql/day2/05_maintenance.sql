-- DAY 12: Database Maintenance

-- Reclaim reusable space and update visibility information
VACUUM employees_benchmark;

-- Collect updated statistics
ANALYZE employees_benchmark;

-- Combined operation
VACUUM ANALYZE employees_benchmark;

-- Verify table statistics
SELECT
    relname,
    reltuples,
    relpages
FROM pg_class
WHERE relname = 'employees_benchmark';
