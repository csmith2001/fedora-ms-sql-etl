# ************************************************************************************
# === SCRIPT VARIABLES ===
param(
    [System.Data.SqlClient.SqlConnection]$Connection
)
# ************************************************************************************
# === CREATE DATABASE QUERIES ===
# Parametrize CREATE query as string
    $createDatabase = "CREATE DATABASE [SmithBikes];"
# Create command, send text, execute query
$command = $connection.CreateCommand()
$command.CommandText = $createDatabase
[void]$command.ExecuteNonQuery()

# Echo to host database creation
Write-Host "Created database: SmithBikes`n"
