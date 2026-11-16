-- DAY 12: Large Dataset for Performance Benchmarking

DROP TABLE IF EXISTS employees_benchmark;

CREATE TABLE employees_benchmark AS
SELECT
    gs AS emp_id,
    'Employee ' || gs AS name,
    ((gs % 1000) + 1)::INTEGER AS manager_id,
    repeat('x', 100) AS additional_data
FROM generate_series(1, 500000) AS gs;

-- Verify dataset size
SELECT COUNT(*) AS total_employees
FROM employees_benchmark;

-- Update statistics before baseline benchmark
VACUUM ANALYZE employees_benchmark;

-- BASELINE: Before index creation
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM employees_benchmark
WHERE manager_id = 105;
