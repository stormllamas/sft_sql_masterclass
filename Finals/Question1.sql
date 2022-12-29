-- Problem 1
CREATE PROCEDURE CreateNewBrandAndMoveProducts @NewBrandName nvarchar(30), @OldBrandId int
AS
BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO Brand (BrandName) VALUES (@NewBrandName)
		UPDATE Product
		SET BrandId=(SELECT BrandId FROM Brand WHERE BrandName=@NewBrandName)
		WHERE BrandId=@OldBrandId
		DELETE FROM Brand WHERE BrandId=@OldBrandId
		COMMIT
END TRY
BEGIN CATCH
	ROLLBACK
END CATCH
GO;

EXEC CreateNewBrandAndMoveProducts @NewBrandName = 'Electra', @OldBrandId = 11;