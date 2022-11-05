function New-Binary {
    param (
        [Parameter(Mandatory)]
        $ProjectFile,
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )
	
	& "C:\fpcupdeluxe\lazarus\lazbuild.exe" "--pcp=C:\fpcupdeluxe\config_lazarus", "--build-all", "--cpu=$TargetCpu", "--operating-system=$TargetOS", "SOURCE\$ProjectFile.lpi"
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





# Define our build targets
$Targets = "i386-go32v2", "i386-linux", "i386-win32", "x86_64-linux", "x86_64-win64"

# Loop through our build targets, building EDITOR and USURPER for each, and then zipping up the RELEASE directory along with the new binaries
try {

	Foreach ($Target in $Targets) {
        $CpuOS = $Target.Split("-")
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
