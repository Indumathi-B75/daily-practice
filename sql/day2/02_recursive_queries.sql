-- DAY 12: Recursive CTE
-- Task: Traverse the complete employee hierarchy

WITH RECURSIVE org_tree AS (

    -- 1. Anchor query: Find the top-level manager
    SELECT
        emp_id,
        name,
        position,
        manager_id,
        1 AS depth,
        ARRAY[emp_id] AS path
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- 2. Recursive query: Find employees reporting to current employees
    SELECT
        e.emp_id,
        e.name,
        e.position,
        e.manager_id,
        ot.depth + 1,
        ot.path || e.emp_id
    FROM employees e
    JOIN org_tree ot
        ON e.manager_id = ot.emp_id
)

-- 3. Display complete hierarchy
SELECT
    emp_id,
    REPEAT('    ', depth - 1) || name AS employee_hierarchy,
    position,
    manager_id,
    depth,
    path
FROM org_tree
ORDER BY path;

-- Cycle detection demonstration

WITH RECURSIVE org_tree AS (

    SELECT
        emp_id,
        name,
        manager_id,
        ARRAY[emp_id] AS path,
        false AS cycle
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.emp_id,
        e.name,
        e.manager_id,
        ot.path || e.emp_id,
        e.emp_id = ANY(ot.path)
    FROM employees e
    JOIN org_tree ot
        ON e.manager_id = ot.emp_id
    WHERE NOT ot.cycle
)

SELECT *
FROM org_tree
ORDER BY path;
