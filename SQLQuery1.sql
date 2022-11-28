SELECT
CustomerId,
Count(CASE
		WHEN (OrderDate BETWEEN '20170101' and '20181212') AND ShippedDate is null
		THEN 1 ELSE null END
	) as OrderCount
FROM dbo.[Order]
GROUP BY CustomerId
HAVING Count(CASE
		WHEN (OrderDate BETWEEN '20170101' and '20181212') AND ShippedDate is null
		THEN 1 ELSE null END
	)>1

	
SELECT *
INTO dbo.ProductBackup_20221124
FROM dbo.Product
WHERE ModelYear < 2016 OR ModelYear > 2016;


UPDATE dbo.ProductBackup
SET ListPrice = ListPrice*1.2
WHERE
	BrandId IN (SELECT BrandId FROM dbo.Brand WHERE BrandName='Heller')
	OR BrandId IN (SELECT BrandId FROM dbo.Brand WHERE BrandName='Sun Bicycles')