param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory
)
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
$batchSize = 10000
foreach ($file in $csvFiles)
{
    $tableName = $file.BaseName
    Write-Host "Importing $tableName..."
    $reader = [System.IO.StreamReader]::new($file.FullName)
    try
    {
        $headers = $reader.ReadLine().Split(',')
        $dataTable = [System.Data.DataTable]::new()
        foreach ($header in $headers)
        {
            [void]$dataTable.Columns.Add($header)
        }
        $bulkCopy = [System.Data.SqlClient.SqlBulkCopy]::new($Connection)
        $bulkCopy.DestinationTableName = "[dbo].[$tableName]"
        $bulkCopy.BatchSize = $batchSize
        $totalRows = 0
        while (-not $reader.EndOfStream)
        {
            $line = $reader.ReadLine()
            if ([System.String]::IsNullOrWhiteSpace($line))
            {
                continue
            }
            $values = $line.Split(',')
            $newRow = $dataTable.NewRow()
            for ($i = 0; $i -lt $headers.Count; $i++)
            {
                if ($i -lt $values.Count)
                {
                    $newRow[$i] = $values[$i]
                }
            }
            $dataTable.Rows.Add($newRow)
            if ($dataTable.Rows.Count -ge $batchSize)
            {
                $bulkCopy.WriteToServer($dataTable)
                $totalRows += $dataTable.Rows.Count
                Write-Host "Imported $totalRows rows..."
                $dataTable.Clear()
            }
        }
        if ($dataTable.Rows.Count -gt 0)
        {
            $bulkCopy.WriteToServer($dataTable)
            $totalRows += $dataTable.Rows.Count
            $dataTable.Clear()
        }
        Write-Host "Imported $totalRows rows into $tableName"
    }
    finally
    {
        $reader.Close()
    }
}
