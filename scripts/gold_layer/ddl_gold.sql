/*
===============================================================================
DDL Script: Create Gold layer
===============================================================================
Script Purpose:
    This script creates views for aggregated business metrics in the Gold layer 
    of the data warehouse. These aggregates are business-ready and optimized 
    for analytics and reporting.

Usage:
    - These views can be queried directly by BI tools or analysts.
===============================================================================
*/

-- =============================================================================
-- Create Aggregate: gold.customer_sales_agg
-- =============================================================================
IF OBJECT_ID('gold.customer_sales_agg', 'V') IS NOT NULL
    DROP VIEW gold.customer_sales_agg;
GO

CREATE VIEW gold.customer_sales_agg AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.Country,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate,
    COUNT(DISTINCT s.OrderID) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.Quantity * s.UnitPrice), 2) AS TotalSales
FROM silver.dim_customers c
JOIN silver.fact_orders o 
    ON c.CustomerID = o.CustomerID
JOIN silver.fact_sales s 
    ON o.OrderID = s.OrderID
GROUP BY 
    c.CustomerID, 
    c.CompanyName, 
    c.Country;
GO

-- =============================================================================
-- Create Aggregate: gold.product_sales_agg
-- =============================================================================
IF OBJECT_ID('gold.product_sales_agg', 'V') IS NOT NULL
    DROP VIEW gold.product_sales_agg;
GO

CREATE VIEW gold.product_sales_agg AS
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryID,
    c.CategoryName,
    COUNT(DISTINCT fs.OrderID) AS TotalOrders,
    SUM(fs.Quantity) AS TotalQuantity,
    ROUND(SUM(fs.Quantity * fs.UnitPrice), 2) AS TotalSales
FROM silver.dim_products p
JOIN silver.dim_categories c 
    ON p.CategoryID = c.CategoryID
JOIN silver.fact_sales fs 
    ON p.ProductID = fs.ProductID
GROUP BY 
    p.ProductID,
    p.ProductName,
    c.CategoryID,
    c.CategoryName;
GO

-- =============================================================================
-- Create Aggregate: gold.sales_summary
-- =============================================================================
IF OBJECT_ID('gold.sales_summary', 'V') IS NOT NULL
    DROP VIEW gold.sales_summary;
GO

CREATE VIEW gold.sales_summary AS
SELECT 
    o.OrderDate,
    COUNT(DISTINCT s.OrderID) AS TotalOrders,
    SUM(s.Quantity) AS TotalQuantity,
    ROUND(SUM(s.UnitPrice * s.Quantity), 2) AS TotalSales,
    COUNT(DISTINCT o.CustomerID) AS UniqueCustomers,
    COUNT(DISTINCT s.ProductID) AS UniqueProductsSold
FROM silver.fact_orders o 
JOIN silver.fact_sales s 
    ON o.OrderID = s.OrderID
GROUP BY 
    o.OrderDate;
GO
