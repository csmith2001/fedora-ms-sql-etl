# ************************************************************************************
# === SCRIPT VARIABLES ===
param(
    [System.Data.SqlClient.SqlConnection]$Connection,

    [string]$DataBase
)
# ************************************************************************************
# === DROP DATABASE QUERIES ===
# Parametrize CREATE query as string
$dropDatabase = @"
IF DB_ID('$DataBase') IS NOT NULL
BEGIN
    ALTER DATABASE [$DataBase]
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [$DataBase];
END
"@
# Create command, send text, execute query
$command = $connection.CreateCommand()
$command.CommandText = $dropDatabase
[void]$command.ExecuteNonQuery()

# Echo to host dropped database
Write-Host "Dropped database: $DataBase`n"
