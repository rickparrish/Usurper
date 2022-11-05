function New-Binary {
    param (
        [Parameter(Mandatory)]
        $ProjectFile,
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )
	
	& "C:\fpcupdeluxe\lazarus\lazbuild.exe" "--pcp=C:\fpcupdeluxe\config_lazarus", "--build-all", "--cpu=$TargetCpu", "--operating-system=$TargetOS", "$ProjectFile.lpi"
	if ($LASTEXITCODE -ne 0) {
		throw "lazbuild exited with exit code $LASTEXITCODE"
	}
}

function New-Release-Archive {
    param (
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )

    Write-Host "Creating archive for CPU=$TargetCpu OS=$TargetOS"
    $TenMinutesAgo = (Get-Date).AddMinutes(-10)

    # Ensure EDITOR.EXE exists
    $EditorPath = "..\bin\$TargetCpu-$TargetOS\EDITOR.EXE"
    Write-Host " - Ensuring $EditorPath exists and was recently compiled"
    if (-not (Test-Path -Path $EditorPath -PathType Leaf)) {
        throw "$EditorPath does not exist"
    }
    if ((Get-Item -Path $EditorPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$EditorPath was compiled more than 10 minutes ago"
    }
    
    # Ensure USURPER.EXE exists
    $UsurperPath = "..\bin\$TargetCpu-$TargetOS\USURPER.EXE"
    Write-Host " - Ensuring $UsurperPath exists and was recently compiled"
    if (-not (Test-Path -Path $UsurperPath -PathType Leaf)) {
        throw "$UsurperPath does not exist"
    }
    if ((Get-Item -Path $UsurperPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$UsurperPath was compiled more than 10 minutes ago"
    }

    # Copy EDITOR.EXE and USURPER.EXE to RELEASE directory
    $ReleasePath = "..\RELEASE"
    Write-Host " - Copying $EditorPath to $ReleasePath"
    Copy-Item $EditorPath -Destination $ReleasePath
    Write-Host " - Copying $UsurperPath to $ReleasePath"
    Copy-Item $UsurperPath -Destination $ReleasePath

    # Create ZIP file
    $ZipPath = "..\usurper-$TargetCpu-$TargetOS.zip"
    if (Test-Path -Path $ZipPath -PathType Leaf) {
        Write-Host " - Deleting old $ZipPath"
        Remove-Item $ZipPath
    }

    Write-Host " - Creating new $ZipPath"
    Compress-Archive -Path "$ReleasePath\*" -DestinationPath $ZipPath
}

# Create a new ZIP file for each of the subdirectories under the bin directory
try {
    Get-ChildItem -Path ..\bin -Directory | ForEach-Object { 
        $CpuOS = $_.Name.Split("-")
		New-Binary "EDITOR" $CpuOS[0] $CpuOS[1]
		New-Binary "USURPER" $CpuOS[0] $CpuOS[1]
        New-Release-Archive $CpuOS[0] $CpuOS[1]
    }
} catch {
    Write-Host "An error occurred:"
    Write-Host $_
}

# Pause if run via right-click option
if ($MyInvocation.InvocationName -eq "&")
{
    pause
}