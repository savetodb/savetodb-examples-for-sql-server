CREATE PROCEDURE s08.CustOrderHist
    @CustomerID nchar(5)
AS

SELECT
    p.ProductName
    , SUM(od.Quantity) AS Total
FROM
    s08.OrderDetails od
    INNER JOIN s08.Orders o ON o.OrderID = od.OrderID
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID
WHERE
    o.CustomerID = @CustomerID
GROUP BY
    p.ProductName


GO

CREATE PROCEDURE s08.CustOrdersDetail
    @OrderID int
AS

SELECT
    p.ProductName
    , ROUND(od.UnitPrice, 2) AS UnitPrice
    , od.Quantity
    , CONVERT(int, od.Discount * 100) AS Discount
    , ROUND(CONVERT(money, od.Quantity * (1 - od.Discount) * od.UnitPrice), 2) AS ExtendedPrice
FROM
    s08.OrderDetails od
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID
WHERE
    od.ProductID = p.ProductID
    AND od.OrderID = @OrderID


GO

CREATE PROCEDURE s08.CustOrdersOrders
    @CustomerID nchar(5)
AS

SELECT
    o.OrderID
    , o.OrderDate
    , o.RequiredDate
    , o.ShippedDate
FROM
    s08.Orders o
WHERE
    o.CustomerID = @CustomerID
ORDER BY
    o.OrderID


GO

CREATE PROCEDURE s08.EmployeeSalesByCountry
    @BeginningDate datetime
    , @EndingDate datetime
AS

SELECT
    e.Country
    , e.LastName
    , e.FirstName
    , o.ShippedDate
    , o.OrderID
    ,  os.Subtotal AS SaleAmount
FROM
    OrderSubtotals os
    INNER JOIN s08.Orders o ON o.OrderID =  os.OrderID
    INNER JOIN s08.Employees e ON e.EmployeeID = o.EmployeeID
WHERE
    o.ShippedDate BETWEEN @BeginningDate AND @EndingDate


GO

CREATE PROCEDURE s08.SalesByCategory
    @CategoryName nvarchar(15)
    , @OrderYear nvarchar(4) = '1998'
AS

IF @OrderYear != '1996' AND @OrderYear != '1997' AND @OrderYear != '1998' SELECT @OrderYear = '1998'

SELECT
    p.ProductName
    , ROUND(SUM(CONVERT(decimal(14,2), od.Quantity * (1 - od.Discount) * od.UnitPrice)), 0) AS TotalPurchase
FROM
    s08.OrderDetails od
    INNER JOIN s08.Orders o ON o.OrderID = od.OrderID
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID
    INNER JOIN s08.Categories c ON c.CategoryID = p.CategoryID
WHERE
    c.CategoryName = @CategoryName
    AND SUBSTRING(CONVERT(nvarchar(22), o.OrderDate, 111), 1, 4) = @OrderYear
GROUP BY
    p.ProductName
ORDER BY
    p.ProductName


GO

CREATE PROCEDURE s08.SalesByYear
    @BeginningDate datetime
    , @EndingDate datetime
AS

SELECT
    o.ShippedDate
    , o.OrderID
    , os.Subtotal
    , DATENAME(yy, ShippedDate) AS [Year]
FROM
    OrderSubtotals os
    INNER JOIN s08.Orders o ON o.OrderID =  os.OrderID
WHERE
    o.ShippedDate BETWEEN @BeginningDate AND @EndingDate


GO

CREATE PROCEDURE s08.TenMostExpensiveProducts
AS

SET ROWCOUNT 10

SELECT
    p.ProductName AS TenMostExpensiveProducts
    , p.UnitPrice
FROM
    s08.Products p
ORDER BY
    p.UnitPrice DESC


GO

