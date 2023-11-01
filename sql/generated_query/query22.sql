SELECT * FROM (SELECT
  i_product_name,
  i_brand,
  i_class,
  i_category,
  AVG(inv_quantity_on_hand) AS qoh
FROM inventory
JOIN date_dim ON inv_date_sk = d_date_sk
JOIN item ON inv_item_sk = i_item_sk
WHERE d_month_seq BETWEEN 1200 AND 1200 + 11
GROUP BY i_product_name, i_brand, i_class, i_category WITH ROLLUP
LIMIT 100) t1
ORDER BY qoh;
