WITH wscs AS
 (SELECT sold_date_sk
        ,sales_price
  FROM (SELECT ws_sold_date_sk AS sold_date_sk
              ,ws_ext_sales_price AS sales_price
        FROM web_sales 
        UNION ALL
        SELECT cs_sold_date_sk AS sold_date_sk
              ,cs_ext_sales_price AS sales_price
        FROM catalog_sales) AS subquery),
 wswscs AS 
 (SELECT d_week_seq,
        SUM(IF(d_day_name = 'Sunday', sales_price, 0)) AS sun_sales,
        SUM(IF(d_day_name = 'Monday', sales_price, 0)) AS mon_sales,
        SUM(IF(d_day_name = 'Tuesday', sales_price, 0)) AS tue_sales,
        SUM(IF(d_day_name = 'Wednesday', sales_price, 0)) AS wed_sales,
        SUM(IF(d_day_name = 'Thursday', sales_price, 0)) AS thu_sales,
        SUM(IF(d_day_name = 'Friday', sales_price, 0)) AS fri_sales,
        SUM(IF(d_day_name = 'Saturday', sales_price, 0)) AS sat_sales
FROM wscs
     ,date_dim
WHERE d_date_sk = sold_date_sk
GROUP BY d_week_seq)
SELECT d_week_seq1,
       ROUND(sun_sales1 / sun_sales2, 2) AS Sunday,
       ROUND(mon_sales1 / mon_sales2, 2) AS Monday,
       ROUND(tue_sales1 / tue_sales2, 2) AS Tuesday,
       ROUND(wed_sales1 / wed_sales2, 2) AS Wednesday,
       ROUND(thu_sales1 / thu_sales2, 2) AS Thursday,
       ROUND(fri_sales1 / fri_sales2, 2) AS Friday,
       ROUND(sat_sales1 / sat_sales2, 2) AS Saturday
FROM (
  SELECT wswscs.d_week_seq AS d_week_seq1,
         sun_sales AS sun_sales1,
         mon_sales AS mon_sales1,
         tue_sales AS tue_sales1,
         wed_sales AS wed_sales1,
         thu_sales AS thu_sales1,
         fri_sales AS fri_sales1,
         sat_sales AS sat_sales1
  FROM wswscs, date_dim
  WHERE date_dim.d_week_seq = wswscs.d_week_seq AND d_year = 1998
) AS y,
(
  SELECT wswscs.d_week_seq AS d_week_seq2,
         sun_sales AS sun_sales2,
         mon_sales AS mon_sales2,
         tue_sales AS tue_sales2,
         wed_sales AS wed_sales2,
         thu_sales AS thu_sales2,
         fri_sales AS fri_sales2,
         sat_sales AS sat_sales2
  FROM wswscs,date_dim
  WHERE date_dim.d_week_seq = wswscs.d_week_seq AND d_year = 1998 + 1
) AS z 
WHERE d_week_seq1 = d_week_seq2 - 53
ORDER BY d_week_seq1;
