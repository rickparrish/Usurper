function New-Binary {
    param (
        [Parameter(Mandatory)]
        $ProjectFile,
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )
	
	& "C:\fpcupdeluxe\fpc\bin\x86_64-win64\fpc.exe" "-B", "-T$TargetOS", "-P$TargetCpu", "-Mtp", "-Scgi", "-CX", "-O3", "-g", "-gl", "-Xs", "-XX", "-l", "-vewnhibq", "-FiSOURCE\$ProjectFile", "-FiSOURCE\COMMON", "-Fiobj\$TargetCpu-$TargetOS", "-FuSOURCE\COMMON", "-FUobj\$TargetCpu-$TargetOS\", "-FEbin\$TargetCpu-$TargetOS\", "-obin\$TargetCpu-$TargetOS\$ProjectFile.EXE", "SOURCE\$ProjectFile\$ProjectFile.PAS"
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
    $EditorPath = "bin\$TargetCpu-$TargetOS\EDITOR.EXE"
    Write-Host " - Ensuring $EditorPath exists and was recently compiled"
    if (-not (Test-Path -Path $EditorPath -PathType Leaf)) {
        throw "$EditorPath does not exist"
    }
    if ((Get-Item -Path $EditorPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$EditorPath was compiled more than 10 minutes ago"
    }
    
    # Ensure USURPER.EXE exists
    $UsurperPath = "bin\$TargetCpu-$TargetOS\USURPER.EXE"
    Write-Host " - Ensuring $UsurperPath exists and was recently compiled"
    if (-not (Test-Path -Path $UsurperPath -PathType Leaf)) {
        throw "$UsurperPath does not exist"
    }
    if ((Get-Item -Path $UsurperPath).LastWriteTime -lt $TenMinutesAgo) {
        throw "$UsurperPath was compiled more than 10 minutes ago"
    }

    # Copy EDITOR.EXE and USURPER.EXE to RELEASE directory
    $ReleasePath = "RELEASE"
    Write-Host " - Copying $EditorPath to $ReleasePath"
    Copy-Item $EditorPath -Destination $ReleasePath
    Write-Host " - Copying $UsurperPath to $ReleasePath"
    Copy-Item $UsurperPath -Destination $ReleasePath

    # Create ZIP file
    $ZipPath = "usurper-$TargetCpu-$TargetOS.zip"
    if (Test-Path -Path $ZipPath -PathType Leaf) {
        Write-Host " - Deleting old $ZipPath"
        Remove-Item $ZipPath
    }

    Write-Host " - Creating new $ZipPath"
    Compress-Archive -Path "$ReleasePath\*" -DestinationPath $ZipPath
}





# Loop through our build targets, building EDITOR and USURPER for each, and then zipping up the RELEASE directory along with the new binaries
$Targets = "i386-go32v2", "i386-linux", "i386-win32", "x86_64-linux", "x86_64-win64"
Foreach ($Target in $Targets) {
	$CpuOS = $Target.Split("-")
	New-Binary "EDITOR" $CpuOS[0] $CpuOS[1]
	New-Binary "USURPER" $CpuOS[0] $CpuOS[1]
	New-Release-Archive $CpuOS[0] $CpuOS[1]
}