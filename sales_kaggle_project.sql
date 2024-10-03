USE kaggle;
SELECT * FROM df_orders;
DROP TABLE df_orders;
CREATE TABLE df_orders(
[order_id] INT PRIMARY KEY,
[order_date] DATE,
[ship_mode] VARCHAR(20),
[segment] VARCHAR(20),
[country] VARCHAR(20),
[city] VARCHAR(20),
[state] VARCHAR(20),
[postal_code] VARCHAR(20),
[region] VARCHAR(20),
[category] VARCHAR(20),
[sub_category] VARCHAR(20),
[product_id] VARCHAR(20),
[quantity] VARCHAR(20),
[discount] DECIMAL(7,2),
[sale_price] DECIMAL(7,2),
[profit] DECIMAL(7,2))
--- Now again running from pandas
SELECT * FROM df_orders;
 --Q-1 Find top 10 highest revenue generating products.
 SELECT TOP 10 product_id, SUM(sale_price) AS sales
 FROM df_orders
 GROUP BY product_id
 ORDER BY sales DESC;

 --Q-2 Find top 5 highest selling products in each region
 WITH cte AS(
 SELECT region, product_id, SUM(sale_price) AS sales
 FROM df_orders
 GROUP BY region, product_id)
 SELECT * FROM(
 SELECT *, ROW_NUMBER() OVER( PARTITION BY region ORDER BY sales) AS rn
 FROM cte) AS A
 WHERE rn<=5;

 --Q-3 Find month over month growth comparison for 2022 and 2023 sales 
 --eg jan 2022 vs jan 2023
 WITH cte AS (
 SELECT YEAR(order_date) AS order_year, MONTH(order_date) AS order_month, SUM(sale_price) AS sales
 FROM df_orders
 GROUP BY YEAR(order_date), MONTH(order_date)
 --ORDER BY YEAR(order_date), MONTH(order_date)
 )
 SELECT order_month,
 SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
 SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023

 FROM cte
 GROUP BY order_month
 ORDER BY order_month;


 -- Q-4 For each category which month has highest sales
 --SELECT DISTINCT category FROM df_orders;
 WITH CTE AS (
 SELECT category, FORMAT(order_date,'yyyy-MM') AS order_year_month, SUM(sale_price) AS sales
 FROM df_orders
 GROUP BY category, FORMAT(order_date,'yyyy-MM')
 --ORDER BY category, FORMAT(order_date,'yyyy-MM')
 )
 SELECT * FROM(
 SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
 FROM cte) AS b
 WHERE rn = 1;

 --Q-5 Which sub category had highest growth by profit in 2023 compare to 2022
 WITH CTE AS(
 SELECT sub_category, YEAR(order_date) AS order_year, SUM(sale_price) AS sales
 FROM df_orders
 GROUP BY sub_category, YEAR(order_date)
 ),
 CTE2 AS(
 SELECT sub_category,
 SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
 SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023

 FROM cte
 GROUP BY sub_category
 --ORDER BY sub_category
 )
 SELECT TOP 1 *, (sales_2023-sales_2022)*100/sales_2022
 FROM CTE2
 ORDER BY (sales_2023-sales_2022)*100/sales_2022 DESC;
