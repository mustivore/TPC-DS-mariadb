SELECT
    total_sum,
    i_category,
    i_class,
    lochierarchy,
    rank_within_parent
FROM (
    SELECT
        SUM(ws_net_paid) AS total_sum,
        i_category,
        i_class,
        CASE
            WHEN COALESCE(i_category) = 0 AND COALESCE(i_class) = 0 THEN 0
            WHEN COALESCE(i_category) = 1 AND COALESCE(i_class) = 0 THEN 1
            ELSE 2
        END AS lochierarchy,
        DENSE_RANK() OVER (
            PARTITION BY CASE WHEN COALESCE(i_class) = 0 THEN i_category END
            ORDER BY SUM(ws_net_paid) DESC
        ) AS rank_within_parent
    FROM
        web_sales
    INNER JOIN date_dim AS d1 ON d1.d_date_sk = ws_sold_date_sk
    INNER JOIN item ON i_item_sk = ws_item_sk
    WHERE
        d1.d_month_seq BETWEEN 1186 AND 1186 + 11
    GROUP BY i_category, i_class WITH ROLLUP
) ranked_data
WHERE lochierarchy = 0 OR (lochierarchy = 1 AND i_category IS NOT NULL)
ORDER BY
    lochierarchy DESC,
    CASE WHEN lochierarchy = 0 THEN i_category END,
    rank_within_parent
LIMIT 100;
