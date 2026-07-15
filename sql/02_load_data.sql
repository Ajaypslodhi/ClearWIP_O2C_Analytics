/* =========================================================================
   FILE: 02_load_data.sql
   PURPOSE: Load the 6 CSV files into the schema created in 01_schema.sql.
   DATABASE: ClearWIP
   ========================================================================= */

USE ClearWIP;
GO

/* =========================
   Load Clients
   ========================= */

BULK INSERT dbo.clients
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\clients.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Load Contracts
   ========================= */

BULK INSERT dbo.contracts
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\contracts.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Load Invoices
   ========================= */

BULK INSERT dbo.invoices
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\invoices.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Load Transactions
   ========================= */

BULK INSERT dbo.transactions
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\transactions.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Load Revenue WIP
   ========================= */

BULK INSERT dbo.revenue_wip
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\revenue_wip.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Load Audit Log
   ========================= */

BULK INSERT dbo.audit_log
FROM 'C:\Users\ajayp\Documents\My Projects\ClearWIP_O2C_Analytics\data\audit_log.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    CODEPAGE = '65001',
    TABLOCK
);
GO

/* =========================
   Sanity Check
   ========================= */

SELECT 'clients' AS TableName, COUNT(*) AS RowsLoaded FROM dbo.clients
UNION ALL
SELECT 'contracts', COUNT(*) FROM dbo.contracts
UNION ALL
SELECT 'invoices', COUNT(*) FROM dbo.invoices
UNION ALL
SELECT 'transactions', COUNT(*) FROM dbo.transactions
UNION ALL
SELECT 'revenue_wip', COUNT(*) FROM dbo.revenue_wip
UNION ALL
SELECT 'audit_log', COUNT(*) FROM dbo.audit_log;
GO
