# Fedora MSSQL ETL

A small PowerShell ETL project I built while learning PowerShell, SQL Server, and bulk data processing.

The original goal was to get more comfortable working with large datasets involving exporting millions of SQL records to a text file. Rather than just reading documentation, I wanted to build something end-to-end.

## What it does

The project bootstraps a [SQL Server](https://www.microsoft.com/en-us/sql-server) database running in a [Podman](https://podman.io/) container and loads CSV data automatically.

The bootstrap process:

1. Connects to SQL Server
2. Drops the existing `SmithBikes` database (if present)
3. Creates a fresh `SmithBikes` database
4. Creates tables dynamically from CSV headers
5. Loads data using `SqlBulkCopy`

No manual table creation is required.

## Project Structure

Data was sourced from [Kaggle](https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database/data).

```text
Scripts
├── bootstrap.ps1
│
├── Database
│   ├── CreateDatabase.ps1
│   └── DropDatabase.ps1
│
└── Tables
    ├── CreateTables.ps1
    └── InsertData.ps1

Data
└── Bike_Store_Relational_Database
    ├── brands.csv
    ├── categories.csv
    ├── customers.csv
    ├── orders.csv
    ├── order_items.csv
    ├── products.csv
    ├── staffs.csv
    ├── stocks.csv
    └── stores.csv
```
