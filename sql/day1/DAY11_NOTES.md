# Day 11 — PostgreSQL Advanced SQL
## Window Functions and Common Table Expressions (CTEs)

**Learning environment:** Ubuntu (WSL) + Docker + PostgreSQL  
**Database:** `day11_db`  
**Database user:** `day11_user`  
**Practice directory:** `~/sql/day11`

---

# 1. Learning Objectives

By completing this lesson, I learned:

1. What window functions are and why they are useful.
2. The difference between `GROUP BY` and window functions.
3. Ranking functions: `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.
4. How to retrieve previous and next row values using `LAG()` and `LEAD()`.
5. How to calculate running totals using `SUM() OVER()`.
6. How to use `PARTITION BY` and `ORDER BY`.
7. How to calculate day-over-day revenue changes and growth percentages.
8. How to create CTEs using `WITH`.
9. How to combine multiple CTEs with window functions.

---

# 2. PostgreSQL Environment Setup

## 2.1 Navigate to the SQL directory

```bash
cd ~/sql/day11
```

Check project files:

```bash
ls -la
```

## 2.2 Start PostgreSQL using Docker Compose

```bash
docker compose up -d
```

Check the running container:

```bash
docker compose ps
```

Check PostgreSQL readiness:

```bash
docker compose exec db pg_isready -U day11_user -d day11_db
```

## 2.3 Connect to PostgreSQL

```bash
docker compose exec db psql -U day11_user -d day11_db
```

Useful PostgreSQL commands:

```sql
\dt
```

Lists all tables.

```sql
\d sales
```

Displays the structure of the sales table.

```sql
\q
```

Exits PostgreSQL.

**Important:** Ubuntu commands run in the terminal. SQL statements run inside PostgreSQL or through a `.sql` file.

---

# 3. Practice Database

Three tables were created for this lesson.

## 3.1 Sales table

Stores individual sales transactions.

| Column | Description |
|---|---|
| sale_id | Unique sale identifier |
| sale_date | Date of the sale |
| salesperson | Name of salesperson |
| region | Sales region |
| amount | Sale amount |

Inspect the table:

```sql
SELECT * FROM sales ORDER BY sale_id;
```

Sample data:

| Sale ID | Date | Salesperson | Amount |
|---:|---|---|---:|
| 1 | 2026-01-01 | Anu | 1000 |
| 2 | 2026-01-01 | Ravi | 1500 |
| 3 | 2026-01-02 | Anu | 500 |
| 4 | 2026-01-02 | Ravi | 1500 |
| 5 | 2026-01-03 | Meena | 2000 |

There are 10 records in the sales table.

## 3.2 Products table

Stores product information.

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Product name |
| category_id | Product category |
| price | Product price |

Inspect:

```sql
SELECT * FROM products ORDER BY product_id;
```

There are 7 products. Some products have identical prices, which helps demonstrate ranking ties.

## 3.3 Orders table

Stores customer order information.

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer identifier |
| order_date | Order date |
| total_amount | Order amount |

Inspect:

```sql
SELECT * FROM orders ORDER BY order_id;
```

There are 6 orders belonging to 3 customers.

---

# 4. Introduction to Window Functions

## 4.1 What is a window function?

A window function performs a calculation across a set of related rows without combining those rows into a single result row.

It allows us to calculate rankings, previous values, next values, and running totals while retaining individual records.

### General syntax

```sql
function_name(column_name) OVER (
    PARTITION BY column_name
    ORDER BY column_name
)
```

### Important components

| Component | Purpose |
|---|---|
| Function | Performs the calculation |
| `OVER()` | Defines the window |
| `PARTITION BY` | Divides rows into independent groups |
| `ORDER BY` | Defines the order of rows |
| Frame clause | Defines which rows are included in a calculation |

## 4.2 GROUP BY versus Window Functions

| GROUP BY | Window Functions |
|---|---|
| Groups multiple rows into fewer rows | Preserves individual rows |
| Commonly used with aggregate functions | Used with ranking, navigation and aggregate functions |
| Produces one result per group | Can produce a result for every input row |

### Example 1: GROUP BY

```sql
SELECT
    salesperson,
    SUM(amount) AS total_sales
