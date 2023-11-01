SELECT * FROM (SELECT
  SUM(ss_net_profit) / SUM(ss_ext_sales_price) AS gross_margin,
  i_category,
  i_class,
  COALESCE(i_category) + COALESCE(i_class) AS lochierarchy,
  DENSE_RANK() OVER (
    PARTITION BY COALESCE(i_category) + COALESCE(i_class),
    CASE WHEN COALESCE(i_class) = 0 THEN i_category END
    ORDER BY SUM(ss_net_profit) / SUM(ss_ext_sales_price) ASC
  ) AS rank_within_parent
FROM store_sales
JOIN date_dim AS d1 ON d1.d_date_sk = ss_sold_date_sk
JOIN item ON i_item_sk = ss_item_sk
JOIN store ON s_store_sk = ss_store_sk
WHERE d1.d_year = 2000
  AND s_state IN ('TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN', 'TN')
GROUP BY i_category, i_class WITH ROLLUP) t1
ORDER BY
  lochierarchy DESC,
  CASE WHEN lochierarchy = 0 THEN i_category END
FETCH FIRST 100 ROWS ONLY;

