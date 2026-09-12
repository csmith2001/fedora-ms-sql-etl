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

    # Connection String
    $connectionString = @"
Server=sql2022,1433;
Database=master;
TrustServerCertificate=True;
User ID=$env:SA_USR;
Password=$env:SA_PASSWD;
"@

    # Connection
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString

    # Open connection & Echo success
    $connection.Open()
    Write-Host "Connected successfully...`n"

    Write-Host "Bootstrapping $database..."

    Write-Host "Dropping Database..."
    & "Scripts/Database/DropDatabase.ps1" -Connection $connection -Database $database

    Write-Host "Creating Database..."
    & "Scripts/Database/CreateDatabase.ps1" -Connection $connection -Database $database
    $connection.ChangeDatabase("$database")

    Write-Host "Creating Tables..."
    & "Scripts/Schema/CreateTables.ps1" -Connection $connection -DataDirectory $dataDir

    Write-Host "Loading Data..."
    & "Scripts/Tables/InsertData.ps1" -Connection $connection -DataDirectory $dataDir

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
