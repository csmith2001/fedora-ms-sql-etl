$rootDir = $PSScriptRoot
$scriptsDir = Split-Path -Path $rootDir -Parent
$projectDir = Split-Path -Path $scriptsDir -Parent
$csvDir = Join-Path -Path $projectDir -ChildPath "Data/Bike_Store_Relational_Database"
$csvFiles = Get-ChildItem -Path $csvDir -Filter "*.csv"

foreach ($file in $csvFiles)
{
    $tableName = $file.BaseName
    $headers = (Get-Content $file.FullName -First 1) -split ','

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
    Write-Host $createTable
    Write-Host
}