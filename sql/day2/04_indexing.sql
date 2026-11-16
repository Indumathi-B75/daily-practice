-- DAY 12: B-tree Index Optimization

-- Create B-tree index
CREATE INDEX idx_benchmark_manager_id
ON employees_benchmark USING BTREE (manager_id);

-- Update planner statistics
ANALYZE employees_benchmark;

-- AFTER INDEX: Check execution plan
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM employees_benchmark
WHERE manager_id = 105;
