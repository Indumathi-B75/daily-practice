-- Daily revenue, previous revenue, and next revenue
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
    LAG(daily_revenue) OVER (
        ORDER BY sale_date
    ) AS previous_day_revenue,
    LEAD(daily_revenue) OVER (
        ORDER BY sale_date
    ) AS next_day_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM daily_sales
ORDER BY sale_date;

-- Previous sale and cumulative sales for each salesperson
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

-- Daily revenue change and percentage growth
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(amount) AS daily_revenue
    FROM sales
    GROUP BY sale_date
),
comparison AS (
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
        100.0 * (daily_revenue - previous_revenue)
        / NULLIF(previous_revenue, 0),
        2
    ) AS growth_percentage
FROM comparison
ORDER BY sale_date;
