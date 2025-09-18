# Downloads CIFAR-10 python version and extracts to Assignment1/notebooks/data/
Param(
    [string]$TargetDir = "Assignment1/notebooks/data",
    [string]$Url = "https://www.cs.toronto.edu/~kriz/cifar-10-python.tar.gz"
)

$dest = Join-Path $PSScriptRoot $TargetDir
if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }

$filename = Split-Path $Url -Leaf
$local = Join-Path $PSScriptRoot $filename

Write-Host "Downloading $Url to $local..."
Invoke-WebRequest -Uri $Url -OutFile $local

Write-Host "Extracting $local to $dest..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($local, $dest)

Write-Host "Cleaning up..."
Remove-Item $local -Force

Write-Host "Done. Data available at: $dest"