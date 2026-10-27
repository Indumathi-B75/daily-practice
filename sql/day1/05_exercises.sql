-- Exercise 1:
-- Rank salespeople by total sales using ROW_NUMBER, RANK,
-- and DENSE_RANK. Explain how ties are handled.

-- Exercise 2:
-- Show each sale and the previous sale amount for that salesperson.

-- Exercise 3:
-- Calculate running revenue by date and running spending by customer.

-- Exercise 4:
-- Calculate day-over-day revenue change and growth percentage.

-- Exercise 5:
-- Use two or more chained CTEs to return the top two
-- distinct customer lifetime spending levels.

-- Write your solutions below this line.

--1
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
    ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS row_num,
    RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
    DENSE_RANK() OVER (ORDER BY total_sales DESC) AS dense_sales_rank
FROM salesperson_totals
ORDER BY total_sales DESC;

--2
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


-- Exercise 3A: Running revenue by date

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


-- Exercise 3B: Running spending by customer

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


--4
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


--5
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
