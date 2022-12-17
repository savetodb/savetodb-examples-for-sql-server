CREATE VIEW s08.AlphabeticalListOfProducts
AS

SELECT
    p.*
    , c.CategoryName
FROM
    s08.Products p
    INNER JOIN s08.Categories c ON c.CategoryID = p.CategoryID
WHERE
    p.Discontinued = 0


GO

CREATE VIEW s08.CurrentProductList
AS

SELECT
    p.ProductID
    , p.ProductName
FROM
    s08.Products AS p
WHERE
    p.Discontinued = 0


GO

CREATE VIEW s08.CustomerAndSuppliersByCity
AS

SELECT
    c.City
    , c.CompanyName
    , c.ContactName
    , 'Customers' AS Relationship
FROM
    s08.Customers c
UNION
SELECT
    c.City
    , c.CompanyName
    , c.ContactName
    , 'Suppliers' AS Relationship
FROM
    s08.Suppliers c


GO

CREATE VIEW s08.Invoices
AS

SELECT
    o.ShipName
    , o.ShipAddress
    , o.ShipCity
    , o.ShipRegion
    , o.ShipPostalCode
    , o.ShipCountry
    , o.CustomerID
    , c.CompanyName AS CustomerName
    , c.Address
    , c.City
    , c.Region
    , c.PostalCode
    , c.Country
    , e.FirstName + ' ' + e.LastName AS Salesperson
    , o.OrderID
    , o.OrderDate
    , o.RequiredDate
    , o.ShippedDate
    , s.CompanyName As ShipperName
    , od.ProductID
    , p.ProductName
    , od.UnitPrice
    , od.Quantity
    , od.Discount
    , CONVERT(money, od.UnitPrice * Quantity * (1 - Discount)/100) * 100 AS ExtendedPrice
    , o.Freight
FROM
    s08.OrderDetails od
    INNER JOIN s08.Orders o ON o.OrderID = od.OrderID
    INNER JOIN s08.Shippers s ON s.ShipperID = o.ShipVia
    INNER JOIN s08.Customers c ON o.CustomerID = c.CustomerID
    INNER JOIN s08.Employees e ON e.EmployeeID = o.EmployeeID
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID


GO

CREATE VIEW s08.OrderDetailsExtended
AS

SELECT
    od.OrderID
    , od.ProductID
    , p.ProductName
    , od.UnitPrice
    , od.Quantity
    , od.Discount
    , CONVERT(money, od.UnitPrice * od.Quantity * (1 - od.Discount)/100) * 100 AS ExtendedPrice
FROM
    s08.OrderDetails od
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID


GO

CREATE VIEW s08.OrdersQry
AS

SELECT
    o.OrderID
    , o.CustomerID
    , o.EmployeeID
    , o.OrderDate
    , o.RequiredDate
    , o.ShippedDate
    , o.ShipVia
    , o.Freight
    , o.ShipName
    , o.ShipAddress
    , o.ShipCity
    , o.ShipRegion
    , o.ShipPostalCode
    , o.ShipCountry
    , c.CompanyName
    , c.Address
    , c.City
    , c.Region
    , c.PostalCode
    , c.Country
FROM
    s08.Orders o
    INNER JOIN s08.Customers c ON o.CustomerID = c.CustomerID


GO

CREATE VIEW s08.OrderSubtotals
AS

SELECT
     od.OrderID
     , SUM(CONVERT(money, od.UnitPrice * od.Quantity * (1 - od.Discount) / 100) * 100) AS Subtotal
FROM
    s08.OrderDetails od
GROUP BY
    od.OrderID


GO

CREATE VIEW s08.ProductsAboveAveragePrice
AS

SELECT
    p.ProductName
    , p.UnitPrice
FROM
    s08.Products p
WHERE
    p.UnitPrice > (SELECT AVG(UnitPrice) FROM s08.Products)


GO

CREATE VIEW s08.ProductSalesFor1997
AS

SELECT
    c.CategoryName
    , p.ProductName
    , SUM(CONVERT(money, od.UnitPrice * od.Quantity * (1 - od.Discount)/100) * 100) AS ProductSales
FROM
    s08.OrderDetails od
    INNER JOIN s08.Orders o ON o.OrderID = od.OrderID
    INNER JOIN s08.Products p ON p.ProductID = od.ProductID
    INNER JOIN s08.Categories c ON c.CategoryID = p.CategoryID
WHERE
    o.ShippedDate BETWEEN '19970101' AND '19971231'
GROUP BY
    c.CategoryName
    , p.ProductName


GO

CREATE VIEW s08.CategorySalesFor1997
AS

SELECT
    ps.CategoryName
    , SUM(ps.ProductSales) AS CategorySales
FROM
    s08.ProductSalesFor1997 ps
GROUP BY
    ps.CategoryName


GO

CREATE VIEW s08.ProductsByCategory
AS

SELECT
    c.CategoryName
    , p.ProductName
    , p.QuantityPerUnit
    , p.UnitsInStock
    , p.Discontinued
FROM
    s08.Products p
    INNER JOIN s08.Categories c ON c.CategoryID = p.CategoryID
WHERE
    p.Discontinued = 0


GO

CREATE VIEW s08.QuarterlyOrders
AS

SELECT
    DISTINCT
    c.CustomerID
    , c.CompanyName
    , c.City
    , c.Country
FROM
    s08.Customers c
    INNER JOIN s08.Orders o ON c.CustomerID = o.CustomerID
WHERE
    o.OrderDate BETWEEN '19970101' AND '19971231'


GO

CREATE VIEW s08.SalesByCategory1997
AS

SELECT
    c.CategoryID
    , c.CategoryName
    , p.ProductName
    , SUM(ode.ExtendedPrice) AS ProductSales
FROM
    s08.OrderDetailsExtended ode
    INNER JOIN s08.Orders o ON o.OrderID = ode.OrderID
    INNER JOIN s08.Products p ON p.ProductID = ode.ProductID
    INNER JOIN s08.Categories c ON c.CategoryID = p.CategoryID
WHERE
    o.OrderDate BETWEEN '19970101' And '19971231'
GROUP BY
    c.CategoryID
    , c.CategoryName
    , p.ProductName


GO

CREATE VIEW s08.SalesTotalsByAmount
AS

SELECT
     os.Subtotal AS SaleAmount
     , o.OrderID
     , c.CompanyName
     , o.ShippedDate
FROM
    s08.Customers c
    INNER JOIN s08.Orders o ON o.CustomerID = c.CustomerID
    INNER JOIN s08.OrderSubtotals os ON os.OrderID = os.OrderID
WHERE
    os.Subtotal > 2500
    AND o.ShippedDate BETWEEN '19970101' And '19971231'


GO

CREATE VIEW s08.SummaryOfSalesByQuarter
AS

SELECT
    o.ShippedDate
    , o.OrderID
    , os.Subtotal
FROM
    s08.OrderSubtotals os
    INNER JOIN s08.Orders o ON o.OrderID = os.OrderID
WHERE
    o.ShippedDate IS NOT NULL


GO

CREATE VIEW s08.SummaryOfSalesByYear
AS

SELECT
    o.ShippedDate
    , o.OrderID
    , os.Subtotal
FROM
    s08.OrderSubtotals os
    INNER JOIN s08.Orders o ON o.OrderID = os.OrderID
WHERE
    o.ShippedDate IS NOT NULL


GO

