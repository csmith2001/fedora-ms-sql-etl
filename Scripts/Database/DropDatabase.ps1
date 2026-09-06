# ************************************************************************************
# === SCRIPT VARIABLES ===
param(
    [System.Data.SqlClient.SqlConnection]$Connection
)
# ************************************************************************************
# === DROP DATABASE QUERIES ===
# Parametrize CREATE query as string
$dropDatabase = @"
IF DB_ID('SmithBikes') IS NOT NULL
BEGIN
    ALTER DATABASE [SmithBikes]
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [SmithBikes];
END
"@
# Create command, send text, execute query
$command = $connection.CreateCommand()
$command.CommandText = $dropDatabase
[void]$command.ExecuteNonQuery()

# Echo to host dropped database
Write-Host "Dropped database: SmithBikes`n"
