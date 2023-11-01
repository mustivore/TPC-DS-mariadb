WITH ranked_web_sales AS (
    SELECT
        SUM(ws_net_paid) AS total_sum,
        i_category,
        i_class,
        COALESCE(i_category) + COALESCE(i_class) AS lochierarchy,
        RANK() OVER (
            PARTITION BY COALESCE(i_category) + COALESCE(i_class),
            CASE WHEN COALESCE(i_class) = 0 THEN i_category END
            ORDER BY SUM(ws_net_paid) DESC
        ) AS rank_within_parent
    FROM
        web_sales
    JOIN
        date_dim AS d1 ON d1.d_month_seq BETWEEN 1186 AND 1186 + 11
        AND d1.d_date_sk = ws_sold_date_sk
    JOIN
        item ON i_item_sk = ws_item_sk
    GROUP BY i_category, i_class
)
SELECT * FROM ranked_web_sales
UNION ALL
SELECT
    SUM(total_sum),
    NULL,
    NULL,
    2,
    DENSE_RANK() OVER (ORDER BY SUM(total_sum) DESC)
FROM ranked_web_sales
ORDER BY
    lochierarchy DESC,
    CASE WHEN lochierarchy = 0 THEN i_category END,
    rank_within_parent
LIMIT 100;



