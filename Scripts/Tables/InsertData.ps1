# *********************************************************************************
# Script parameters for invocation: './Scripts/Tables/InsertData.ps1 -Connection $connection -DataDirectory $dataDir'
param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory,
    [char]$SplitOn = ','
)
# *********************************************************************************
$delimiter = [System.Text.RegularExpressions.Regex]::Escape($SplitOn)
$splitPattern = "$delimiter(?=(?:[^""]*""[^""]*"")*[^""]*$)"
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
$batchSize = 20000
# *********************************************************************************
# For each file passed:
foreach ($file in $csvFiles) {
    # Set Table = FileName, write table name
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $tableName = $file.BaseName
    Write-Host "Importing $tableName..."
    # Open StreamReader on file being passed
    $reader = [System.IO.StreamReader]::new($file.FullName)
    try {
        # Find headers, initialize DataTable
        $headers = $reader.ReadLine() -split $splitPattern
        $dataTable = [System.Data.DataTable]::new()
     
        # Add each header to DataTable
        foreach ($header in $headers)
        {
            [void]$dataTable.Columns.Add($header)
        }
        # Create BulkCopy connection, set BatchSize
        $bulkCopy = [System.Data.SqlClient.SqlBulkCopy]::new($Connection)
        $bulkCopy.DestinationTableName = "[dbo].[$tableName]"
        $bulkCopy.BatchSize = $batchSize
        # Initialize total row count
        $totalRows = 0
        # While every line until end of stream
        while (-not $reader.EndOfStream)
        {
            # Set reader line
            $line = $reader.ReadLine()
            # If line is null or whitespace, continue
            if ([System.String]::IsNullOrWhiteSpace($line))
            {
                continue
            }
            # Set values to split line content, add as new row to DataTable
            $values = $line -split $splitPattern
            $newRow = $dataTable.NewRow()
            # 
            for ($i = 0; $i -lt $headers.Count; $i++)
            {
                # 
                if ($i -lt $values.Count)
                {
                    # 
                    $newRow[$i] = $values[$i]
                }
            }
            # 
            $dataTable.Rows.Add($newRow)
            # 
            if ($dataTable.Rows.Count -ge $batchSize) {
                # 
                $bulkCopy.WriteToServer($dataTable)
                $totalRows += $dataTable.Rows.Count
                # 
                Write-Host "Imported $totalRows rows..."
                $dataTable.Clear()
            }
        }
        # 
        if ($dataTable.Rows.Count -gt 0) {
            # 
            $bulkCopy.WriteToServer($dataTable)
            $totalRows += $dataTable.Rows.Count
            $dataTable.Clear()
        }
        # 
        Write-Host "Imported $totalRows rows into $tableName"
    }
    catch {
        Write-Error $_
}
    finally {
        # 
        $reader.Close()
        $stopwatch.Stop()
        Write-Host "Total import time: $($stopwatch.Elapsed)"
    }
}
