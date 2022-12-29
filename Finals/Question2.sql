CREATE PROCEDURE GetProducts
	@ProductName nvarchar(30) = NULL,
	@BrandId int = NULL,
	@CategoryId int = NULL,
	@ModelYear int = NULL,
	@PageIndex int = 0
AS
SELECT * FROM Product
WHERE	ProductName LIKE @ProductName+'%' AND
		BrandId=@BrandId OR @BrandId IS NULL AND
		CategoryId= @CategoryId OR @CategoryId IS NULL AND
		ModelYear = @ModelYear OR @ModelYear IS NULL
ORDER BY ModelYear DESC, ListPrice DESC, ProductName DESC
OFFSET @PageIndex*10 ROWS FETCH NEXT 10 ROWS ONLY;
GO;	

EXEC GetProducts @ProductName = 'Trek', @PageIndex=0;