# ****************************************************************************************************************************
# === SETUP ===
$module = "SqlServer"
$runType = "AdHoc"
$appName = "SmithLab"
$separator = "=" * 150

# Runtime variables
$runTime = Get-Date
$timeStamp = $runTime.ToString("yyyyMMddHHmmss")
$today = $runTime.ToString("yyyyMMdd")

# File specs
$delimiter = '@~'
$maxChars = "2147483647"
$runName = ($appName, $runType, $today) -join "_"
$metaHeader = @(
    "file_name",
    "table_schema",
    "date_run_start",
    "date_run_end",
    "output_file",
    "record_count",
    "summed_field_name",
    "summed_field_value"
) -join $delimiter

# Directory info
$rootDir = Join-Path ([System.IO.Path]::GetTempPath()) "mssql-output-extract"
$workDir = Join-Path $rootDir -ChildPath $runName
$logDir = Join-Path $rootDir -ChildPath "logs"
$logFile = Join-Path $logDir -ChildPath "${runName}_${timeStamp}.txt"

# Database connection
$server="sql2022"
$connectionString = @"
Server=$server,1433;
Database=master;
TrustServerCertificate=True;
User ID=$env:SA_USR;
Password=$env:SA_PASSWD;
"@
$query = @"
SELECT [name]
FROM [sys].[databases]
WHERE [database_id] > 4
ORDER BY [name];
"@

# ****************************************************************************************************************************
# === MAIN EXECUTION ===
# Create log directory + parents and start transcript
$runStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
[void](New-Item -Path $logDir -ItemType Directory -Force)
Start-Transcript -Path $logFile -Append
Write-Host "$separator"

if (Test-Path $workDir) { Remove-Item $workDir -Recurse -Force -ErrorAction Stop }
[void](New-Item -Path $workDir -ItemType Directory -Force)

