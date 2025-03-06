-- Northwind Database SQL Practice Exam - Example Answers
-- ----------------------------------------------------------------
-- General Tips:
-- - Read each question carefully
-- - Ensure correct SQL syntax
-- - Test queries before submission when possible
-- - Pay attention to specific columns requested
-- - Use proper joins and aliases for readability

-- Question 1: SQL SELECT Statements
-- Write a query to list all products (ProductName) with their CategoryName and SupplierName.
SELECT 
    p.ProductName,
    c.CategoryName,
    s.CompanyName AS SupplierName
FROM 
    Products p
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN Suppliers s ON p.SupplierID = s.SupplierID
ORDER BY 
    p.ProductName;
GO

-- Question 2: SQL JOINs
-- Find all customers who have never placed an order. Display the CustomerID and CompanyName.
SELECT 
    c.CustomerID, 
    c.CompanyName
FROM 
    Customers c
    LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE 
    o.OrderID IS NULL
ORDER BY 
    c.CompanyName;
GO

-- Question 3: Functions and GROUP BY
-- List the top 5 employees by total sales amount. Include EmployeeID, FirstName, LastName, and TotalSales.
SELECT TOP 5
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM 
    Employees e
    INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    TotalSales DESC;
GO

-- Question 4: SQL Insert Statement
-- Add a new product to the Products table with the specified details.
INSERT INTO Products (
    ProductName,
    SupplierID,
    CategoryID,
    QuantityPerUnit,
    UnitPrice,
    UnitsInStock,
    UnitsOnOrder,
    ReorderLevel,
    Discontinued
)
VALUES (
    'Northwind Coffee',
    1,
    1,
    '10 boxes x 20 bags',
    18.00,
    39,
    0,
    10,
    0
);
GO

-- Question 5: SQL Update Statement
-- Increase the UnitPrice of all products in the "Beverages" category by 10%.
UPDATE Products
SET UnitPrice = UnitPrice * 1.10
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Beverages';
GO

-- Question 6: SQL Insert and Delete Statements
-- a) Insert a new order for customer VINET with today's date.
-- b) Delete the order you just created.
DECLARE @OrderID int;

-- Part a: Insert a new order
INSERT INTO Orders (
    CustomerID,
    EmployeeID,
    OrderDate,
    RequiredDate
)
VALUES (
    'VINET',
    1,
    GETDATE(),
    DATEADD(day, 7, GETDATE())
);

-- Store the new OrderID to use in the DELETE statement
SET @OrderID = SCOPE_IDENTITY();

-- Part b: Delete the order
DELETE FROM Orders 
WHERE OrderID = @OrderID;
GO

-- Question 7: Creating Tables
-- Create a new table named "ProductReviews" with the specified columns.
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ProductReviews')
    DROP TABLE ProductReviews;
GO

CREATE TABLE ProductReviews (
    ReviewID int PRIMARY KEY,
    ProductID int FOREIGN KEY REFERENCES Products(ProductID),
    CustomerID nchar(5) FOREIGN KEY REFERENCES Customers(CustomerID),
    Rating int CHECK (Rating BETWEEN 1 AND 5),
    ReviewText nvarchar(max),
    ReviewDate datetime DEFAULT GETDATE()
);
GO

-- Question 8: Creating Views
-- Create a view named "vw_ProductSales" that shows ProductName, CategoryName, and TotalSales.
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ProductSales')
    DROP VIEW vw_ProductSales;
GO

CREATE VIEW vw_ProductSales AS
SELECT 
    p.ProductName,
    c.CategoryName,
    SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales
FROM 
    Products p
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductName, c.CategoryName;
GO

-- Question 9: Stored Procedures
-- Write a stored procedure named "sp_TopCustomersByCountry" that takes a country name as input
-- and returns the top 3 customers by total order amount for that country.
IF EXISTS (SELECT * FROM sys.procedures WHERE name = 'sp_TopCustomersByCountry')
    DROP PROCEDURE sp_TopCustomersByCountry;
GO

CREATE PROCEDURE sp_TopCustomersByCountry
    @CountryName nvarchar(15)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT TOP 3
        c.CustomerID,
        c.CompanyName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalOrderAmount
    FROM 
        Customers c
        INNER JOIN Orders o ON c.CustomerID = o.CustomerID
        INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
    WHERE 
        c.Country = @CountryName
    GROUP BY 
        c.CustomerID, c.CompanyName
    ORDER BY 
        TotalOrderAmount DESC;
END;
GO

-- Question 10: Complex Query
-- Write a query to find the employee who has processed orders for the most unique products.
-- Display the EmployeeID, FirstName, LastName, and the count of unique products they've processed.
SELECT TOP 1
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    COUNT(DISTINCT od.ProductID) AS UniqueProductsCount
FROM 
    Employees e
    INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
    INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    UniqueProductsCount DESC;
GO

-- Example of how to execute the stored procedure
EXEC sp_TopCustomersByCountry @CountryName = 'USA';
GO

-- Clean up (optional - comment these out if you want to keep the objects)
-- DROP TABLE IF EXISTS ProductReviews;
-- DROP VIEW IF EXISTS vw_ProductSales;
-- DROP PROCEDURE IF EXISTS sp_TopCustomersByCountry;
-- DELETE FROM Products WHERE ProductName = 'Northwind Coffee';


--Test your code by running the script at the command line in the Terminal
--sqlcmd -S localhost -U sa -P P@ssw0rd -d Northwind -i Module8-PracticeExam.sql