param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory
)

$credential = Get-Credential
$user = $credential.UserName
$password = $credential.GetNetworkCredential().Password

$connectionString = @"
Server=sql2022,1433;
Database=TEST;
TrustServerCertificate=True;
User ID=$user;
Password=$password;
"@

$Connection = [System.Data.SqlClient.SqlConnection]::new($connectionString)

$Connection.Open()

Write-Host "Starting SQL Bulk import..."
Write-Host $Connection.State

$readerPath = Join-Path $PSScriptRoot "../Readers/CsvReader.ps1"
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
$batchSize = 10000
$totalRows = 0

Write-Host "Starting writer..."
Write-Host "Reader Path: $readerPath"
Write-Host "Data Directory: $DataDirectory"
Write-Host "CSV Files Found: $($csvFiles.Count)"

foreach ($file in $csvFiles)
{
    $tableName = $file.BaseName

    Write-Host "FILE: $($file.FullName)"
    Write-Host "Importing $tableName..."

    $bulkCopy = [System.Data.SqlClient.SqlBulkCopy]::new($Connection)
    $bulkCopy.DestinationTableName = "dbo.$tableName"
    $bulkCopy.BatchSize = $batchSize
    $batch = New-Object System.Data.DataTable
    $firstRow = $true

    & $readerPath `
        -Path $file.FullName `
        -HasHeaders |
    ForEach-Object {

        $row = $_
        if ($firstRow) {
            foreach ($column in $row.PSObject.Properties.Name) {
                [void]$batch.Columns.Add($column)
            }
            $firstRow = $false
        }

        $dataRow = $batch.NewRow()
        foreach ($column in $row.PSObject.Properties.Name) {
            $dataRow[$column] = $row.$column
        }

        $batch.Rows.Add($dataRow)
        if ($batch.Rows.Count -ge $batchSize) {
            $bulkCopy.WriteToServer($batch)
            $totalRows += $batch.Rows.Count
            Write-Host "Imported $totalRows rows..."
            $batch.Clear()
        }
    }

    if ($batch.Rows.Count -gt 0) {
        Write-Host "Writing batch of $($batch.Rows.Count)..."
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $bulkCopy.WriteToServer($batch)
        $totalRows += $batch.Rows.Count
        Write-Host "Imported $totalRows rows..."
        Write-Host "Batch completed in $($sw.Elapsed.TotalSeconds) sec"
        $sw.Stop()
    }
}

$Connection.Close()
