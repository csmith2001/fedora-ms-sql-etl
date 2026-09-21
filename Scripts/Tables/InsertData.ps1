# *********************************************************************************
# === SETUP ===
param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory,
    [char]$SplitOn = ','
)

$delimiter = [System.Text.RegularExpressions.Regex]::Escape($SplitOn)
$splitPattern = "$delimiter(?=(?:[^""]*""[^""]*"")*[^""]*$)"
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
$batchSize = 20000
# *********************************************************************************
# === MAIN EXECUTION ===
# For each file passed, try import
foreach ($file in $csvFiles) {
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $tableName = $file.BaseName
    $reader = [System.IO.StreamReader]::new($file.FullName)

    Write-Host "Importing $tableName..."
    try {
        $headers = $reader.ReadLine() -split $splitPattern
        $dataTable = [System.Data.DataTable]::new()

        for ($i = 0; $i -lt $headers.Count; $i++) {
            if ($headers[$i].StartsWith('"') -and $headers[$i].EndsWith('"')) {
                $headers[$i] = $headers[$i].Substring(1, $headers[$i].Length -2) # Substring(startIndex, Length)
            }
        }
     
        foreach ($header in $headers) {
            [void]$dataTable.Columns.Add($header)
        }

        $bulkCopy = [System.Data.SqlClient.SqlBulkCopy]::new($Connection)
        $bulkCopy.DestinationTableName = "[dbo].[$tableName]"
        $bulkCopy.BatchSize = $batchSize
        $totalRows = 0

        while (-not $reader.EndOfStream) {
            $line = $reader.ReadLine()
            if ([System.String]::IsNullOrWhiteSpace($line)) {
                continue
            }
            $values = $line -split $splitPattern
            $newRow = $dataTable.NewRow()

            for ($i = 0; $i -lt $values.Count; $i++) {
                if ($values[$i].Length -gt 2 -and $values[$i].StartsWith('"') -and $values[$i].EndsWith('"')) {
                    $values[$i] = $values[$i].Substring(1, $values[$i].Length -2).Replace('""','"')
                }
            }
            
            for ($i = 0; $i -lt $headers.Count; $i++) {
                if ($i -lt $values.Count) {
                    $newRow[$i] = $values[$i]
                }
            }
            $dataTable.Rows.Add($newRow)

            if ($dataTable.Rows.Count -ge $batchSize) {
                $bulkCopy.WriteToServer($dataTable)
                $totalRows += $dataTable.Rows.Count
                $dataTable.Clear()
            }
        }

        if ($dataTable.Rows.Count -gt 0) {
            $bulkCopy.WriteToServer($dataTable)
            $totalRows += $dataTable.Rows.Count
            $dataTable.Clear()
        }
        Write-Host "Imported $totalRows rows into $tableName"
    } catch {
        Write-Error $_
    } finally {
        $reader.Close()
        $stopwatch.Stop()
        Write-Host "Total import time: $($stopwatch.Elapsed)"
    }
}
