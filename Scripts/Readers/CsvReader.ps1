
param(
    [string]$Path,
    [char]$Delimiter = ',',
    [switch]$HasHeaders
)

$reader=[System.IO.StreamReader]::new($Path)

try {
    $firstLine=$reader.ReadLine()
 
    if ($HasHeaders) {
        $headers = $firstLine.Split($Delimiter)
    }
    else {
        values = $reader.ReadLine().Split($Delimiter)
        $headers = 1..($headers = $firstLine.Split($Delimiter).Count) |
            ForEach-Object { "Column$_" }
        $row = [ordered]@{}
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $row[$headers[$i]] = $values[$i]
        }
        [PSCustomObject]$row
    }
    while (-not $reader.EndOfStream) {
        $values = $reader.ReadLine().Split($Delimiter)
        $row = [ordered]@{}
        for ($i = 0; $i -lt $headers.Count; $i++) {
            $row[$headers[$i]] = $values[$i]
        }
        [PSCustomObject]$row
    }
} finally {
    $reader.Close()
}
