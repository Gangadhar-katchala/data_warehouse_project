USE DataWarehouse;
GO

/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source CSV → Bronze Tables)
===============================================================================
Purpose:
    Loads data into the Bronze layer tables from external CSV files.
    This process:
        1. Truncates each Bronze table before load.
        2. Uses BULK INSERT to load CSV data directly into the tables.

Parameters:
    None – This procedure does not accept input parameters or return values.

Example Usage:
    EXEC bronze.load_bronze;
===============================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze 
AS
BEGIN
    DECLARE 
        @start_time DATETIME, 
        @end_time DATETIME, 
        @batch_start_time DATETIME, 
        @batch_end_time DATETIME; 

    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Starting Bronze Layer Load';
        PRINT '================================================';

        --------------------------------------------------
        -- Load categories
        --------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating: bronze.categories';
        TRUNCATE TABLE bronze.categories;
        PRINT '>> Loading: bronze.categories';
        BULK INSERT bronze.categories
        FROM 'C:\Users\katch\Downloads\traders_dataset\categories.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------------
        -- Load customers
        --------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.customers;
        BULK INSERT bronze.customers
        FROM 'C:\Users\katch\Downloads\traders_dataset\customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------------
        -- Load products
        --------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.products;
        BULK INSERT bronze.products
        FROM 'C:\Users\katch\Downloads\traders_dataset\products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------------
        -- Load orders
        --------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.orders;
        BULK INSERT bronze.orders
        FROM 'C:\Users\katch\Downloads\traders_dataset\orders.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------------
        -- Load order_details
        --------------------------------------------------
        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.order_details;
        BULK INSERT bronze.order_details
        FROM 'C:\Users\katch\Downloads\traders_dataset\order_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        --------------------------------------------------
        -- End of Batch Load
        --------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '================================================';
        PRINT 'Bronze Layer Load Completed';
        PRINT 'Total Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '================================================';
    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH
END;
GO
