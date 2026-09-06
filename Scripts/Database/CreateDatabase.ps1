# ************************************************************************************
# === SCRIPT VARIABLES ===
param(
    [System.Data.SqlClient.SqlConnection]$Connection,

    [string]$DataBase
)
# ************************************************************************************
# === CREATE DATABASE QUERIES ===
# Parametrize CREATE query as string
    $createDatabase = "CREATE DATABASE [$DataBase];"
# Create command, send text, execute query
$command = $connection.CreateCommand()
$command.CommandText = $createDatabase
[void]$command.ExecuteNonQuery()

# Echo to host database creation
Write-Host "Created database: $DataBase`n"
