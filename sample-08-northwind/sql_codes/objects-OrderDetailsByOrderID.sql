SELECT
    d.OrderID
    , d.ProductID
    , p.ProductName
    , p.QuantityPerUnit
    , d.UnitPrice
    , d.Quantity
    , ROUND(d.UnitPrice * d.Quantity * (1 - d.Discount), 2) AS [Sum]
    , CAST(d.Discount AS money) AS Discount
FROM
    s08.OrderDetails d
    INNER JOIN s08.Products p ON p.ProductID = d.ProductID
WHERE
    d.OrderID = @OrderID