-- DAY 12: Recursive Queries and Query Optimization

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(100),
    manager_id INTEGER,
    salary NUMERIC(10,2),

    CONSTRAINT fk_manager
        FOREIGN KEY (manager_id)
        REFERENCES employees(emp_id)
);

INSERT INTO employees
(emp_id, name, position, manager_id, salary)
VALUES
(101, 'Alice', 'CEO', NULL, 150000),
(102, 'Bob', 'CTO', 101, 120000),
(103, 'Carol', 'CFO', 101, 115000),
(104, 'David', 'Engineering Manager', 102, 95000),
(105, 'Emma', 'Senior Developer', 104, 80000),
(106, 'Frank', 'Developer', 105, 60000),
(107, 'Grace', 'Developer', 105, 62000),
(108, 'Henry', 'Finance Manager', 103, 90000),
(109, 'Ivy', 'Accountant', 108, 55000),
(110, 'Jack', 'Junior Developer', 106, 45000),
(111, 'Kate', 'DevOps Engineer', 104, 85000),
(112, 'Leo', 'Intern', 111, 25000);

-- Verify data
SELECT * FROM employees
ORDER BY emp_id;
