# Directories
$databaseScripts = "$PSScriptRoot/Database"
$tableScripts = "$PSScriptRoot/Tables"

# Try to connect to db with provided credentials
try {
    # Prompt for Data Directory
    $dataDir = Read-Host "Enter path to data directory"
    $dataDir = $dataDir.Trim("'`"")
    if (-not (Test-Path -Path $dataDir -PathType Container)) {
        throw "Directory does not exist: $dataDir"
    }

    # Prompt for database
    $database = Read-Host "Enter database name"
    if (!$database) {
        throw "Database can't be empty!"
    }

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

    # Open connection & Echo success
    $connection.Open()
    Write-Host "Connected successfully...`n"

    Write-Host "Bootstrapping $database..."

    Write-Host "Dropping Database..."
    & "$databaseScripts/DropDatabase.ps1" -Connection $connection -Database $database

    Write-Host "Creating Database..."
    & "$databaseScripts/CreateDatabase.ps1" -Connection $connection -Database $database
    $connection.ChangeDatabase("$database")

    Write-Host "Creating Tables..."
    & "$tableScripts/CreateTables.ps1" -Connection $connection -DataDirectory $dataDir

    Write-Host "Loading Data..."
    & "$tableScripts/InsertData.ps1" -Connection $connection -DataDirectory $dataDir

    Write-Host "Bootstrap for $database complete!"
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