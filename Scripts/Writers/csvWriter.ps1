param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory
)

$connectionString = @"
Server=sql2022,1433;
Database=TEST2;
TrustServerCertificate=True;
User ID=$env:SA_USR;
Password=$env:SA_PASSWD;
"@

$Connection = [System.Data.SqlClient.SqlConnection]::new($connectionString)
$Connection.Open()

Write-Host "Starting SQL CSV import..."
Write-Host "Connection status:" $Connection.State

$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"

Write-Host "Starting writer..."
Write-Host "Data Directory: $DataDirectory"
Write-Host "CSV Files Found: $($csvFiles.Count)"

foreach ($file in $csvFiles) {
    $tableName = $file.BaseName

    Write-Host "FILE: $($file.FullName)"
    Write-Host "Importing $tableName..."
}


$Connection.Close()
