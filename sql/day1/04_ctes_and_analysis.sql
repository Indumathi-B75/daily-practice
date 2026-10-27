-- CTE chain: daily aggregation -> previous-day comparison -> metrics
WITH daily_sales AS (
    SELECT
        sale_date,
        SUM(amount) AS daily_revenue
    FROM sales
    GROUP BY sale_date
),
daily_comparison AS (
    SELECT
        sale_date,
        daily_revenue,
        LAG(daily_revenue) OVER (
            ORDER BY sale_date
        ) AS previous_revenue
    FROM daily_sales
),
daily_metrics AS (
    SELECT
        sale_date,
        daily_revenue,
        previous_revenue,
        daily_revenue - previous_revenue AS revenue_change,
        SUM(daily_revenue) OVER (
            ORDER BY sale_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_revenue
    FROM daily_comparison
)
SELECT *
FROM daily_metrics
ORDER BY sale_date;

-- Customer lifetime spending and ranking
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(total_amount) AS lifetime_spend
    FROM orders
    GROUP BY customer_id
),
customer_rankings AS (
    SELECT
        customer_id,
        lifetime_spend,
        DENSE_RANK() OVER (
            ORDER BY lifetime_spend DESC
        ) AS spending_rank
    FROM customer_totals
)
SELECT *
FROM customer_rankings
ORDER BY spending_rank, customer_id;

-- Customer order history and running spend
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
