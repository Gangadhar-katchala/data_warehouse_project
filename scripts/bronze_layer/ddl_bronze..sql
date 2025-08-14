/*
===============================================================================
DDL Script: Bronze Layer Table Creation 
===============================================================================
Purpose:
    Creates all Bronze tables inside the 'bronze' schema.
    Drops existing tables if they already exist.
===============================================================================
*/

USE DataWarehouse;
GO

----- Create bronze Schema if not exists -----
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

----- bronze.categories -----
IF OBJECT_ID('bronze.categories', 'U') IS NOT NULL
    DROP TABLE bronze.categories;
GO
CREATE TABLE bronze.categories (
    CategoryID     INT,
    CategoryName   NVARCHAR(255),
    Description    NVARCHAR(255)
);
GO

----- bronze.customers -----
IF OBJECT_ID('bronze.customers', 'U') IS NOT NULL
    DROP TABLE bronze.customers;
GO
CREATE TABLE bronze.customers (
    CustomerID     NVARCHAR(255),
    CompanyName    NVARCHAR(255),
    ContactName    NVARCHAR(255),
    ContactTitle   NVARCHAR(255),
    Address        NVARCHAR(255),
    City           NVARCHAR(255),
    Region         NVARCHAR(255),
    PostalCode     NVARCHAR(255),
    Country        NVARCHAR(255),
    Phone          NVARCHAR(255),
    Fax            NVARCHAR(255)
);
GO

----- bronze.order_details -----
IF OBJECT_ID('bronze.order_details', 'U') IS NOT NULL
    DROP TABLE bronze.order_details;
GO
CREATE TABLE bronze.order_details (
    OrderID     INT,
    ProductID   INT,
    UnitPrice   DECIMAL(10,2),
    Quantity    INT,
    Discount    DECIMAL(5,2)
);
GO

----- bronze.orders -----
IF OBJECT_ID('bronze.orders', 'U') IS NOT NULL
    DROP TABLE bronze.orders;
GO
CREATE TABLE bronze.orders (
    OrderID         INT,
    CustomerID      NVARCHAR(255),
    EmployeeID      NVARCHAR(255),
    OrderDate       NVARCHAR(255),
    RequiredDate    NVARCHAR(255),
    ShippedDate     NVARCHAR(255),
    ShipVia         INT,
    Freight         DECIMAL(10,2),
    ShipName        NVARCHAR(255),
    ShipAddress     NVARCHAR(255),
    ShipCity        NVARCHAR(255),
    ShipRegion      NVARCHAR(255),
    ShipPostalCode  NVARCHAR(255),
    ShipCountry     NVARCHAR(255)
);
GO

----- bronze.products -----
IF OBJECT_ID('bronze.products', 'U') IS NOT NULL
    DROP TABLE bronze.products;
GO
CREATE TABLE bronze.products (
    ProductID        INT,
    ProductName      NVARCHAR(255),
    SupplierID       INT,
    CategoryID       INT,
    QuantityPerUnit  NVARCHAR(255),
    UnitPrice        DECIMAL(10,2),
    UnitsInStock     INT,
    UnitsOnOrder     INT,
    ReorderLevel     INT,
    Discontinued     INT
);
GO
