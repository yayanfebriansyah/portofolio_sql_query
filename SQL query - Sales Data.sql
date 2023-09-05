-- SQL Query from 'customer' table and 'orders' table

SELECT * FROM customer;
SELECT * FROM orders;

-- Mencari jumlah customer
SELECT Count(distinct `Customer ID`) FROM customer;

-- Mencari category dengan rataan profit tertinggi 
-- Write SQL code to find the category with the highest average profit
SELECT `Category`, AVG(Profit) FROM orders
GROUP BY `Category` ORDER BY 2 DESC LIMIT 1;

-- Mencari jumlah customer yang melakukan order
SELECT Count(DISTINCT `Customer ID`) FROM orders;

-- Mencari data dengan selisih order date dan ship date kurang dari 3 hari
-- Write SQL code to find data with a difference in days between the order date and ship date of less than 3 days
SELECT *, 
	datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),
    STR_TO_DATE(`Order Date`, '%m/%d/%Y')) 
    AS avg_diff_date
FROM orders 
WHERE datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),
STR_TO_DATE(`Order Date`, '%m/%d/%Y')) < 3;

-- Mencari data dengan tahun order date dan ship date berbeda
-- Write SQL code to find data where the year of order date and year of ship date are different
SELECT *
FROM orders
WHERE YEAR(STR_TO_DATE(`Order Date`, '%m/%d/%Y')) <>
	  YEAR(STR_TO_DATE(`SHIP Date`, '%m/%d/%Y'));
      
      

-- Mencari data dengan profit di atas rata-rata untuk setiap kategori
-- Write SQL code to find data Find data with profits above the average for each category
-- Alternative 1
SELECT *
FROM orders
WHERE Profit > (
    SELECT AVG(Profit)
    FROM orders AS subquery
    WHERE subquery.Category = orders.Category
);

-- Alternative 2
WITH AvgProfit AS (
	SELECT *, AVG(Profit) OVER (PARTITION BY Category) 
    as avg_profit_per_category
	FROM orders
)
SELECT *
FROM AvgProfit
WHERE Profit > avg_profit_per_category;



-- Mencari data dengan profit tertinggi untuk setiap kategori
-- Write SQL code to find data with highest profit for each category
-- Alternative 1
SELECT *
FROM orders
WHERE Profit = (
    SELECT MAX(Profit)
    FROM orders AS subquery
    WHERE subquery.Category = orders.Category
);

-- Alternative 2
WITH MaxProfit AS (
	SELECT *, MAX(Profit) OVER (PARTITION BY Category) as max_profit_per_category
	FROM orders
)
SELECT *
FROM MaxProfit
WHERE Profit = max_profit_per_category;

-- Mencari data dengan ship mode same day
-- Write SQL code to find data that ship mode is same day
SELECT * FROM orders
JOIN customer 
ON orders.`Customer ID` = customer.`Customer ID`
WHERE `Ship Mode` = "Same Day";

-- Mencari jumlah order dengan selisih order date dan ship date kurang dari 3 hari untuk setiap region
-- Write SQL code to find data with a difference in days between the order date and ship date of less than 3 days
-- Alternative 1
WITH order_lower AS (
SELECT *, datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),STR_TO_DATE(`Order Date`, '%m/%d/%Y'))
as avg_diff_date FROM orders where datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),STR_TO_DATE(`Order Date`, '%m/%d/%Y')) < 3
)
SELECT Region, count(distinct `Order ID`)
FROM order_lower
GROUP BY Region;
-- Alternative 2
SELECT Region, count(distinct `Order ID`)
FROM (
	SELECT *, datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),STR_TO_DATE(`Order Date`, '%m/%d/%Y')) as avg_diff_date
    FROM orders
    WHERE datediff(STR_TO_DATE(`Ship Date`, '%m/%d/%Y'),STR_TO_DATE(`Order Date`, '%m/%d/%Y')) < 3
) a
GROUP BY Region;

