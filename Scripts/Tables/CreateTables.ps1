<<<<<<< HEAD
=======
# ************************************************************************************
# === SCRIPT VARIABLES ===
# Directory variables
param(
    [System.Data.SqlClient.SqlConnection]$Connection
)

>>>>>>> e2feececa3e9632a625e3c1e609c5682f70e4308
$rootDir = $PSScriptRoot
$scriptsDir = Split-Path -Path $rootDir -Parent
$projectDir = Split-Path -Path $scriptsDir -Parent
$csvDir = Join-Path -Path $projectDir -ChildPath "Data/Bike_Store_Relational_Database"
$csvFiles = Get-ChildItem -Path $csvDir -Filter "*.csv"
<<<<<<< HEAD

foreach ($file in $csvFiles)
{
    $tableName = $file.BaseName
    $headers = (Get-Content $file.FullName -First 1) -split ','

=======
# ************************************************************************************
# === CREATE TABLE QUERIES ===
# For each file in CSV Data:
foreach ($file in $csvFiles)
{
    # Select table name and grab headers from file
    $tableName = $file.BaseName
    $headers = (Get-Content $file.FullName -First 1) -split ','

    # Parametrize CREATE query as string
>>>>>>> e2feececa3e9632a625e3c1e609c5682f70e4308
    $createTable = @"
CREATE TABLE [dbo].[$tableName]
(
$(
<<<<<<< HEAD
    ($headers | ForEach-Object {
        "[$_] NVARCHAR(MAX)"
    }) -join ",`n"
)
);
"@
    Write-Host $createTable
    Write-Host
}
=======
($headers | ForEach-Object {
    "[$_] NVARCHAR(MAX)"
}) -join ",`n"
)
);
"@
    # Create command, send text, execute query
    $command = $connection.CreateCommand()
    $command.CommandText = $createTable
    [void]$command.ExecuteNonQuery()

    # Echo to host table creation
    Write-Host "Created table: $tableName`n"
}
>>>>>>> e2feececa3e9632a625e3c1e609c5682f70e4308