FROM sales
GROUP BY salesperson;
```

Returns one row for each salesperson.

### Example 2: Window Function

```sql
SELECT
    salesperson,
    amount,
    SUM(amount) OVER (
        PARTITION BY salesperson
    ) AS total_sales
FROM sales;
```

Returns every sale along with that salesperson's total sales.

---

# 5. Ranking Functions

Ranking functions assign positions to rows based on an ordering.

PostgreSQL provides three important ranking functions:

- `ROW_NUMBER()`
- `RANK()`
- `DENSE_RANK()`

## 5.1 ROW_NUMBER()

Assigns a unique sequential number to each row.

### Syntax

```sql
ROW_NUMBER() OVER (
    ORDER BY column_name
)
```

### Example

```sql
SELECT
    product_name,
    price,
    ROW_NUMBER() OVER (
        ORDER BY price DESC, product_id
    ) AS row_num
FROM products;
```

If two products have the same price, they still receive different row numbers.

## 5.2 RANK()

Assigns the same rank to tied values and skips subsequent rank numbers.

### Example

```sql
SELECT
    product_name,
    price,
    RANK() OVER (
        ORDER BY price DESC
    ) AS price_rank
FROM products;
```

If two products tie for rank 2, the next product receives rank 4.

## 5.3 DENSE_RANK()

Assigns the same rank to tied values without skipping subsequent rank numbers.

### Example

```sql
SELECT
    product_name,
    price,
    DENSE_RANK() OVER (
        ORDER BY price DESC
    ) AS dense_rank
FROM products;
```

If two products tie for rank 2, the next product receives rank 3.

## 5.4 Difference between ranking functions

Consider these prices:

| Product | Price |
|---|---:|
| Laptop A | 90000 |
| Laptop B | 80000 |
| Laptop C | 80000 |
| Laptop D | 70000 |

Expected ranking:

| Product | ROW_NUMBER | RANK | DENSE_RANK |
|---|---:|---:|---:|
| Laptop A | 1 | 1 | 1 |
| Laptop B | 2 | 2 | 2 |
| Laptop C | 3 | 2 | 2 |
| Laptop D | 4 | 4 | 3 |

**Remember:**

- `ROW_NUMBER()` gives unique numbers.
- `RANK()` leaves gaps after ties.
- `DENSE_RANK()` does not leave gaps after ties.

## 5.5 Ranking products by category

```sql
SELECT
    product_name,
    category_id,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY category_id
        ORDER BY price DESC, product_id
    ) AS row_num,
    RANK() OVER (
        PARTITION BY category_id
        ORDER BY price DESC
    ) AS price_rank,
    DENSE_RANK() OVER (
        PARTITION BY category_id
        ORDER BY price DESC
    ) AS dense_price_rank
FROM products
ORDER BY category_id, price DESC, product_id;
```

### Explanation

1. `PARTITION BY category_id` separates products by category.
2. `ORDER BY price DESC` ranks expensive products first.
3. `ROW_NUMBER()` assigns a unique number.
4. `RANK()` handles ties with gaps.
5. `DENSE_RANK()` handles ties without gaps.

The `product_id` in the `ROW_NUMBER()` ordering makes the numbering deterministic when prices are equal.

## 5.6 Find the top three distinct price ranks per category

```sql
WITH ranked_products AS (
    SELECT
        product_id,
        product_name,
        category_id,
        price,
        DENSE_RANK() OVER (
            PARTITION BY category_id
            ORDER BY price DESC
        ) AS price_rank
    FROM products
)
SELECT
    product_id,
    product_name,
    category_id,
    price,
    price_rank
