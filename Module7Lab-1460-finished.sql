CREATE OR ALTER PROCEDURE CalculateOrderTotal
    @OrderID INT,
    @TotalAmount MONEY OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    -- Calculate the total amount for the given order
    SELECT @TotalAmount = SUM(UnitPrice * Quantity * (1 - Discount))
    FROM [Order Details]
    WHERE OrderID = @OrderID;
    -- Check if the order exists
    IF @TotalAmount IS NULL
    BEGIN
        SET @TotalAmount = 0;
        PRINT 'Order ' + CAST(@OrderID AS NVARCHAR(10)) + ' not found.';
        RETURN;
    END
    PRINT 'The total amount for Order ' + CAST(@OrderID AS NVARCHAR(10)) + ' is $' + CAST(@TotalAmount AS NVARCHAR(20));
END
GO
-- Test the stored procedure with a valid order
DECLARE @OrderID INT = 10248;
DECLARE @TotalAmount MONEY;
EXEC CalculateOrderTotal 
    @OrderID = @OrderID, 
    @TotalAmount = @TotalAmount OUTPUT;
PRINT 'Returned total amount: $' + CAST(@TotalAmount AS NVARCHAR(20));
-- Test with an invalid order
SET @OrderID = 99999;
SET @TotalAmount = NULL;
EXEC CalculateOrderTotal 
    @OrderID = @OrderID, 
    @TotalAmount = @TotalAmount OUTPUT;
PRINT 'Returned total amount: $' + CAST(ISNULL(@TotalAmount, 0) AS NVARCHAR(20));
GO
CREATE OR ALTER PROCEDURE CheckProductStock
    @ProductID INT,
    @NeedsReorder BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;
    DECLARE @ProductName NVARCHAR(40);
    
    -- Get product information
    SELECT 
        @UnitsInStock = UnitsInStock,
        @ReorderLevel = ReorderLevel,
        @ProductName = ProductName
    FROM Products
    WHERE ProductID = @ProductID;
    
    -- Check if product exists
    IF @ProductName IS NULL
    BEGIN
        SET @NeedsReorder = 0;
        PRINT 'Product ID ' + CAST(@ProductID AS NVARCHAR(10)) + ' not found.';
        RETURN;
    END
    
    -- Check if reorder is needed
    IF @UnitsInStock <= @ReorderLevel
    BEGIN
        SET @NeedsReorder = 1;
        PRINT @ProductName + ' needs reordering! Stock: ' + 
              CAST(@UnitsInStock AS NVARCHAR(10)) + 
              ', Reorder Level: ' + CAST(@ReorderLevel AS NVARCHAR(10));
    END
    ELSE
    BEGIN
        SET @NeedsReorder = 0;
        PRINT @ProductName + ' has adequate stock. Stock: ' + 
              CAST(@UnitsInStock AS NVARCHAR(10)) + 
              ', Reorder Level: ' + CAST(@ReorderLevel AS NVARCHAR(10));
    END
END
GO

-- Test the new procedure
DECLARE @NeedsReorder BIT;
EXEC CheckProductStock 
    @ProductID = 11,
    @NeedsReorder = @NeedsReorder OUTPUT;
PRINT 'Needs Reorder: ' + CAST(@NeedsReorder AS VARCHAR(1));

