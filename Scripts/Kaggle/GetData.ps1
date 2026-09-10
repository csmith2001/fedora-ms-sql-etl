do {
  $input_url=Read-Host "Enter Kaggle dataset URL"
  $input_pattern="^(https:\/\/)?(www\.)?kaggle.com\/datasets\/([^\/]+)\/([^\/]+)$"

  if ($input_url -match $input_pattern) {
    $kaggleAPI="v1"
    $kaggleBase="https://www.kaggle.com/api/$kaggleAPI/datasets/download"
    $kaggleUser=$Matches[3]
    $kaggleDataset=$Matches[4]
    $zipFile="/tmp/$kaggleDataset.zip"
    $targetDir="/stream-write/Data/$kaggleDataset/"
    $downloadURL="$kaggleBase/$kaggleUser/$kaggleDataset"

    Invoke-WebRequest `
      -Uri $downloadURL `
      -OutFile $zipFile

    New-Item `
      -ItemType Directory `
      -Path $targetDir `
      -Force | Out-Null

    Write-Host "Extracting dataset..."
    Expand-Archive `
      -Path $zipFile `
      -DestinationPath $targetDir `
      -Force

    Remove-Item -Path $zipFile -Force
  } else {
      Write-Host "Invalid URL!" -ForegroundColor Red
    }
} while ($input_url -notmatch $input_pattern)

Write-Host "Extracted Dataset: $kaggleDataset"