FROM ranked_products
WHERE price_rank <= 3
ORDER BY category_id, price DESC, product_id;
```

### Explanation

- First, the CTE calculates product rankings.
- Then, the outer query filters products with ranks up to 3.
- `DENSE_RANK()` includes products with tied prices.

**Important:** Window functions cannot normally be filtered directly in the `WHERE` clause of the same query level. Use a CTE or subquery to calculate the ranking first.

---

# 6. LAG() and LEAD()

These functions retrieve values from preceding or following rows.

## 6.1 LAG()

`LAG()` retrieves a value from a previous row.

### Syntax

```sql
LAG(column_name) OVER (
    ORDER BY column_name
)
```

### Example

```sql
SELECT
    sale_date,
    amount,
    LAG(amount) OVER (
        ORDER BY sale_date, sale_id
    ) AS previous_amount
FROM sales;
```

This retrieves the previous sale amount.

## 6.2 LEAD()

`LEAD()` retrieves a value from the next row.

### Syntax

```sql
LEAD(column_name) OVER (
    ORDER BY column_name
)
```

### Example

```sql
SELECT
    sale_date,
    amount,
    LEAD(amount) OVER (
        ORDER BY sale_date, sale_id
    ) AS next_amount
FROM sales;
```

This retrieves the next sale amount.

If a previous or next row does not exist, the result is `NULL` by default.

## 6.3 Difference between LAG and LEAD

| LAG | LEAD |
|---|---|
| Retrieves a previous row's value | Retrieves a following row's value |
| Looks backward | Looks forward |
| Useful for previous-period comparisons | Useful for next-period comparisons |

---

# 7. Running Totals

A running total calculates the cumulative sum of values up to the current row.

## 7.1 General syntax

```sql
SUM(column_name) OVER (
    ORDER BY sort_column
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

### Frame explanation

- `UNBOUNDED PRECEDING`: Starts from the first row in the window partition.
- `CURRENT ROW`: Ends at the current row.
- `ROWS`: Uses individual rows to define the frame.

## 7.2 Example: Running revenue by date

```sql
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(amount) AS daily_revenue
    FROM sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM daily_sales
ORDER BY sale_date;
```

### Expected output

| Date | Daily revenue | Running revenue |
|---|---:|---:|
| Jan 1 | 2500 | 2500 |
| Jan 2 | 2000 | 4500 |
| Jan 3 | 2800 | 7300 |
| Jan 4 | 4000 | 11300 |
| Jan 5 | 1900 | 13200 |

### Example calculation

January 3:

```text
2500 + 2000 + 2800 = 7300
```

The running revenue on January 3 is 7300.

## 7.3 Running sales by salesperson

```sql
SELECT
    sale_id,
    sale_date,
    salesperson,
    amount,
    LAG(amount) OVER (
        PARTITION BY salesperson
        ORDER BY sale_date, sale_id
    ) AS previous_sale_amount,
    SUM(amount) OVER (
        PARTITION BY salesperson
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS salesperson_running_sales
FROM sales
ORDER BY salesperson, sale_date, sale_id;
```

### Explanation

`PARTITION BY salesperson` separates sales into individual salesperson groups.

The running total restarts for each salesperson.

### Example 1: Anu

```text
1000
1000 + 500 = 1500
1500 + 2000 = 3500
3500 + 700 = 4200
```

Final sales: 4200.

### Example 2: Ravi

```text
1500
1500 + 1500 = 3000
3000 + 800 = 3800
3800 + 1200 = 5000
```

Final sales: 5000.

---

# 8. Day-over-Day Revenue Analysis

This analysis compares daily revenue with the previous available date.

## 8.1 Revenue change formula

```text
Current revenue - Previous revenue
```

## 8.2 Growth percentage formula

```text
(Current revenue - Previous revenue)
------------------------------------ × 100
          Previous revenue
```

## 8.3 SQL query

```sql
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(amount) AS daily_revenue
    FROM sales
    GROUP BY sale_date
),
revenue_comparison AS (
    SELECT
        sale_date,
        daily_revenue,
        LAG(daily_revenue) OVER (
            ORDER BY sale_date
        ) AS previous_revenue
    FROM daily_sales
)
SELECT
    sale_date,
    daily_revenue,
    previous_revenue,
    daily_revenue - previous_revenue AS revenue_change,
    ROUND(
        (daily_revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY sale_date;
```

### Explanation

1. `daily_sales` calculates revenue for each date.
2. `revenue_comparison` uses `LAG()` to retrieve previous revenue.
3. The final query calculates revenue change.
4. The growth percentage is calculated using the formula.
5. `ROUND(..., 2)` rounds the result to two decimal places.
6. `NULLIF(previous_revenue, 0)` prevents division by zero.

### Example 1: January 2

```text
Current revenue  = 2000
Previous revenue = 2500

Revenue change = 2000 - 2500
               = -500

Growth = (-500 / 2500) × 100
       = -20%
```

### Example 2: January 4

```text
Current revenue  = 4000
Previous revenue = 2800

Revenue change = 4000 - 2800
               = 1200

Growth = (1200 / 2800) × 100
       = 42.86%
```

Expected growth percentages:

| Date | Growth |
|---|---:|
| Jan 1 | NULL |
| Jan 2 | -20.00% |
| Jan 3 | 40.00% |
| Jan 4 | 42.86% |
| Jan 5 | -52.50% |

---

# 9. Common Table Expressions (CTEs)

## 9.1 What is a CTE?

A Common Table Expression is a named result set defined using the `WITH` keyword.

It makes complex SQL queries easier to read and organize.

A CTE exists for the duration of the SQL statement in which it is defined. It is not a permanent table.

## 9.2 Basic syntax

```sql
WITH cte_name AS (
    SELECT ...
)
SELECT *
FROM cte_name;
```

## 9.3 Example: Customer lifetime spending

```sql
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    lifetime_spend
FROM customer_totals
ORDER BY lifetime_spend DESC;
```

### Explanation

1. `customer_totals` calculates the total spending for each customer.
2. `SUM(total_amount)` adds all order amounts.
3. `GROUP BY customer_id` groups orders by customer.
4. The outer query retrieves the customer totals.
5. `ORDER BY lifetime_spend DESC` sorts the highest spender first.

Expected results:

| Customer ID | Lifetime spend |
|---:|---:|
| 102 | 4500 |
| 101 | 3000 |
| 103 | 800 |

## 9.4 Chained CTEs

Multiple CTEs can be defined in the same query.

### Example: Rank customers by lifetime spending

```sql
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        lifetime_spend,
        DENSE_RANK() OVER (
            ORDER BY lifetime_spend DESC
        ) AS spending_rank
    FROM customer_totals
)
SELECT
    customer_id,
    lifetime_spend,
    spending_rank
FROM ranked_customers
ORDER BY spending_rank;
```

### Explanation

**CTE 1 — customer_totals**

Calculates the lifetime spending of every customer.

**CTE 2 — ranked_customers**

Uses the first CTE's output and assigns a spending rank.

**Final query**

Displays the ranked customer information.

The second CTE can use the first CTE because it is defined later in the same `WITH` statement.

## 9.5 CTE with customer running spending

```sql
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    LAG(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_customer_spend
FROM orders
ORDER BY customer_id, order_date, order_id;
```

This query shows:

- Each customer's order history.
- The previous order amount.
- The cumulative spending for each customer.

Example for customer 101:

```text
Order 1 = 1000
Order 2 = 1000 + 1500 = 2500
Order 3 = 1000 + 1500 + 500 = 3000
```

Final customer spending: 3000.

---

# 10. Day 11 Practice Exercises and Solutions

## Exercise 1: Rank salespeople by total sales

```sql
WITH salesperson_totals AS (
    SELECT
        salesperson,
        SUM(amount) AS total_sales
    FROM sales
    GROUP BY salesperson
)
SELECT
    salesperson,
    total_sales,
    ROW_NUMBER() OVER (
        ORDER BY total_sales DESC
    ) AS row_num,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank,
    DENSE_RANK() OVER (
        ORDER BY total_sales DESC
    ) AS dense_sales_rank
FROM salesperson_totals
ORDER BY total_sales DESC;
```

Expected totals:

| Salesperson | Total sales |
|---|---:|
| Ravi | 5000 |
| Anu | 4200 |
| Meena | 4000 |

There are no ties in this dataset, so all three ranking functions return ranks 1, 2, and 3.

## Exercise 2: Previous sale amount for each salesperson

```sql
SELECT
    sale_id,
    sale_date,
    salesperson,
    amount,
    LAG(amount) OVER (
        PARTITION BY salesperson
        ORDER BY sale_date, sale_id
    ) AS previous_sale_amount
FROM sales
ORDER BY salesperson, sale_date, sale_id;
```

`PARTITION BY salesperson` ensures that the previous sale belongs to the same salesperson.

## Exercise 3: Running revenue by date

```sql
WITH daily_revenue AS (
    SELECT
        sale_date,
        SUM(amount) AS revenue
    FROM sales
    GROUP BY sale_date
)
SELECT
    sale_date,
    revenue,
    SUM(revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM daily_revenue
ORDER BY sale_date;
```

## Exercise 3: Running spending by customer

```sql
SELECT
    customer_id,
    order_id,
    order_date,
    total_amount,
    SUM(total_amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_customer_spend
FROM orders
ORDER BY customer_id, order_date, order_id;
```

## Exercise 4: Day-over-day revenue change and growth

```sql
WITH daily_revenue AS (
    SELECT
        sale_date,
        SUM(amount) AS revenue
    FROM sales
    GROUP BY sale_date
),
revenue_comparison AS (
    SELECT
        sale_date,
        revenue,
        LAG(revenue) OVER (
            ORDER BY sale_date
        ) AS previous_revenue
    FROM daily_revenue
)
SELECT
    sale_date,
    revenue,
    previous_revenue,
    revenue - previous_revenue AS revenue_change,
    ROUND(
        (revenue - previous_revenue) * 100.0
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY sale_date;
```

## Exercise 5: Top two distinct customer spending levels

```sql
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend
    FROM orders
    GROUP BY customer_id
),
spending_levels AS (
    SELECT
        customer_id,
        lifetime_spend,
        DENSE_RANK() OVER (
            ORDER BY lifetime_spend DESC
        ) AS spending_rank
    FROM customer_totals
)
SELECT
    customer_id,
    lifetime_spend,
    spending_rank
FROM spending_levels
WHERE spending_rank <= 2
ORDER BY spending_rank, customer_id;
```

Expected output:

| Customer ID | Lifetime spend | Rank |
|---:|---:|---:|
| 102 | 4500 | 1 |
| 101 | 3000 | 2 |

Because the query uses `DENSE_RANK()`, customers tied at either of the top two distinct spending levels are all included.

---

# 11. Important PostgreSQL Concepts to Remember

## Window function execution

Window functions are evaluated after `FROM`, `WHERE`, `GROUP BY`, and `HAVING`. They are commonly used in the `SELECT` list and `ORDER BY` clause.

This is why a window-function result generally needs a CTE or subquery before it can be filtered.

## Window frame

For an ordered window, PostgreSQL's default frame is based on `RANGE` from the partition's start through the current row's last peer.

For predictable row-by-row running totals, explicitly use:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

## CTE materialization in PostgreSQL 13

In PostgreSQL 13, a side-effect-free `SELECT` CTE referenced once can generally be folded into the main query. A CTE referenced multiple times is generally materialized.

PostgreSQL also supports:

```sql
WITH my_cte AS MATERIALIZED (
    SELECT ...
)
SELECT * FROM my_cte;
```

and:

```sql
WITH my_cte AS NOT MATERIALIZED (
    SELECT ...
)
SELECT * FROM my_cte;
```

These options influence whether the CTE is materialized or can be folded into the surrounding query. They are advanced optimization controls, not requirements for ordinary CTE usage.

---

# 12. Execute SQL Files from Ubuntu

All lesson files can be executed using Docker Compose.

## Run setup file

Run only for initial database setup:

```bash
docker compose exec -T db psql \
    -U day11_user -d day11_db \
    -v ON_ERROR_STOP=1 < 01_setup.sql
```

## Run ranking functions

```bash
docker compose exec -T db psql \
    -U day11_user -d day11_db \
    -v ON_ERROR_STOP=1 < 02_ranking_functions.sql
```

## Run LAG, LEAD and running totals

```bash
docker compose exec -T db psql \
    -U day11_user -d day11_db \
    -v ON_ERROR_STOP=1 < 03_lag_lead_running_totals.sql
```

## Run CTE analysis

```bash
docker compose exec -T db psql \
    -U day11_user -d day11_db \
    -v ON_ERROR_STOP=1 < 04_ctes_and_analysis.sql
```

## Run exercises

```bash
docker compose exec -T db psql \
    -U day11_user -d day11_db \
    -v ON_ERROR_STOP=1 < 05_exercises.sql
```

### Command explanation

- `docker compose exec`: Executes a command inside a running service.
- `-T`: Disables pseudo-terminal allocation, which is useful for redirected input.
- `db`: Docker Compose service name.
- `psql`: PostgreSQL command-line client.
- `-U day11_user`: Specifies the database user.
- `-d day11_db`: Specifies the database.
- `-v ON_ERROR_STOP=1`: Stops the script when an SQL error occurs.
- `< filename.sql`: Sends the SQL file as input.

---

# 13. Common Mistakes

| Mistake | Correct approach |
|---|---|
| Using SQL directly in Ubuntu shell | Execute SQL through `psql` |
| Forgetting `ORDER BY` in `LAG()` | Specify the intended row sequence |
| Forgetting `PARTITION BY` | Add it when calculations must restart per group |
| Filtering a window function in the same-level `WHERE` | Use a CTE or subquery |
| Confusing `RANK()` and `DENSE_RANK()` | Remember that `RANK()` leaves gaps |
| Assuming `LAG()` retrieves the previous calendar date | It retrieves the previous row |
| Re-running setup SQL on populated tables | Check whether tables already exist |
| Dividing by zero in growth calculations | Use `NULLIF()` |

---

# 14. Quick Revision Sheet

| Function / Keyword | Purpose |
|---|---|
| `OVER()` | Defines the window |
| `PARTITION BY` | Separates rows into groups |
| `ORDER BY` | Defines row order |
| `ROW_NUMBER()` | Assigns unique row numbers |
| `RANK()` | Assigns ranks with gaps after ties |
| `DENSE_RANK()` | Assigns ranks without gaps |
| `LAG()` | Retrieves previous row value |
| `LEAD()` | Retrieves next row value |
| `SUM() OVER()` | Calculates window sums and running totals |
| `WITH` | Defines a CTE |
| `DENSE_RANK() <= 2` | Filters to the top two distinct ranking levels |
| `NULLIF()` | Returns NULL when two expressions are equal |

## Four important SQL patterns

### 1. Ranking

```sql
RANK() OVER (
    PARTITION BY category_id
    ORDER BY price DESC
)
```

### 2. Previous row

```sql
LAG(amount) OVER (
    PARTITION BY salesperson
    ORDER BY sale_date, sale_id
)
```

### 3. Running total

```sql
SUM(amount) OVER (
    PARTITION BY salesperson
    ORDER BY sale_date, sale_id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
```

### 4. CTE

```sql
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(amount) AS revenue
    FROM sales
    GROUP BY sale_date
)
SELECT *
FROM daily_sales;
```

---

# 15. Final Day 11 Completion Checklist

- [x] Created a separate SQL Day 11 directory.
- [x] Started PostgreSQL using Docker Compose.
- [x] Created and populated three practice tables.
- [x] Practised ROW_NUMBER().
- [x] Practised RANK().
- [x] Practised DENSE_RANK().
- [x] Practised LAG().
- [x] Practised LEAD().
- [x] Calculated running totals.
- [x] Calculated day-over-day revenue changes.
- [x] Calculated growth percentages.
- [x] Practised basic CTEs.
- [x] Practised chained CTEs.
- [x] Completed five SQL exercises.

## Final Learning Outcome

I learned how to analyse relational data using PostgreSQL window functions and CTEs.

I can now:

1. Rank products and salespeople.
2. Compare current and previous records.
3. Calculate cumulative sales and customer spending.
4. Analyse revenue growth.
5. Write multi-stage SQL queries using CTEs.

**Day 11 completed: PostgreSQL Advanced SQL — Window Functions + CTEs.**

