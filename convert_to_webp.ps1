Add-Type -AssemblyName System.Drawing

$inputFolder = "assets\images"
$outputFolder = "assets\images_webp"

if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder
}

Get-ChildItem "$inputFolder\*.png" | ForEach-Object {
    $inputPath = $_.FullName
    $outputPath = Join-Path $outputFolder ($_.BaseName + ".webp")
    $image = [System.Drawing.Image]::FromFile($inputPath)
    $image.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Webp)
    $image.Dispose()
    Write-Host "Converted $($_.Name) to WebP"
}