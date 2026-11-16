# DAY 12 — PostgreSQL Advanced SQL

## Topics Covered
1. Recursive CTEs (`WITH RECURSIVE`)
2. Anchor and recursive terms
3. Hierarchical tree traversal
4. Depth and path tracking
5. Cycle detection
6. EXPLAIN and EXPLAIN ANALYZE
7. Sequential Scan vs Index Scan
8. B-tree indexing
9. Bitmap Index Scan and Bitmap Heap Scan
10. VACUUM and ANALYZE

## 1. Recursive Queries

A recursive CTE allows PostgreSQL to traverse hierarchical data using repeated execution of a recursive query.

Main components:
- Anchor query: identifies starting records.
- UNION ALL: combines anchor and recursive results.
- Recursive term: retrieves related records using the previous iteration.

Practical implementation: Employee organizational hierarchy.

Table: employees

Columns:
- emp_id
- name
- position
- manager_id
- salary

Additional tracking:
- depth: hierarchy level.
- path: array containing the employee traversal path.

## 2. Cycle Detection

Used to identify repeated nodes in recursive traversal.

Important expressions:

`ARRAY[emp_id]` — initializes the path.

`path || e.emp_id` — appends an employee ID.

`e.emp_id = ANY(path)` — checks whether an ID already exists in the path.

`WHERE NOT cycle` — prevents further expansion of cyclic paths.

## 3. EXPLAIN ANALYZE

EXPLAIN displays the estimated execution plan.

EXPLAIN ANALYZE executes the query and displays actual execution information.

Important fields:
- cost: estimated planner cost.
- rows: estimated rows.
- width: estimated row width in bytes.
- actual time: measured execution time.
- loops: number of node executions.
- Buffers: shared memory buffer activity.

## 4. Scan Types

### Sequential Scan
Reads the table sequentially and checks filter conditions.

### Index Scan
Uses an index to locate matching table rows.

### Bitmap Index Scan
Builds a bitmap containing matching tuple locations.

### Bitmap Heap Scan
Fetches matching heap pages using the bitmap.

PostgreSQL selects the execution strategy based on estimated cost.

## 5. B-tree Indexing

Created an index:

`CREATE INDEX idx_benchmark_manager_id ON employees_benchmark USING BTREE (manager_id);`

B-tree indexes support equality and range conditions.

An index does not guarantee an Index Scan. PostgreSQL chooses the cheapest estimated access path.

## 6. Performance Benchmark

Dataset: employees_benchmark

Records: 500,000

Query:

`SELECT * FROM employees_benchmark WHERE manager_id = 105;`

### Before Indexing

- Scan: Parallel Sequential Scan
- Estimated rows: 496
- Actual rows: 500
- Execution time: 30.581 ms

### After Indexing

- Scan: Bitmap Index Scan + Bitmap Heap Scan
- Estimated rows: 498
- Actual rows: 500
- Execution time: 4.338 ms

### Performance Comparison

- Speedup: approximately 7.05x
- Execution-time reduction: approximately 85.8%

These are observed single-run measurements, not a controlled repeated benchmark.

## 7. Database Maintenance

VACUUM:
- Reclaims dead tuple space for reuse.
- Maintains visibility information.

ANALYZE:
- Collects table statistics.
- Helps PostgreSQL estimate query selectivity.

Combined command:

`VACUUM ANALYZE employees_benchmark;`

Final catalog statistics:
- reltuples: 500000
- relpages: 9616

## 8. Key Learnings

1. Recursive CTEs solve hierarchical data traversal.
2. Anchor queries define recursive starting points.
3. Path arrays help track traversal history.
4. EXPLAIN ANALYZE reveals actual query execution behavior.
5. Sequential scans can be more efficient for small tables.
6. B-tree indexes improve selective data retrieval.
7. Bitmap scans are useful for retrieving multiple matching rows.
8. VACUUM ANALYZE supports database maintenance and planner statistics.

## Conclusion

Successfully implemented recursive SQL queries, analyzed PostgreSQL execution plans, created B-tree indexes, benchmarked a 500,000-row dataset and performed database maintenance.

Day 12 practical objectives completed.
