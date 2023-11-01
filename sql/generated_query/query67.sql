SELECT *
FROM (
    SELECT i_category,
        i_class,
        i_brand,
        i_product_name,
        d_year,
        d_qoy,
        d_moy,
        s_store_id,
        sumsales,
        RANK() OVER (PARTITION BY i_category ORDER BY sumsales DESC) rk
    FROM (
        SELECT i_category,
            i_class,
            i_brand,
            i_product_name,
            d_year,
            d_qoy,
            d_moy,
            s_store_id,
            SUM(COALESCE(ss_sales_price * ss_quantity, 0)) AS sumsales
        FROM store_sales
        JOIN date_dim ON ss_sold_date_sk = d_date_sk
        JOIN store ON ss_store_sk = s_store_sk
        JOIN item ON ss_item_sk = i_item_sk
        WHERE d_month_seq BETWEEN 1217 AND 1217 + 11
        GROUP BY i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id WITH ROLLUP
    ) dw1
) dw2
WHERE rk <= 100
ORDER BY i_category, i_class, i_brand, i_product_name, d_year, d_qoy, d_moy, s_store_id, sumsales, rk
LIMIT 100;
