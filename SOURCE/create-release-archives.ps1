function New-Release-Archive {
    param (
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )

    Write-Output "Creating archive for CPU=$TargetCpu OS=$TargetOS"
    $TenMinutesAgo = (Get-Date).AddMinutes(-10)

    # Ensure EDITOR.EXE exists
    $EditorPath = "..\bin\$TargetCpu-$TargetOS\EDITOR.EXE"
    Write-Output " - Ensuring $EditorPath exists and was recently compiled"
    if (-not (Test-Path -Path $EditorPath -PathType Leaf)) {
        throw "$EditorPath does not exist"
    }
    if ((Get-Item -Path $EditorPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$EditorPath was compiled more than 10 minutes ago"
    }
    
    # Ensure USURPER.EXE exists
    $UsurperPath = "..\bin\$TargetCpu-$TargetOS\USURPER.EXE"
    Write-Output " - Ensuring $UsurperPath exists and was recently compiled"
    if (-not (Test-Path -Path $UsurperPath -PathType Leaf)) {
        throw "$UsurperPath does not exist"
    }
    if ((Get-Item -Path $UsurperPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$UsurperPath was compiled more than 10 minutes ago"
    }

    # Copy EDITOR.EXE and USURPER.EXE to RELEASE directory
    $ReleasePath = "..\RELEASE"
    Write-Output " - Copying $EditorPath to $ReleasePath"
    Copy-Item $EditorPath -Destination $ReleasePath
    Write-Output " - Copying $UsurperPath to $ReleasePath"
    Copy-Item $UsurperPath -Destination $ReleasePath

    # Create ZIP file
    $ZipPath = "..\usurper-$TargetCpu-$TargetOS.zip"
    if (Test-Path -Path $ZipPath -PathType Leaf) {
        Write-Output " - Deleting old $ZipPath"
        Remove-Item $ZipPath
    }

    Write-Output " - Creating new $ZipPath"
    Compress-Archive -Path "$ReleasePath\*" -DestinationPath $ZipPath
}

# Create a new ZIP file for each of the subdirectories under the bin directory
try {
    Get-ChildItem -Path ..\bin -Directory | ForEach-Object { 
        $CpuOS = $_.Name.Split("-")
        New-Release-Archive $CpuOS[0] $CpuOS[1]
    }
} catch {
    Write-Host "An error occurred:"
    Write-Host $_
}

# Pause before closing
Write-Host "Hit a key to quit"
$Key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
