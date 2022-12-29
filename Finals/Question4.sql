-- Create Table
CREATE TABLE [dbo].Ranking(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

SET IDENTITY_INSERT [dbo].Ranking ON

-- Populate
INSERT [dbo].[Ranking] ([Id], [Description]) VALUES (1, 'Inactive')
INSERT [dbo].[Ranking] ([Id], [Description]) VALUES (2, 'Bronze')
INSERT [dbo].[Ranking] ([Id], [Description]) VALUES (3, 'Silver')
INSERT [dbo].[Ranking] ([Id], [Description]) VALUES (4, 'Gold')
INSERT [dbo].[Ranking] ([Id], [Description]) VALUES (5, 'Platinum')

-- Add RankingId to Customer Table
ALTER TABLE [dbo].[Customer]
ADD RankingId int;

-- Create Stored Procedure
ALTER PROCEDURE uspRankCustomers AS
BEGIN
	WITH all_customer_order_items AS (
		SELECT
			c.CustomerId,
			c.RankingId,
			oi.OrderItemId,
			oi.Quantity,
			oi.ListPrice,
			oi.Discount
		FROM Customer c
			INNER JOIN [Order] o
		ON o.CustomerId = c.CustomerId
			INNER JOIN OrderItem oi
		ON oi.OrderId = o.OrderId
	), customer_total_amount AS (
		SELECT c.CustomerId, c.RankingId, SUM(c.Quantity*c.ListPrice/(1+c.Discount)) as TotalAmount
		FROM all_customer_order_items c
		GROUP BY c.CustomerId, c.RankingId
	)
	
	SELECT *
	INTO #TempTable
	FROM customer_total_amount
	
	UPDATE Customer
	SET RankingId = 1
	FROM Customer c
	INNER JOIN #TempTable temp
	ON c.CustomerId = temp.CustomerId
	WHERE temp.TotalAmount=0

	UPDATE Customer
	SET RankingId = 2
	FROM Customer c
	INNER JOIN #TempTable temp
	ON c.CustomerId = temp.CustomerId
	WHERE temp.TotalAmount > 0 AND temp.TotalAmount < 1000
	
	UPDATE Customer
	SET RankingId = 3
	FROM Customer c
	INNER JOIN #TempTable temp
	ON c.CustomerId = temp.CustomerId
	WHERE temp.TotalAmount >= 1000 AND temp.TotalAmount < 2000
	
	UPDATE Customer
	SET RankingId = 4
	FROM Customer c
	INNER JOIN #TempTable temp
	ON c.CustomerId = temp.CustomerId
	WHERE temp.TotalAmount >= 2000 AND temp.TotalAmount < 3000
	
	UPDATE Customer
	SET RankingId = 4
	FROM Customer c
	INNER JOIN #TempTable temp
	ON c.CustomerId = temp.CustomerId
	WHERE temp.TotalAmount >= 3000

	DROP TABLE #TempTable
END

EXEC uspRankCustomers;


-- Create View
CREATE VIEW vwCustomerOrders AS
	SELECT 
		c.CustomerId,
		c.FirstName,
		c.LastName,
		SUM(c.Quantity*c.ListPrice/(1+c.Discount)) as TotalAmount,
		r.[Description] as CustomerRanking
	FROM (SELECT
		c.CustomerId,
		c.FirstName,
		c.LastName,
		c.RankingId,
		oi.Quantity,
		oi.ListPrice,
		oi.Discount
	FROM Customer c
		INNER JOIN [Order] o
	ON o.CustomerId = c.CustomerId
		INNER JOIN OrderItem oi
	ON oi.OrderId = o.OrderId) c
		INNER JOIN Ranking r
	ON r.Id = c.RankingId
	GROUP BY c.CustomerId, c.FirstName, c.LastName, r.[Description]

SELECT * FROM vwCustomerOrders
