WITH ssci AS (
    SELECT ss_customer_sk AS customer_sk, ss_item_sk AS item_sk
    FROM store_sales
    JOIN date_dim ON ss_sold_date_sk = d_date_sk
    WHERE d_month_seq BETWEEN 1199 AND 1199 + 11
    GROUP BY ss_customer_sk, ss_item_sk
),
csci AS (
    SELECT cs_bill_customer_sk AS customer_sk, cs_item_sk AS item_sk
    FROM catalog_sales
    JOIN date_dim ON cs_sold_date_sk = d_date_sk
    WHERE d_month_seq BETWEEN 1199 AND 1199 + 11
    GROUP BY cs_bill_customer_sk, cs_item_sk
)
SELECT
    SUM(CASE WHEN s.customer_sk IS NOT NULL AND c.customer_sk IS NULL THEN 1 ELSE 0 END) AS store_only,
    SUM(CASE WHEN s.customer_sk IS NULL AND c.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS catalog_only,
    SUM(CASE WHEN s.customer_sk IS NOT NULL AND c.customer_sk IS NOT NULL THEN 1 ELSE 0 END) AS store_and_catalog
FROM (
    (SELECT DISTINCT customer_sk, item_sk FROM ssci) AS s
    LEFT JOIN
    (SELECT DISTINCT customer_sk, item_sk FROM csci) AS c
    ON s.customer_sk = c.customer_sk AND s.item_sk = c.item_sk
)
LIMIT 100;
