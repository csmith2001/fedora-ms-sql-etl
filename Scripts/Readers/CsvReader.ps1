function Get-NextRow {
    param(
        [System.IO.StreamReader]$Reader,
        [char]$Delimiter = ',',
        [switch]$Quoted
    )
    if($Reader.EndOfStream) {
        return $null
    }
    $line = $Reader.ReadLine()

    if ($Quoted) {
        throw "Quoted TODO"
    }

    return $line.Split($Delimiter)
}

$Reader = [System.IO.StreamReader]::new(
    "Data/red-wine-quality-cortez-et-al-2009/winequality-red.csv"
)

$header = Get-NextRow -Reader $Reader -Delimiter ','
$header