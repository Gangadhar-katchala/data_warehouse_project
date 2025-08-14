/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
	i	- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        ----------------------------
        -- Load dim_customers
        ----------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.dim_customers';
        TRUNCATE TABLE silver.dim_customers;

        PRINT '>> Inserting Data Into: silver.dim_customers';
        INSERT INTO silver.dim_customers (
            CustomerID, CompanyName, ContactName, ContactTitle, Address,
            City, Region, PostalCode, Country, Phone, Fax, create_date
        )
        SELECT
            LTRIM(RTRIM(CustomerID)) AS CustomerID,
            LTRIM(RTRIM(CompanyName)),
            LTRIM(RTRIM(ContactName)),
            LTRIM(RTRIM(ContactTitle)),
            LTRIM(RTRIM(Address)),
            LTRIM(RTRIM(City)),
            LTRIM(RTRIM(Region)),
            CASE 
                WHEN PostalCode IS NULL OR LTRIM(RTRIM(PostalCode)) = '' THEN NULL
                WHEN PostalCode NOT LIKE '%[^0-9]%' THEN PostalCode
                ELSE NULL
            END AS PostalCode,
            LTRIM(RTRIM(Country)),
            CASE 
                WHEN Phone IS NULL THEN NULL
                ELSE REPLACE(REPLACE(REPLACE(Phone, ' ', ''), '-', ''), '(', '')
            END AS Phone,
            CASE 
                WHEN Fax IS NULL THEN NULL
                ELSE REPLACE(REPLACE(REPLACE(Fax, ' ', ''), '-', ''), '(', '')
            END AS Fax,
            CAST(GETDATE() AS DATE) AS create_date
        FROM bronze.customers;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration (dim_customers): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ----------------------------
        -- Load fact_orders
        ----------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.fact_orders';
        TRUNCATE TABLE silver.fact_orders;

        PRINT '>> Inserting Data Into: silver.fact_orders';
        INSERT INTO silver.fact_orders (
            OrderID, CustomerID, EmployeeID, OrderDate, RequiredDate, ShippedDate,
            ShipVia, Freight, ShipName, ShipAddress, ShipCity, ShipRegion,
            ShipPostalCode, ShipCountry, create_date
        )
        SELECT
            OrderID,
            CustomerID,
            EmployeeID,
            TRY_CAST(OrderDate AS DATE),
            TRY_CAST(RequiredDate AS DATE),
            TRY_CAST(ISNULL(ShippedDate, RequiredDate) AS DATE),
            ShipVia,
            Freight,
            ShipName,
            LTRIM(RTRIM(ShipAddress)),
            LTRIM(RTRIM(ShipCity)),
            LTRIM(RTRIM(ShipRegion)),
            CASE 
                WHEN ShipPostalCode IS NULL OR LTRIM(RTRIM(ShipPostalCode)) = '' THEN NULL
                WHEN ShipPostalCode NOT LIKE '%[^0-9]%' THEN ShipPostalCode
                ELSE NULL
            END AS ShipPostalCode,
            LTRIM(RTRIM(ShipCountry)),
            CAST(GETDATE() AS DATE)
        FROM bronze.orders;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration (fact_orders): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ----------------------------
        -- Load fact_sales (order_details)
        ----------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.fact_sales';
        TRUNCATE TABLE silver.fact_sales;

        PRINT '>> Inserting Data Into: silver.fact_sales';
        INSERT INTO silver.fact_sales (
            OrderID, ProductID, UnitPrice, Quantity, Discount, create_date
        )
        SELECT
            OrderID,
            ProductID,
            UnitPrice,
            Quantity,
            Discount,
            CAST(GETDATE() AS DATE)
        FROM bronze.order_details;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration (fact_sales): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ----------------------------
        -- Load dim_products
        ----------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.dim_products';
        TRUNCATE TABLE silver.dim_products;

        PRINT '>> Inserting Data Into: silver.dim_products';
        INSERT INTO silver.dim_products (
            ProductID, ProductName, SupplierID, CategoryID, QuantityPerUnit,
            UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued, create_date
        )
        SELECT
            ProductID,
            LTRIM(RTRIM(ProductName)),
            SupplierID,
            CategoryID,
            QuantityPerUnit,
            UnitPrice,
            UnitsInStock,
            UnitsOnOrder,
            ReorderLevel,
            Discontinued,
            CAST(GETDATE() AS DATE)
        FROM bronze.products;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration (dim_products): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ----------------------------
        -- Load dim_categories
        ----------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.dim_categories';
        TRUNCATE TABLE silver.dim_categories;

        PRINT '>> Inserting Data Into: silver.dim_categories';
        INSERT INTO silver.dim_categories (
            CategoryID, CategoryName, Description, create_date
        )
        SELECT
            CategoryID,
            LTRIM(RTRIM(CategoryName)),
            LTRIM(RTRIM(Description)),
            CAST(GETDATE() AS DATE)
        FROM bronze.categories;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration (dim_categories): ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        ----------------------------
        -- Batch Complete
        ----------------------------
        SET @batch_end_time = GETDATE();
        PRINT '==========================================';
        PRINT 'Loading Silver Layer Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '==========================================';
    END TRY
    BEGIN CATCH
        PRINT '==========================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================';
    END CATCH
END;
GO
