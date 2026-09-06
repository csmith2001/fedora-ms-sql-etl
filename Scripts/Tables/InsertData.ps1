# ************************************************************************************
# === SCRIPT VARIABLES ===
# Directory variables
param(
    [System.Data.SqlClient.SqlConnection]$Connection,

    [string]$DataDirectory
)
$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
# ************************************************************************************
# === CREATE TABLE QUERIES ===
# Try to connect to db with provided credentials
# For each file in CSV Data:
foreach ($file in $csvFiles)
{
    $tableName = $file.BaseName
    $data = Import-Csv $file.FullName
    $dataTable = New-Object System.Data.DataTable

    foreach ($column in $data[0].PSObject.Properties.Name)
    {
        [void]$dataTable.Columns.Add($column)
    }

    foreach ($row in $data)
    {
        $newRow = $dataTable.NewRow()
        foreach ($column in $data[0].PSObject.Properties.Name)
        {
            $newRow[$column] = $row.$column
        }

        $dataTable.Rows.Add($newRow)
    }

    $bulkCopy = New-Object System.Data.SqlClient.SqlBulkCopy($Connection)
    $bulkCopy.DestinationTableName = "dbo.$tableName"
    $bulkCopy.WriteToServer($dataTable)

    Write-Host "Imported $($dataTable.Rows.Count) rows into $tableName"
}