-- Mencari produk dengan jumlah order tertinggi
-- Write SQL code to find product ID with the highest number of orders
SELECT * FROM orders
WHERE `Product ID` = (SELECT `Product ID` FROM (SELECT `Product ID`, Count(`Product ID`)
FROM orders
GROUP BY 1
ORDER BY 2 DESC LIMIT 1) as max_order)
ORDER BY `Product Name`;

-- Mencari Category dengan jumlah order tertinggi untuk setiap region
-- Write SQL code to find category with the highest number of order each region
WITH num_category AS (
	SELECT Region, Category, COUNT(`Order ID`) as num_of_order, 
		ROW_NUMBER() OVER (PARTITION BY Region ORDER BY COUNT(Category) DESC) as row_num
	FROM orders
	GROUP BY Region, Category
)
SELECT Region, Category, num_of_order FROM num_category
WHERE row_num = 1;

-- Kategori barang yang sering dibeli oleh setiap segmen
-- Write SQL code to find category with the highest number of order each segment
WITH RankedCategories AS (
SELECT Segment, Category, Count(`Order ID`) as num_category, 
	row_number() OVER (partition by Segment ORDER BY Count(Category) DESC) as row_num
FROM customer a
JOIN orders b
ON a.`Customer ID` = b.`Customer ID`
GROUP BY Segment, Category
ORDER BY num_category)
SELECT Segment, Category, num_category
FROM RankedCategories
WHERE row_num = 1;

-- Mencari customer dengan jenis produk terbanyak (product ID terbanyak) untuk satu kali order
-- Write SQL code to find customers and Order ID with the highest Product ID count for a single order
-- 1. Hanya menghasilkan nama customer tanpa jumlah jenis order
-- 1. without product ID count
WITH number_order AS (
	SELECT `Order ID`, Count(`Product ID`) as num_orders FROM orders
	GROUP BY `Order ID`
    )
SELECT DISTINCT(`Customer Name`), a.`Customer ID` FROM customer a
JOIN orders b
ON a.`Customer ID` = b.`Customer ID`
WHERE `Order ID` in (
					SELECT `Order ID` 
                    FROM number_order 
                    WHERE num_orders = (SELECT MAX(num_orders) FROM number_order));
-- 2. Dengan jumlah produk ID
-- 2. with product ID count
WITH number_orders AS (
	SELECT `Customer ID`, `Order ID`, Count(distinct `Product ID`) as num_product, 
		RANK() OVER(ORDER BY Count(`Order ID`) DESC) AS rank_num_orders FROM orders
	GROUP BY `Customer ID`, `Order ID`
    )
SELECT distinct a.`Customer ID`,b.`Customer Name`,a.`Order ID`,num_product
FROM number_orders a
JOIN customer b
ON a.`Customer ID` = b.`Customer ID`
WHERE rank_num_orders = 1;


-- Mencari customer dengan jumlah order terbanyak
-- Write SQL code to find customers with the highest number of orders
WITH NumOrder AS (
	SELECT `Customer ID`, Count(Distinct `Order ID`) as num_orders
    FROM orders
	GROUP BY `Customer ID`)
SELECT `Customer ID`, num_orders
FROM NumOrder
WHERE num_orders = (SELECT Max(num_orders) FROM NumOrder);


-- Customer dengan kuantitas barang terbanyak untuk sekali order
-- Write SQL code to find customer with the most quantity for a single order
WITH MaxQuantity AS (
	SELECT `Customer ID`, `Order ID`, SUM(Quantity) as sum_quantity
	FROM orders
	GROUP BY `Customer ID`, `Order ID`
	ORDER BY 3 DESC LIMIT 1
    )
SELECT distinct a.`Customer ID`,b.`Customer Name`,a.`Order ID`, a.sum_quantity
FROM Maxquantity a
JOIN customer b
ON a.`Customer ID`=b.`Customer ID`;