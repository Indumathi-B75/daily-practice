-- ROW_NUMBER, RANK, and DENSE_RANK
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

-- Top three distinct price levels per category
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
SELECT *
FROM ranked_products
WHERE price_rank <= 3
ORDER BY category_id, price_rank, product_id;
