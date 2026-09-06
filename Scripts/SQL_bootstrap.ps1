$databaseScripts = "$PSScriptRoot/Database"
$tableScripts = "$PSScriptRoot/Tables"

# Credentials
$credential = Get-Credential
$user = $credential.UserName
$password = $credential.GetNetworkCredential().Password

# Connection String
$connectionString = @"
Server=localhost,1433;
Database=Master;
TrustServerCertificate=True;
User ID=$user;
Password=$password
"@

# Connection
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString

# Try to connect to db with provided credentials
try {
    # Open connection & Echo success
    $connection.Open()
    Write-Host "Connected successfully...`n"

    Write-Host "Bootstrapping SmithBikes..."

    Write-Host "Dropping Database..."
    & "$databaseScripts/DropDatabase.ps1" -Connection $connection

    Write-Host "Creating Database..."
    & "$databaseScripts/CreateDatabase.ps1" -Connection $connection
    $connection.ChangeDatabase("SmithBikes")

    Write-Host "Creating Tables..."
    & "$tableScripts/CreateTables.ps1" -Connection $connection

    Write-Host "Loading Data..."
    & "$tableScripts/InsertData.ps1" -Connection $connection

    Write-Host "Bootstrap Complete."
}
# Do this if a terminating exception happens
catch {
    # Echo errors
    Write-Error $_
}
# Do this after the try block regardless of whether an exception occurred or not
finally {
    # Close connection
    $connection.Close()
}