WITH ss AS (
    SELECT
        s_store_sk,
        SUM(ss_ext_sales_price) AS sales,
        SUM(ss_net_profit) AS profit
    FROM store_sales, date_dim, store
        
    WHERE ss_sold_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
        AND ss_store_sk = s_store_sk
    GROUP BY
        s_store_sk
),
sr AS (
    SELECT
        s_store_sk,
        SUM(sr_return_amt) AS returns,
        SUM(sr_net_loss) AS profit_loss
    FROM store_returns,
        date_dim,
        store
    WHERE sr_returned_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
        AND sr_store_sk = s_store_sk
    GROUP BY
        s_store_sk
), 
cs AS (
    SELECT
        cs_call_center_sk,
        SUM(cs_ext_sales_price) AS sales,
        SUM(cs_net_profit) AS profit
    FROM catalog_sales, date_dim
    WHERE cs_sold_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
    GROUP BY
        cs_call_center_sk
), 
cr AS (
    SELECT
        cr_call_center_sk,
        SUM(cr_return_amount) AS returns,
        SUM(cr_net_loss) AS profit_loss
    FROM catalog_returns, date_dim
    WHERE cr_returned_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
    GROUP BY
        cr_call_center_sk
), 
ws AS (
    SELECT
        wp_web_page_sk,
        SUM(ws_ext_sales_price) AS sales,
        SUM(ws_net_profit) AS profit
    FROM web_sales, date_dim, web_page
    WHERE ws_sold_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
        AND ws_web_page_sk = wp_web_page_sk
    GROUP BY
        wp_web_page_sk
), 
wr AS (
    SELECT
        wp_web_page_sk,
        SUM(wr_return_amt) AS returns,
        SUM(wr_net_loss) AS profit_loss
    FROM web_returns, date_dim, web_page
    WHERE wr_returned_date_sk = d_date_sk AND
        d_date BETWEEN CAST('2000-08-10' AS DATE) AND (DATE_ADD(CAST('2000-08-10' AS DATE), INTERVAL 30 DAY))
        AND wr_web_page_sk = wp_web_page_sk
    GROUP BY
        wp_web_page_sk
)
SELECT * FROM (SELECT
    channel,
    id,
    SUM(sales) AS sales,
    SUM(returns) AS returns,
    SUM(profit) AS profit
FROM
    (SELECT 'store channel' AS channel, ss.s_store_sk AS id, sales, COALESCE(returns, 0) AS returns, (profit - COALESCE(profit_loss, 0)) AS profit FROM ss
     LEFT JOIN sr ON ss.s_store_sk = sr.s_store_sk
     UNION ALL
     SELECT 'catalog channel' AS channel, cs_call_center_sk AS id, sales, returns, (profit - profit_loss) AS profit FROM cs, cr
     UNION ALL
     SELECT 'web channel' AS channel, wr.wp_web_page_sk AS id, sales, COALESCE(returns, 0) AS returns, (profit - COALESCE(profit_loss, 0)) AS profit FROM ws
     LEFT JOIN wr ON ws.wp_web_page_sk = wr.wp_web_page_sk
    ) x
GROUP BY channel, id WITH ROLLUP) t1
ORDER BY
    channel,
    id
LIMIT 100;
