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
    # TODO add check if file is a directory and make error to user
    $headers = (Get-Content $file.FullName -First 1) -split ','

    # Parametrize CREATE query as string
    $createTable = @"
CREATE TABLE [dbo].[$tableName]
(
$(
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
    Write-Host "Created table: $tableName"
}
Write-Host
