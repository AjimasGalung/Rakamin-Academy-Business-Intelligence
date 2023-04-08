-- 1. Total order SAME DAY which delays in delivery 
SELECT COUNT(t1.*)
FROM (
	SELECT order_id
	FROM public.superstore_order
	WHERE ship_mode = 'Same Day' AND ship_date > order_date
) AS t1

/* 2. Display the discount level (low, moderate, or high) and spot the
relationship between discount level and profitability by showing
the average of each discount level.
*/
WITH cte_level_discount AS
(
	SELECT
		discount,
		CASE
			WHEN discount < 0.2 THEN 'LOW'
			WHEN discount >= 0.2 and discount < 0.4 THEN 'MODERATE'
			WHEN discount >= 0.4 THEN 'HIGH'
		END	AS discount_level,
		profit
	FROM public.superstore_order
)
SELECT discount_level, ROUND(AVG(profit), 2) AS average_profit
FROM cte_level_discount
GROUP BY discount_level
ORDER BY average_profit DESC;

/* 3. displays the following metrics for each of the existing Category-Subcategory pairs
where the metric is average profit and average discount.
*/
SELECT 
	CONCAT(p.category,'-',p.sub_category) AS category_subcategory,
	ROUND(AVG(o.discount), 3) AS average_discount,
	ROUND(AVG(o.profit), 3) AS average_profit
FROM public.superstore_order o
INNER JOIN public.superstore_product p ON o.product_id = p.product_id
GROUP BY category_subcategory
ORDER BY average_discount DESC;

/* 4. Performe the total sales and average profit for each Customer Segment who lived
in California, Texas, and Georgia.
*/
WITH cte_customer AS
(
	SELECT customer_id, segment, state
	FROM public.superstore_customer
	WHERE state IN ('California','Texas','Georgia')
)
SELECT 
	c.segment AS segment,
	ROUND(SUM(o.sales), 3) AS total_sales,
	ROUND(AVG(o.profit), 2) AS average_profit
FROM public.superstore_order o 
INNER JOIN cte_customer c ON o.customer_id = c.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2016
GROUP BY segment
ORDER BY total_sales DESC;

/* 5. We are asked to show total customer who has average discount over 0.4
for each region
*/
SELECT region, COUNT(customer_id) AS total_customer
FROM public.superstore_customer
WHERE customer_id IN (
	SELECT customer_id
	FROM public.superstore_order
	GROUP BY customer_id
	HAVING AVG(discount) >= 0.4
	)
GROUP BY region
ORDER BY total_customer DESC;