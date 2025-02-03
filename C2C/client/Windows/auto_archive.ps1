function Create-Archive {
    param (
        [string]$destinationPath,
        [string]$fileName
    )

    # Define the zip file path
    $zipFilePath = "$destinationPath\$fileName.zip"
    $tempFolderPath = "$destinationPath\$fileName"

    # Validate path
    if (!(Test-Path $tempFolderPath)) {
        Write-Host "Error: Path $tempFolderPath does not exist" -ForegroundColor Red
        return $null
    }

    # Create the zip archive
    Compress-Archive -Path "$tempFolderPath\*" -Update -DestinationPath $zipFilePath

    # Clean up the temporary folder
    Remove-Item -Path $tempFolderPath -Recurse -Force

    Write-Host "Info: Archive created successfully at $zipFilePath" -ForegroundColor Green
    return $zipFilePath
}


# File Archiving
Write-Host "File Archiving....." -ForegroundColor Blue
$destinationPath = [System.Environment]::GetFolderPath('Temp')
$zipFileName = "Windows"
$zipFilePath = Create-Archive -destinationPath $destinationPath -fileName $zipFileName -files $scannedFiles
