# ************************************************************************************
# === SCRIPT VARIABLES ===
# Directory variables
param(
    [System.Data.SqlClient.SqlConnection]$Connection,
    [string]$DataDirectory,
    [char]$SplitOn = ','
)

$csvFiles = Get-ChildItem -Path $DataDirectory -Filter "*.csv"
$delimiter = [System.Text.RegularExpressions.Regex]::Escape($SplitOn)
# ************************************************************************************
# === CREATE TABLE QUERIES ===
# For each file in CSV Data:
foreach ($file in $csvFiles)
{
    # Select table name and grab headers from file
    # TODO add check if file is a directory and make error to user
    $tableName = $file.BaseName
    $splitPattern = "$delimiter(?=(?:[^""]*""[^""]*"")*[^""]*$)"
    $reader = [System.IO.StreamReader]::new($file.FullName)
    $headers = $reader.ReadLine() -split $splitPattern

    for ($i = 0; $i -lt $headers.Count; $i++) {
        if ($headers[$i].StartsWith('"') -and $headers[$i].EndsWith('"')) {
            $headers[$i] = $headers[$i].Substring(1, $headers[$i].Length -2) # Substring(startIndex, Length)
        }
    }

    # Parametrize CREATE query as string
    $createTable = @"
CREATE TABLE [dbo].[$tableName]
(
$(
($headers | ForEach-Object {
    "[$_] NVARCHAR(MAX)"
}) -join ",`n"
)
);
"@
    # Create command, send text, execute query
    $command = $connection.CreateCommand()
    $command.CommandText = $createTable
    [void]$command.ExecuteNonQuery()

    # Echo to host table creation
    Write-Host "Created table: $tableName"
}
Write-Host
