param (
    [switch]$Debug = $false
)
 
function New-Binary {
    param (
        [Parameter(Mandatory)]
        $ProjectFile,
        [Parameter(Mandatory)]
        $TargetCpu,
        [Parameter(Mandatory)]
        $TargetOS
    )
	
	if ($Debug) {
		$DebugFlags = "-g -gl"
	} else {
		$DebugFlags = "-CX -O3 -Xs -XX"
	}

	Write-Host "Building $ProjectFile for CPU=$TargetCpu and OS=$TargetOS with DebugFlags=$DebugFlags"
	
	# Create the bin and obj directories
	$null = New-Item -ItemType "Directory" -Path "bin\$TargetCpu-$TargetOS" -Force
	$null = New-Item -ItemType "Directory" -Path "obj\$TargetCpu-$TargetOS" -Force

	# Call fpc.exe to start the build
	# Parameters and their effect
	# -B 				Build all modules
	# -CX 				Create also smartlinked library
	# -g 				Generate debug information
	# -gl 				Use line info unit (show more info with backtraces)
	# -l 				Write logo
	# -Mtp 				TP/BP 7.0 compatibility mode
	# -O3 				Level 3 optimizations (-O2 + slow optimizations)
	# -P$TargetCpu 		Set target CPU
	# -Scgi 			Syntax options
	#					c=Support operators like C (*=,+=,/= and -=)
	#					g=Enable LABEL and GOTO (default in -Mtp and -Mdelphi)
	#					i=Turn on inlining of procedures/functions declared as "inline"
	# -T$TargetOS 		Target operating system
	# -vewnhibq 		Be verbose
	#					e=Show errors (default)
	#					w=Show warnings
	#					n=Show notes
	#					h=Show hints
	#					i=Show general info
	#					b=Write file names messages with full path
	#					q=Show message numbers
	# -Xs 				Executable options: Strip all symbols from executable
	# -XX 				Executable options: Try to smartlink units
	$Process = Start-Process -NoNewWindow -PassThru -Wait -FilePath "C:\fpcupdeluxe\fpc\bin\x86_64-win64\fpc.exe" -ArgumentList "-B -T$TargetOS -P$TargetCpu -Mtp -Scgi $DebugFlags -l -vewnhibq -FiSOURCE\$ProjectFile -FiSOURCE\COMMON -Fiobj\$TargetCpu-$TargetOS -FuSOURCE\COMMON -FUobj\$TargetCpu-$TargetOS\ -FEbin\$TargetCpu-$TargetOS\ -obin\$TargetCpu-$TargetOS\$ProjectFile.EXE SOURCE\$ProjectFile\$ProjectFile.PAS"
	if ($Process.ExitCode -ne 0) {
		throw "fpc.exe exited with exit code $($Process.ExitCode)"
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





# Confirm fpcupdeluxe is available in C:\fpcupdeluxe
$FpcupDir = "C:\fpcupdeluxe"
$FpcupZip = "fpcupdeluxe.zip"
$FpcupUrl = "https://github.com/rickparrish/fpcupdeluxe/releases/download/Usurper-3.2.2/fpcupdeluxe.zip"
if (!(Test-Path -Path $FpcupDir)) {
	Write-Host "Downloading $FpcupUrl"
	Invoke-WebRequest -Uri $FpcupUrl -OutFile $FpcupZip
	
	Write-Host "Extracting $FpcupZip to $FpcupDir"
	Expand-Archive $FpcupZip -DestinationPath $FpcupDir
}

# Loop through our build targets, building EDITOR and USURPER for each, and then zipping up the RELEASE directory along with the new binaries
$Targets = "i386-go32v2", "i386-linux", "i386-win32", "x86_64-linux", "x86_64-win64"
Foreach ($Target in $Targets) {
	$CpuOS = $Target.Split("-")
	New-Binary "EDITOR" $CpuOS[0] $CpuOS[1]
	New-Binary "USURPER" $CpuOS[0] $CpuOS[1]
	New-Release-Archive $CpuOS[0] $CpuOS[1]
}