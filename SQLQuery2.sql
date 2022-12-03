-- Question 1
SELECT s.StoreId, s.StoreName
FROM dbo.[Store] s
    LEFT JOIN dbo.[Order] o
ON s.StoreId = o.StoreId
WHERE o.OrderId IS NULL

-- Question 2
SELECT p.ProductId, ProductName, BrandName, CategoryName, Quantity
FROM dbo.Product p
	INNER JOIN dbo.Brand b
ON p.BrandId = b.BrandId
	INNER JOIN dbo.Category c
ON p.CategoryId = c.CategoryId
	INNER JOIN dbo.Stock s
ON p.ProductId = s.ProductId
WHERE
	s.StoreId IN (SELECT StoreId FROM dbo.Store WHERE StoreName='Baldwin Bikes')
	AND (ModelYear = 2017 OR ModelYear = 2018)
ORDER BY s.Quantity DESC, ProductName, BrandName, CategoryName



-- Question 3
SELECT StoreName, YEAR(o.OrderDate) as OrderYear, count(o.OrderDate) as OrderCount
from dbo.[Order] o
	INNER JOIN dbo.Store s
ON o.StoreId = s.StoreId
GROUP BY s.StoreName, YEAR(o.OrderDate)
ORDER BY StoreName, YEAR(o.OrderDate) DESC


-- Question 4
WITH myProducts AS (
	SELECT
		ROW_NUMBER() OVER(
		PARTITION BY b.BrandName
		ORDER BY p.ListPrice DESC, p.ProductName) AS row_num, 
		p.ProductId, 
		p.ProductName, 
		b.BrandName, 
		p.ListPrice
	FROM Product p
	 INNER JOIN Brand b
	ON p.BrandId = b.BrandId
)
SELECT 
    BrandName, 
	ProductId,
    ProductName, 
    ListPrice
FROM 
    myProducts
WHERE 
    row_num <= 5

	
-- Question 5
DECLARE @cur CURSOR
DECLARE @var1 varchar(128)
DECLARE @var2 varchar(128)
DECLARE @var3 varchar(128)
SET @cur = CURSOR STATIC FOR
    SELECT StoreName, YEAR(o.OrderDate) as OrderYear, count(o.OrderDate) as OrderCount
	from dbo.[Order] o
		INNER JOIN dbo.Store s
	ON o.StoreId = s.StoreId
	GROUP BY s.StoreName, YEAR(o.OrderDate)
	ORDER BY StoreName, YEAR(o.OrderDate) DESC
OPEN @cur
WHILE 1 = 1
BEGIN
     FETCH @cur INTO @var1, @var2, @var3
     IF @@fetch_status <> 0
        BREAK
		PRINT @var1 + ' ' + @var2 + ' ' + @var3
END
CLOSE @cur
DEALLOCATE @cur



-- Question 6
DECLARE @a INT;
SET @a = 1;
WHILE(@a <= 10)
    BEGIN
		DECLARE @b INT;
		SET @b = 1;

		WHILE(@b <= 10)
			BEGIN
				PRINT CAST(@a as varchar(10)) + ' * ' + CAST(@b as varchar(10)) + ' = ' + CAST((@a*@b) as varchar(10))
				SET @b  = @b + 1;
			END;
			
		SET @a  = @a + 1;
    END;


-- Question 7
SELECT * FROM   
(
    SELECT 
        YEAR(o.OrderDate) as SalesYear, 
		FORMAT(o.OrderDate, 'MMM') as m,
		SUM(oi.ListPrice) as ListPrice
    FROM 
        [Order] o	
        INNER JOIN OrderItem oi 
        ON o.OrderId = oi.OrderId
	GROUP BY YEAR(o.OrderDate), FORMAT(o.OrderDate, 'MMM')
) AS SourceTable
PIVOT(
    SUM(ListPrice) 
    FOR m IN (
        [Jan],
		[Feb],
		[Mar],
		[Apr],
		[May],
		[Jun],
		[Jul],
		[Aug],
		[Sep],
		[Oct],
		[Nov],
		[Dec]
	)
) AS pivot_table;