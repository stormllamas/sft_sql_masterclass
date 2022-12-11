-- Question 1
WITH tx_stores AS (
	SELECT s.StoreId
	FROM [Store] s
	WHERE s.[State]='TX'
), tx_orders AS (
	SELECT o.orderId
	FROM [Order] o
	WHERE o.StoreId IN (SELECT * FROM tx_stores) AND NOT o.OrderDate is null
), tx_order_items AS (
	SELECT oi.Quantity, oi.ProductId, oi.OrderId
	FROM OrderItem oi
	WHERE oi.OrderId IN (SELECT * FROM tx_orders)
)
SELECT p.ProductName, SUM(oi.Quantity) as TotalQuantity
FROM Product p
	LEFT JOIN tx_order_items oi
ON p.ProductId = oi.ProductId
GROUP BY p.ProductName
HAVING SUM(oi.Quantity) > 9
ORDER BY SUM(oi.Quantity) DESC

-- Question 2
WITH shipped_orders AS (
	SELECT o.orderId
	FROM [Order] o
	WHERE NOT o.OrderDate is null
), shipped_order_items AS (
	SELECT oi.Quantity, oi.ProductId, oi.OrderId
	FROM OrderItem oi
	WHERE oi.OrderId IN (SELECT * FROM shipped_orders)
)
SELECT REPLACE(c.CategoryName, 'Bikes', 'Bicycles') as CategoryName, COUNT(oi.Quantity) as TotalQuantity
FROM shipped_order_items oi
	LEFT JOIN Product p
ON oi.ProductId = p.ProductId
	LEFT JOIN Category c
ON p.CategoryId = c.CategoryId
GROUP BY c.CategoryName
HAVING SUM(oi.Quantity) > 9
ORDER BY SUM(oi.Quantity) DESC

-- Question 3
WITH tx_stores AS (
	SELECT s.StoreId
	FROM [Store] s
	WHERE s.[State]='TX'
), tx_orders AS (
	SELECT o.orderId
	FROM [Order] o
	WHERE o.StoreId IN (SELECT * FROM tx_stores) AND NOT o.OrderDate is null
), tx_order_items AS (
	SELECT oi.Quantity, oi.ProductId, oi.OrderId
	FROM OrderItem oi
	WHERE oi.OrderId IN (SELECT * FROM tx_orders)
), shipped_orders AS (
	SELECT o.orderId
	FROM [Order] o
	WHERE NOT o.OrderDate is null
), shipped_order_items AS (
	SELECT oi.Quantity, oi.ProductId, oi.OrderId
	FROM OrderItem oi
	WHERE oi.OrderId IN (SELECT * FROM shipped_orders)
), CategoryTable AS (
	SELECT REPLACE(c.CategoryName, 'Bikes', 'Bicycles') as CategoryName, COUNT(oi.Quantity) as TotalQuantity
	FROM Category c
		LEFT JOIN Product p
	ON p.CategoryId = c.CategoryId
		LEFT JOIN shipped_order_items oi
	ON p.ProductId = oi.ProductId
	GROUP BY c.CategoryName
	HAVING SUM(oi.Quantity) > 9
), ProductTable AS (
	SELECT p.ProductName, SUM(oi.Quantity) as TotalQuantity
	FROM Product p
		LEFT JOIN tx_order_items oi
	ON p.ProductId = oi.ProductId
	GROUP BY p.ProductName
	HAVING SUM(oi.Quantity) > 9
)

MERGE ProductTable AS p
USING CategoryTable AS c 
	ON (p.ProductName = c.CategoryName)
WHEN MATCHED
	THEN UPDATE
		SET p.ProductName = c.CategoryName
WHEN NOT MATCHED 
	THEN INSERT
	VALUES (c.CategoryName, c.TotalQuantity)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE; 

-- Question 4
WITH shipped_orders AS (
	SELECT o.orderId
	FROM [Order] o
	WHERE NOT o.OrderDate is null
), shipped_order_items AS (
	SELECT oi.Quantity, oi.ProductId, oi.OrderId
	FROM OrderItem oi
	WHERE oi.OrderId IN (SELECT * FROM shipped_orders)
), top_products AS (
	SELECT
		YEAR(o.OrderDate) as OrderYear,
		MONTH(o.OrderDate) as OrderMonth,
		p.ProductName,
		SUM(oi.Quantity) as TotalQuantity,
		Rank() over (Partition BY
			YEAR(o.OrderDate),
			MONTH(o.OrderDate) ORDER BY SUM(oi.Quantity) DESC ) as TotalRank
	FROM shipped_order_items oi
		LEFT JOIN Product p
	ON oi.ProductId = p.ProductId
		LEFT JOIN [Order] o
	ON o.OrderId = oi.OrderId
	GROUP BY YEAR(o.OrderDate),
		MONTH(o.OrderDate), p.ProductName, oi.Quantity
)
SELECT OrderYear, OrderMonth, ProductName, TotalQuantity FROM top_products
WHERE TotalRank < 2
ORDER BY
	TotalRank,
	YEAR(OrderYear),
	MONTH(OrderMonth)


