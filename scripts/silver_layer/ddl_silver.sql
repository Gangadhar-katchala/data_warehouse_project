/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
Last Modified:
    YYYY-MM-DD  | Author Name | Description of Change
===============================================================================
*/

----- Create Silver Schema if not exists -----
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO


----- silver.categories -----
IF OBJECT_ID('silver.dim_categories', 'U') IS NOT NULL
    DROP TABLE silver.dim_categories;
GO
CREATE TABLE silver.dim_categories (
    CategoryID INT,
    CategoryName VARCHAR(50),
    Description VARCHAR(50),
    create_date DATE,
    updated_date DATETIME2 DEFAULT GETDATE()
);
GO

----- silver.customers -----
IF OBJECT_ID('silver.dim_customers', 'U') IS NOT NULL
    DROP TABLE silver.dim_customers;
GO
CREATE TABLE silver.dim_customers (
    CustomerID VARCHAR(50),
    CompanyName VARCHAR(50),
    ContactName VARCHAR(50),
    ContactTitle VARCHAR(50),
    Address VARCHAR(50),
    City VARCHAR(50),
    Region VARCHAR(50),
    PostalCode VARCHAR(50),
    Country VARCHAR(50),
    Phone VARCHAR(50),
    Fax VARCHAR(50),
    create_date DATE,
    updated_date DATETIME2 DEFAULT GETDATE()
);
GO

----- silver.order_details -----
IF OBJECT_ID('silver.fact_sales', 'U') IS NOT NULL
    DROP TABLE silver.fact_sales;
GO
CREATE TABLE silver.fact_sales (
    OrderID INT,
    ProductID INT,
    UnitPrice FLOAT,
    Quantity INT,
    Discount INT,
    create_date DATE,
    updated_date DATETIME2 DEFAULT GETDATE()
);
GO

----- silver.orders -----
IF OBJECT_ID('silver.fact_orders', 'U') IS NOT NULL
    DROP TABLE silver.fact_orders;
GO
CREATE TABLE silver.fact_orders (
    OrderID INT,
    CustomerID VARCHAR(50),
    EmployeeID VARCHAR(50),
    OrderDate VARCHAR(50),
    RequiredDate VARCHAR(50),
    ShippedDate VARCHAR(50),
    ShipVia INT,
    Freight FLOAT,
    ShipName VARCHAR(50),
    ShipAddress VARCHAR(50),
    ShipCity VARCHAR(50),
    ShipRegion VARCHAR(50),
    ShipPostalCode VARCHAR(50),
    ShipCountry VARCHAR(50),
    create_date DATE,
    updated_date DATETIME2 DEFAULT GETDATE()
);
GO

----- silver.products -----
IF OBJECT_ID('silver.dim_products', 'U') IS NOT NULL
    DROP TABLE silver.dim_products;
GO
CREATE TABLE silver.dim_products (
    ProductID INT,
    ProductName VARCHAR(50),
    SupplierID INT,
    CategoryID INT,
    QuantityPerUnit VARCHAR(50),
    UnitPrice FLOAT,
    UnitsInStock INT,
    UnitsOnOrder INT,
    ReorderLevel INT,
    Discontinued INT,
    create_date DATE,
    updated_date DATETIME2 DEFAULT GETDATE()
);
GO
