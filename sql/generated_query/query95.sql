WITH ws_wh AS (
    SELECT ws1.ws_order_number, ws1.ws_warehouse_sk AS wh1, ws2.ws_warehouse_sk AS wh2
    FROM web_sales ws1
    JOIN web_sales ws2 ON ws1.ws_order_number = ws2.ws_order_number AND ws1.ws_warehouse_sk <> ws2.ws_warehouse_sk
)
SELECT
    COUNT(DISTINCT ws_order_number) AS "order count",
    SUM(ws_ext_ship_cost) AS "total shipping cost",
    SUM(ws_net_profit) AS "total net profit"
FROM
    web_sales ws1
JOIN date_dim ON ws1.ws_ship_date_sk = d_date_sk
JOIN customer_address ON ws1.ws_ship_addr_sk = ca_address_sk
JOIN web_site ON ws1.ws_web_site_sk = web_site_sk
WHERE
    d_date BETWEEN '2001-04-01' AND DATE_ADD(CAST('2001-04-01' AS DATE), INTERVAL 60 DAY)
    AND ca_state = 'VA'
    AND web_company_name = 'pri'
    AND ws1.ws_order_number IN (SELECT ws_order_number FROM ws_wh)
    AND ws1.ws_order_number IN (SELECT wr_order_number FROM web_returns WHERE wr_order_number IN (SELECT ws_order_number FROM ws_wh))
ORDER BY COUNT(DISTINCT ws_order_number)
LIMIT 100;
