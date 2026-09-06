# ************************************************************************************
# === SCRIPT VARIABLES ===
# Directory variables
param(
    [System.Data.SqlClient.SqlConnection]$Connection
)

$rootDir = $PSScriptRoot
$scriptsDir = Split-Path -Path $rootDir -Parent
$projectDir = Split-Path -Path $scriptsDir -Parent
$csvDir = Join-Path -Path $projectDir -ChildPath "Data/Bike_Store_Relational_Database"
$csvFiles = Get-ChildItem -Path $csvDir -Filter "*.csv"
# ************************************************************************************
# === CREATE TABLE QUERIES ===
# Try to connect to db with provided credentials
# For each file in CSV Data:
foreach ($file in $csvFiles)
{
    # Select table name and grab headers from file
    $tableName = $file.BaseName

    # Parametrize CREATE query as string
    $dropTable = "DROP TABLE [dbo].[$tableName]"
    # Create command, send text, execute query
    $command = $connection.CreateCommand()
    $command.CommandText = $dropTable
    [void]$command.ExecuteNonQuery()

    # Echo to host table creation
    Write-Host "Table Dropped: $tableName`n"
}