# Display available databases and grab tables
try {
    Import-Module $module -Force -ErrorAction Stop
    $databases = @(Invoke-Sqlcmd -ConnectionString $connectionString -Query $query -MaxCharLength $maxChars -ErrorAction Stop)
    $databasesCount = $databases.Count

    Write-Host "Available Databases:"
    for ($i = 0; $i -lt $databasesCount; $i++) {
        Write-Host "$($i + 1)) $($databases[$i].name)"
    } 
    do { $selection = Read-Host "Choose a selection (q to quit)" }
    until (
        (
            [int]::TryParse($selection, [ref]$null) -and
            [int]$selection -ge 1 -and
            [int]$selection -le $databasesCount
        ) -or $selection -eq "q"
    )
    if ($selection -eq 'q') {
        Write-Host "Exiting..."
        exit 0
    }
    $database = $databases[[int]$selection - 1].name
    $connectionString = @"
Server=$server,1433;
Database=$database;
TrustServerCertificate=True;
User ID=$env:SA_USR;
Password=$env:SA_PASSWD;
"@

    Write-Host "Connecting to:"
    Write-Host "`tServer Name: $server"
    Write-Host "`tDatabase Name: $database"

    $query = @"
SELECT [TABLE_NAME]
FROM [INFORMATION_SCHEMA].[TABLES]
WHERE [TABLE_SCHEMA] = 'dbo'
  AND [TABLE_TYPE] = 'BASE TABLE'
ORDER BY [TABLE_NAME];
"@
    $tables = @(Invoke-Sqlcmd -ConnectionString $connectionString -Query $query -MaxCharLength $maxChars -ErrorAction Stop)
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

# Loop through each table in database
foreach ($table in $tables) {
    $tableStopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $table = $table.TABLE_NAME

    $fileName = "${appName}_${runType}_${table}_${today}.txt"
    $metaFile = "${appName}_${runType}_${table}_META_${today}.txt"
    $outFile = Join-Path -Path $workDir -ChildPath $fileName
    $outMeta = Join-Path -Path $workDir -ChildPath $metaFile

    $queryDateTime = Get-Date -f "yyyy-MM-dd${delimiter}HH:mm:ss"
    $queryDate = $queryDateTime.Split($delimiter)[0]
    $queryStart = $queryDateTime.Split($delimiter)[1]
    $query = "SELECT '$queryDate' AS sys_date, '$queryStart' AS sys_time, * FROM [dbo].[$table]"
    $queryEnd = Get-Date -f "HH:mm:ss"

    # Query data
    try {
        Write-Host "$separator"
        Write-Host "Table: $table"
        Write-Host "`tQuery: $query"
        $dataTable = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query -As DataTables -MaxCharLength $maxChars -ErrorAction Stop
    } catch {
        Write-Host "Error querying $table"
        Write-Host $_.Exception.Message
        exit 1
    }

    # Write data file
    try {
        Write-Host "`tCreating file: $outFile"
        $writer = New-Object System.IO.StreamWriter($outFile, $false)
        $columns = $dataTable.Columns | Select-Object -ExpandProperty ColumnName | ForEach-Object { $_.ToLower() }
        $writer.WriteLine($columns -join $delimiter)
        
        # Create arrays for numeric fields and their sums
        $numericFields = @{}
        $numericSums = @{}
        foreach ($column in $columns) { 
            $numericFields[$column] = $true
            $numericSums[$column] = 0.0 
        }

        # Loop through each row of data
        $rowCount = 0
        foreach ($row in $dataTable.Rows) {
            $rowCount ++
            $value = foreach ($column in $columns) {
                $data = $row[$column]
                if ($null -eq $data -or $data -is [DBNull]) { "" }
                else {
                    $stringValue = [string]$data -replace "`n", " "
                    $number = 0.0
                    if ($numericFields[$column]) { 
                        if ([double]::TryParse($stringValue, [ref]$number)) { 
                            $numericSums[$column] += $number
                        } else {
                            $numericFields[$column] = $false
                            $numericSums.Remove($column)
                        }
                    }
                    $stringValue
                }
            }
            $writer.WriteLine([string]::Join($delimiter, $value))
        }
    } catch {
        Write-Host "Error writing to file: $outFile"
        Write-Host $_.Exception.Message
        exit 1
    } finally {
        $writer.Dispose()
        Write-Host "`tRecord count: $rowCount"
    }

    # Sum fields if present
    $summedFields = @($numericFields.keys | Where-Object { $numericFields[$_] })
    $hasNumericField = $true -in $numericFields.Values
    $availableFields = @($summedFields)
    $selectedFields = @()
    
    try {
        if ($hasNumericField) {
            while ($availableFields.Count -gt 0) {
                Write-Host "`n`tAvailable fields:"
                for ($i = 0; $i -lt $availableFields.Count; $i++) {
                    Write-Host "`t$($i + 1)) $($availableFields[$i])"
                }
                do { $chooseSum = Read-Host "`n`tChoose a field to sum (Enter to finish)" }
                until (
                    [string]::IsNullOrWhiteSpace($chooseSum) -or
                    (
                        [int]::TryParse($chooseSum, [ref]$null) -and
                        [int]$chooseSum -ge 1 -and
                        [int]$chooseSum -le $availableFields.Count
                    )
                )
                if ([string]::IsNullOrWhiteSpace($chooseSum)) {
                    break
                }
                $field = $availableFields[[int]$chooseSum - 1]
                $selectedFields += $field
                $availableFields = @(
                    $availableFields |
                    Where-Object { $_ -ne $field }
                )
                foreach ($field in $selectedFields) {
                    $sum = $numericSums[$field]
                    Write-Host "`t$field Sum: $sum"
                }
            }
        }
    } catch {
        Write-Host "Error summing table: $table"
        Write-Host $_.Exception.Message
        exit 1
    } finally {
        Write-Host "`tCreating file: $outMeta"
        $writer = New-Object System.IO.StreamWriter($outMeta, $false)
        $lines = @($metaHeader)

        if ($selectedFields.Count -gt 0) {
            foreach ($field in $selectedFields) {
                $sum = $numericSums[$field]
                $lines += ($table, $appName, $tableStopWatch, $queryStart, $queryEnd, $outFile, $rowCount, $field, $sum) -join $delimiter
            }
        } else {
            $lines += ($table, $appName, $tableStopWatch, $queryStart, $queryEnd, $outFile, $rowCount, "", "") -join $delimiter
        }
        foreach ($line in $lines) {
            $writer.WriteLine($line)
        }
        Write-Host "`t$table completed in: $($tableStopWatch.Elapsed.TotalSeconds) seconds"
        $writer.Dispose()
    }
}
$destination = [System.IO.Path]::Combine(
    $PSScriptRoot,
    "Data",
    "Export",
    $database
)
$logDestination = (Join-Path $destination "logs")
if (Test-Path $destination) {
    Remove-Item $destination -Recurse -Force -ErrorAction Stop
}
[void](New-Item -Path $logDestination -ItemType Directory -Force -ErrorAction Stop)
Copy-Item -Path $workDir -Destination $destination -Recurse -Force
Copy-Item -Path $logFile -Destination $logDestination -Force
Stop-Transcript