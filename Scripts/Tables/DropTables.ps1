# ************************************************************************************
# === SCRIPT VARIABLES ===
# Directory variables
param(
    [System.Data.SqlClient.SqlConnection]$Connection,

    [string]$DataDirectory
)
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
# ************************************************************************************
# === CREATE TABLE QUERIES ===
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
