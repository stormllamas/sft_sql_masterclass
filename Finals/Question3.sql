-- Backup Table
SELECT *
INTO ProductBackup_20221124
FROM Product

UPDATE ProductBackup_20221124
SET ListPrice = (ListPrice * 1.2)
WHERE CategoryId IN (
	SELECT CategoryId
	FROM Category
	WHERE	CategoryName = 'Children Bicycles' OR
			CategoryName = 'Cyclocross Bicycles' OR
			CategoryName = 'Road Bikes')

UPDATE ProductBackup_20221124
SET ListPrice = (ListPrice * 1.7)
WHERE CategoryId IN (
	SELECT CategoryId
	FROM Category
	WHERE	CategoryName = 'Comfort Bicycles' OR
			CategoryName = 'Cruisers Bicycles' OR
			CategoryName = 'Electric Bikes')
			
UPDATE ProductBackup_20221124
SET ListPrice = (ListPrice * 1.4)
WHERE CategoryId IN (
	SELECT CategoryId
	FROM Category
	WHERE CategoryName = 'Mountain Bikes')