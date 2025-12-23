#Requires -Version 7
<#
.SYNOPSIS
Xiaoran System Image Builder

.DESCRIPTION
Build Windows image file with xrsys-osc, drivers and custom configurations.
#>

param(
    # Setting the target version to make
    [string]$Target,

    # Add Full Drivers
    [switch]$FullDrv,

    # Set as the latest version
    [switch]$Latest
)

$ErrorActionPreference = 'Stop'
$Server = "https://alist.xrgzs.top"

function Invoke-Aria2Download {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Uri,

        [Parameter(Position = 1)]
        [string]$Destination,

        [Parameter(Position = 2)]
        [string]$Name,
        
        [switch]$Big,

        [string[]]$Options = @()
    )
    
    function Get-RedirectedUrl {
        param(
            [Parameter(Mandatory, ValueFromPipeline)][string]$Uri,
            [string]$UserAgent = "aria2/1.37.0"
        )
        try {
            while ($true) {
                $req = [System.Net.WebRequest]::Create($Uri)
                $req.UserAgent = $UserAgent
                $req.AllowAutoRedirect = $false
                $res = $req.GetResponse()
                $loc = $res.GetResponseHeader('Location')
                $res.Close()
                if ($loc) { $Uri = $loc } else { return $Uri }
            }
        } catch { return $Uri }
    }
    
    function Get-Aria2Error($exitcode) {
        $codes = @{
            0  = 'All downloads were successful'
            1  = 'An unknown error occurred'
            2  = 'Timeout'
            3  = 'Resource was not found'
            4  = 'Aria2 saw the specified number of "resource not found" error. See --max-file-not-found option'
            5  = 'Download aborted because download speed was too slow. See --lowest-speed-limit option'
            6  = 'Network problem occurred.'
            7  = 'There were unfinished downloads. This error is only reported if all finished downloads were successful and there were unfinished downloads in a queue when aria2 exited by pressing Ctrl-C by an user or sending TERM or INT signal'
            8  = 'Remote server did not support resume when resume was required to complete download'
            9  = 'There was not enough disk space available'
            10 = 'Piece length was different from one in .aria2 control file. See --allow-piece-length-change option'
            11 = 'Aria2 was downloading same file at that moment'
            12 = 'Aria2 was downloading same info hash torrent at that moment'
            13 = 'File already existed. See --allow-overwrite option'
            14 = 'Renaming file failed. See --auto-file-renaming option'
            15 = 'Aria2 could not open existing file'
            16 = 'Aria2 could not create new file or truncate existing file'
            17 = 'File I/O error occurred'
            18 = 'Aria2 could not create directory'
            19 = 'Name resolution failed'
            20 = 'Aria2 could not parse Metalink document'
            21 = 'FTP command failed'
            22 = 'HTTP response header was bad or unexpected'
            23 = 'Too many redirects occurred'
            24 = 'HTTP authorization failed'
            25 = 'Aria2 could not parse bencoded file (usually ".torrent" file)'
            26 = '".torrent" file was corrupted or missing information that aria2 needed'
            27 = 'Magnet URI was bad'
            28 = 'Bad/unrecognized option was given or unexpected option argument was given'
            29 = 'The remote server was unable to handle the request due to a temporary overloading or maintenance'
            30 = 'Aria2 could not parse JSON-RPC request'
            31 = 'Reserved. Not used'
            32 = 'Checksum validation failed'
        }
        if ($null -eq $codes[$exitcode]) {
            return 'An unknown error occurred'
        }
        return $codes[$exitcode]
    }

    # aria2 options
    $Options += @(
        '--no-conf=true'
        '--continue'
        '--allow-overwrite=true'
        '--summary-interval=0'
        '--remote-time=true'
        '--retry-wait=5'
        '--check-certificate=false'
    )

    # set task info
    $Uri = Get-RedirectedUrl -Uri $Uri
    $Options += "`"$Uri`""
    if ($Destination) {
        $Options += "--dir=`"$Destination`""
    }
    if ($Name) {
        $Options += "--out=`"$Name`""
    }
    if ($Big) {
        $Options += @(
            '-s16'
            '-x16'
        )
    }

    # build aria2 command
    $aria2 = "& .\bin\aria2c.exe $($Options -join ' ')"

    # handle aria2 console output
    Write-Host 'Starting download with aria2 ...' -ForegroundColor Green
    Write-Host "  Command: $aria2" -ForegroundColor Cyan
    Invoke-Command ([scriptblock]::Create($aria2))

    # handle aria2 error
    Write-Host ''
    if ($LASTEXITCODE -gt 0) {
        Write-Error "Download failed! (Error $LASTEXITCODE) $(Get-Aria2Error $lastexitcode)"
    }
}

# set original system info
switch ($Target) {
    "w1125h2a64" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/11/25H2/latest_arm64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/11/25H2/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_25H2_Pro_ARM64_CN_Full"
        $sysVerCN = "潇然系统_Win11_25H2_专业_ARM64_完整"
        Invoke-WebRequest https://c.xrgzs.top/unattend/arm64.xml -OutFile .\unattend.xml
    }
    "w1125h264" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/11/25H2/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/11/25H2/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_25H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_25H2_专业_x64_完整"
    }
    "w1123h2a64" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/11/23H2/latest_arm64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/11/23H2/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_23H2_Pro_ARM64_CN_Full"
        $sysVerCN = "潇然系统_Win11_23H2_专业_ARM64_完整"
        Invoke-WebRequest https://c.xrgzs.top/unattend/arm64.xml -OutFile .\unattend.xml
    }
    "w1123h264" {
        # $obj = Get-OsBySearch -Path "/潇然工作室/System/Win11" -Search "MSUpdate_Win11_23H2*.esd"
        # $osUrl = $obj.osurl
        # $osFile = $obj.osfile
        $obj = (Invoke-RestMethod https://c.xrgzs.top/OSList.json).'【更新】23H2_22631_自选_64位_无驱动_原版无接管_iso'
        $osMd5 = $obj.md5
        $osUrl = $obj.osurl2
        $osFile = $obj.osfile
        $osIndex = 3
        $osVer = '11'
        $osVersion = ($obj.osfile -split '\.')[0, 1] -join '.'
        $osArch = 'x64'
        $sysVer = "XRSYS_Win11_23H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_23H2_专业_x64_完整"
    }
    "w1022h264" {
        # $obj = Get-OsBySearch -Path "/潇然工作室/System/Win10" -Search "MSUpdate_Win10_22H2*.esd"
        # $osUrl = $obj.osurl
        # $osFile = $obj.osfile
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/10/22H2/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/10/22H2/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_22H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_22H2_专业_x64_完整"
    }
    "w11lt2464" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/11/LTSC2024/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/11/LTSC2024/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_LTSC2024_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_LTSC2024_企业S_x64_完整"
    }
    "w11lt24a64" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/11/LTSC2024/latest_arm64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/11/LTSC2024/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_LTSC2024_EntS_ARM64_CN_Full"
        $sysVerCN = "潇然系统_Win11_LTSC2024_企业S_ARM64_完整"
        Invoke-WebRequest https://c.xrgzs.top/unattend/arm64.xml -OutFile .\unattend.xml
    }
    "w10lt2164" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/10/LTSC2021/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/10/LTSC2021/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSC2021_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSC2021_企业S_x64_完整"
    }
    "w10lt1964" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/10/LTSC2019/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/10/LTSC2019/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSC2019_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSC2019_企业S_x64_完整"
    }
    "w10lt1664" {
        $obj = Invoke-RestMethod -Uri "$Server/d/pxy/System/MSUpdate/10/LTSB2016/latest_x64.json"
        $osUrl = "$Server/d/pxy/System/MSUpdate/10/LTSB2016/" + $obj.os_version + '/' + $obj.name
        $osMd5 = $obj.hash.md5
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSB2016_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSB2016_企业S_x64_完整"
    }
    "w7ult64" {
        $obj = (Invoke-RestMethod https://c.xrgzs.top/OSList.json).'【更新】7_SP1_IE11_自选_64位_无驱动_原版无接管'
        $osMd5 = $obj.md5
        $osUrl = $obj.osurl2
        $osFile = $obj.osfile
        $osIndex = 5
        $osVer = '7'
        $osVersion = ($obj.osfile -split '_')[-2]
        $osArch = 'x64'
        $sysVer = "XRSYS_Win7_SP1_Ult_x64_CN_Full"
        $sysVerCN = "潇然系统_Win7_SP1_旗舰_x64_完整"
        Invoke-WebRequest https://c.xrgzs.top/unattend/764bit.xml -OutFile .\unattend.xml
    }
    Default {
        Write-Error "Unknown version."
    }
}

if ($FullDrv) {
    if ($osArch -eq "x64" -and [float]$osVersion -ge 16299.0) {
        # DCH x64
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_Win11_x64_Lite.iso"
    } elseif ($osArch -eq "x64" -and [float]$osVersion -ge 10240.0) {
        # noDCH x64
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_noDCH_x64_Lite.iso"
    } elseif ($osArch -eq "x64" -and [float]$osVersion -ge 7600.0) {
        # Win7 x64
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win7x64_Lite.iso"
    } elseif ($osArch -eq "x86" -and [float]$osVersion -ge 7600.0) {
        # Win7 x86
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win7x86_Lite.iso"
    } else {
        Write-Error "Cannot match related driver iso."
    }
    $sysVer = $sysVer + "_DrvCeo"
    $sysVerCN = $sysVerCN + "_驱动总裁"
}

# dealosdriver
if ($null -eq $osdrvurl) {
    if ($osArch -eq "x64" -and [float]$osVersion -ge 19041.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/NET/NET10x64.iso"
    } elseif ($osArch -eq "arm64" -and [float]$osVersion -ge 19041.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/NET/NET10a64.iso"
    } elseif ($osArch -eq "x64" -and [float]$osVersion -ge 10240.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin10x64.iso"
    } elseif ($osArch -eq "x64" -and [float]$osVersion -ge 7600.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin7x64.iso"
    } elseif ($osArch -eq "x86" -and [float]$osVersion -ge 7600.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin7x86.iso"
    } else {
        Write-Error "Cannot match related driver iso."
    }
    $sysVer = $sysVer + "_Net"
    $sysVerCN = $sysVerCN + "_主板驱动"
}

# set version
Set-TimeZone -Id "China Standard Time" -PassThru
$sysDateFull = Get-Date
$sysDate = $sysDateFull | Get-Date -Format "yyyy.MM.dd"
$sysFile = "${sysver}_${sysdate}_${osversion}"

# remove temporaty files
Remove-Item -Path ".\temp\" -Recurse -ErrorAction SilentlyContinue 
New-Item -Path ".\bin\" -ItemType "directory" -ErrorAction SilentlyContinue 
New-Item -Path ".\temp\" -ItemType "directory" -ErrorAction SilentlyContinue 

# Installing dependencies
if (-not (Test-Path -Path ".\bin\rclone.conf")) {
    Write-Error "rclone conf not found"
}
if (-not (Test-Path -Path "C:\Program Files\7-Zip\7z.exe")) {
    Write-Error "7-zip not found, please install it manually!"
}
if (-not (Test-Path -Path ".\bin\aria2c.exe")) {
    Write-Host "aria2c not found, downloading..."
    Invoke-WebRequest -Uri 'https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip' -outfile .\temp\aria2.zip
    Expand-Archive -Path .\temp\aria2.zip -DestinationPath .\temp -Force
    Move-Item -Path .\temp\aria2-1.37.0-win-64bit-build1\aria2c.exe -Destination .\bin\aria2c.exe -Force
}
if (-not (Test-Path -Path ".\bin\wimlib\wimlib-imagex.exe")) {
    Write-Host "wimlib-imagex not found, downloading..."
    Invoke-WebRequest -Uri 'https://wimlib.net/downloads/wimlib-1.14.4-windows-x86_64-bin.zip' -outfile .\temp\wimlib.zip
    Expand-Archive -Path .\temp\wimlib.zip -DestinationPath .\bin\wimlib -Force
}
if (-not (Test-Path -Path ".\bin\rclone.exe")) {
    Write-Host "rclone not found, downloading..."
    Invoke-WebRequest -Uri 'https://downloads.rclone.org/rclone-current-windows-amd64.zip' -outfile .\temp\rclone.zip
    Expand-Archive -Path .\temp\rclone.zip -DestinationPath .\temp\ -Force
    Copy-Item -Path .\temp\rclone-*-windows-amd64\rclone.exe -Destination .\bin\rclone.exe
}

Write-Host "Downloading original system image..."
Remove-Item -Path $osFile -Force -ErrorAction SilentlyContinue 
Invoke-Aria2Download -Uri $osUrl -Name $osFile -Big

Write-Host "Verifying hash of original system image..."
if ($osMd5) {
    $downloadedMd5 = Get-FileHash -Path $osFile -Algorithm MD5 | Select-Object -ExpandProperty Hash
    Write-Host "Expected MD5: $osMd5"
    Write-Host "Actual   MD5: $downloadedMd5"
    if ($downloadedMd5 -ne $osMd5) {
        Write-Error "MD5 check failed, the file may be corrupted."
    } else {
        Write-Host "MD5 check passed."
    }
}

$osFileext = [System.IO.Path]::GetExtension("$osFile")
$osFilename = [System.IO.Path]::GetFileNameWithoutExtension("$osFile")

# extract iso
if ($osFileext -eq ".iso") {
    ."C:\Program Files\7-Zip\7z.exe" e -y "$osFile" sources\install.wim
    if (Test-Path -Path "install.wim") {
        Write-Host "extract iso Successfully!"
        $osFile = "install.wim"
        $osFilename = "install"
        $osFileext = ".wim"
    } else {
        ."C:\Program Files\7-Zip\7z.exe" e -y "$osFile" sources\install.esd
        if (Test-Path -Path "install.esd") {
            Write-Host "extract esd Successfully!"
            $osFile = "install.esd"
            $osFilename = "install"
            $osFileext = ".esd"
        } else {
            Write-Error "extract wim or esd failed!"
        }
    }
}
# convert esd to wim
# if ($osFileext -eq ".esd") {
#     .\bin\wimlib\wimlib-imagex.exe export "$osFile" all "$osFilename.wim" --compress fast
# }

# make xrsys image
# Create virtual disk
$vhdfile = Join-Path -Path (Get-Location) -ChildPath "sys.vhdx"
Remove-Item $vhdfile -ErrorAction SilentlyContinue 
@"
CREATE VDISK FILE="$vhdfile" MAXIMUM=102400 TYPE=EXPANDABLE
SELECT VDISK FILE="$vhdfile"
ATTACH VDISK
CREATE PARTITION PRIMARY
FORMAT FS=NTFS QUICK
ASSIGN LETTER=S
"@ | diskpart.exe
if ($?) { Write-Host "Create virtual disk Successfully!" } else { Write-Error "Create virtual disk Failed!" }
$mountDir = "S:"

# extract imagefile use wimlib-imagex
Write-Host "Extracting $osFile, please wait..."
.\bin\wimlib\wimlib-imagex.exe apply "$osFile" $osIndex "$mountDir"
# inject deploy
Expand-Archive -Path ".\injectdeploy.zip" -DestinationPath "$mountDir" -Force
Invoke-Aria2Download -Uri "$Server/d/pxy/Xiaoran%20Studio/Onekey/Config/osc.exe" -Destination $mountDir -Name "osc.exe"
Copy-Item -Path ".\injectdeploy.bat" -Destination "$mountDir" -Force
Copy-Item -Path ".\unattend.xml" -Destination "$mountDir" -Force
& "$mountDir\injectdeploy.bat" /S
if ($?) { Write-Host "Inject Deploy Successfully!" } else { Write-Error "Inject Deploy Failed!" }
Remove-Item -Path "$mountDir\injectdeploy.bat" -ErrorAction SilentlyContinue 

# add drivers
Invoke-Aria2Download -Uri $osdrvurl -Destination ".\temp" -Name "drivers.iso" -Big
if ($?) { Write-Host "Driver Download Successfully!" } else { Write-Error "Driver Download Failed!" }
$isopath = Resolve-Path -Path ".\temp\drivers.iso"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Copy-Item -Path "${isomount}:\" -Destination "$mountDir\Windows\WinDrive" -Recurse -Force -ErrorAction SilentlyContinue 
# Dismount-DiskImage -ImagePath $isopath 
."C:\Program Files\7-Zip\7z.exe" x -r -y ".\temp\drivers.iso" -o"$mountDir\Windows\WinDrive"
Remove-Item -Path $isopath -ErrorAction SilentlyContinue 

# add software pack
if ([int]$osVer -ge 10) {
    # add edge runtime Windows 10+ 
    $msedge = (Invoke-RestMethod https://raw.githubusercontent.com/Bush2021/edge_installer/main/data.json)."msedge-stable-win-$osArch"
    Invoke-Aria2Download -Uri $msedge.下载链接 -Destination "$mountDir\Windows\Setup\Set\osc\runtime\Edge" -Name $msedge.文件名 -Big
    # add pwsh runtime Windows 10+
    $pwshver = (Invoke-RestMethod https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/metadata.json).ReleaseTag -replace '^v'
    Invoke-Aria2Download -Uri "https://github.com/PowerShell/PowerShell/releases/download/v${pwshver}/PowerShell-${pwshver}-win-${osArch}.msi" -Destination "$mountDir\Windows\Setup\Set\osc\runtime\PWSH" -Name "PowerShell-${pwshver}-win.msi" -Big
} else {
    # add edge runtime Windows 8.1-
    Invoke-Aria2Download -Uri "$Server/d/pxy/Software/Edge/109/MicrosoftEdge_X64_109.0.1518.78_Stable.exe" -Destination "$mountDir\Windows\Setup\Set\osc\runtime\Edge" -Name "MicrosoftEdge_X64_109.0.1518.78_Stable.exe" -Big
    # add pwsh runtime Windows 8.1-
    Invoke-Aria2Download -Uri "$Server/d/pxy/Software/PowerShell/PowerShell-7.2.24-win-x64.msi" -Destination "$mountDir\Windows\Setup\Set\osc\runtime\PWSH" -Name "PowerShell-7.2.24-win-x64.msi" -Big
}

# add runtimes
Invoke-Aria2Download -Uri "$Server/d/pxy/Xiaoran%20Studio/Tools/Soft/MSVCRedist.AIO.exe" -Destination "$mountDir\Windows\Setup\Set\osc\runtime" -Name "MSVCRedist.AIO.exe" -Big
Invoke-Aria2Download -Uri "https://aka.ms/dotnet/8.0/windowsdesktop-runtime-win-$osArch.exe" -Destination "$mountDir\Windows\Setup\Set\osc\runtime\DotNet" -Name "windowsdesktop-runtime-win-$osArch.exe" -Big

# add another softwares
Invoke-Aria2Download -Uri "$Server/d/pxy/Xiaoran%20Studio/Tools/Tools.exe" -Destination "$mountDir\Windows\Setup\Set\Run" -Name "常用工具.exe" -Big
Invoke-Aria2Download -Uri "$Server/d/pxy/Xiaoran%20Studio/Tools/Office2016%E5%AD%97%E4%BD%93.exe" -Destination "$mountDir\Windows\Setup\Set\Run" -Name "办公字体.exe" -Big
Invoke-Aria2Download -Uri "$Server/d/pxy/Xiaoran%20Studio/Tools/Soft/Bandizip.exe" -Destination "$mountDir\Windows\Setup\Set\Run" -Name "Bandizip.exe" -Big

# remove preinstalled appx
if ([int]$osVer -ge 10) {
    $preinstalled = Get-AppxProvisionedPackage -Path "$mountDir"
    foreach ($appName in @(
            'clipchamp.clipchamp',
            'Microsoft.549981C3F5F10',
            'microsoft.microsoftteams',
            'microsoft.skypeapp',
            'microsoft.todos',
            'microsoft.bingnews',
            'microsoft.bingweather',
            'microsoft.windowscommunicationsapps',
            'microsoft.gethelp',
            'microsoft.getstarted',
            'microsoft.microsoft3dviewer',
            'microsoft.microsoftofficehub',
            'microsoft.microsoftsolitairecollection',
            'microsoft.microsoftstickynotes',
            'microsoft.mixedreality.portal',
            'microsoft.mspaint',
            'microsoft.office.onenote',
            'microsoft.OutlookForWindows',
            'microsoft.people',
            'microsoft.powerautomatedesktop',
            'microsoft.windowsfeedbackhub',
            'microsoft.windowsmaps',
            'microsoft.yourphone',
            'microsoft.zunemusic',
            'microsoft.zunevideo',
            'microsoft.xboxapp',
            'Microsoft.Wallet',
            'MicrosoftCorporationII.MicrosoftFamily',
            'MicrosoftTeams',
            'MicrosoftWindows.Client.WebExperience',
            'Microsoft.WidgetsPlatformRuntime',
            'Microsoft.Windows.DevHome',
            'MSTeams',
            'Microsoft.XboxGamingOverlay',
            'Microsoft.XboxSpeechToTextOverlay',
            'Microsoft.XboxIdentityProvider',
            'Microsoft.Xbox.TCUI'
        )) {
        $preinstalled | 
        Where-Object { $_.packagename -like "*$appName*" } | 
        Remove-AppxProvisionedPackage -Path "$mountDir" -ErrorAction SilentlyContinue 
    }
    # disable default wd
    Get-WindowsOptionalFeature -Path "$mountDir" | Where-Object { $_.FeatureName -like "*Defender*" } | Disable-WindowsOptionalFeature
    Get-WindowsOptionalFeature -Path "$mountDir" | Where-Object { $_.FeatureName -like "*Recall*" } | Disable-WindowsOptionalFeature
    
    # remove webview2 fod (hidden), do this in cleanupcomponents stage
    # Remove-WindowsCapability -Path "$mountDir" -Name "Edge.WebView2.Platform~~~~" -ErrorAction SilentlyContinue

    # remove defender sense client
    try {
        Get-WindowsCapability -Path "$mountDir" | Where-Object { $_.Name -like "*Sense.Client*" } | Remove-WindowsCapability -Path "$mountDir"
    } catch {
        Write-Host "No Defender Sense Client found, skipping..."
    }
}

# write version
"${sysvercn}_${sysdate} 
${sysver}_${sysdate}
" | Out-File -FilePath "$mountDir\Windows\Version.txt" -Encoding gbk

# capture system image
# Write-Host "Packing $sysFile.wim, please wait..."
# New-WindowsImage -ImagePath ".\$sysFile.wim" -CapturePath "$mountDir" -Name $sysVer -Description $sysVerCN
.\bin\wimlib\wimlib-imagex.exe capture "$mountDir" "$sysFile.esd" "$sysVer" "$sysVerCN" --solid  --image-property "DISPLAYNAME=$sysVer" --image-property "DISPLAYDESCRIPTION=$sysVerCN"
if ($?) { Write-Host "Capture Successfully!" } else { Write-Error "Capture Failed!" }

# clean up mount dir
# Dismount-DiskImage -Path "$mountDir" -Discard
@"
SELECT VDISK FILE="$vhdfile"
DETACH VDISK
"@  | diskpart.exe
if ($?) { Write-Host "Clean Up Successfully!" } else { Write-Error "Clean Up Failed!" }
Remove-Item $vhdfile -Force -ErrorAction SilentlyContinue

# convert to esd
# .\bin\wimlib\wimlib-imagex.exe export "$sysFile.wim" all "$sysFile.esd" --solid
# if ($?) { Write-Host "Convert Successfully!"} else {Write-Error "Convert Failed!"}

# Get file information
$sysFileByte = (Get-ItemProperty ".\$sysFile.esd").Length
$sysFileSize = [Math]::Round($sysFileByte / 1024 / 1024 / 1024, 2)
$sysFileMD5 = Get-FileHash ".\$sysFile.esd" -Algorithm MD5 | Select-Object -ExpandProperty Hash
$sysFileSHA256 = Get-FileHash ".\$sysFile.esd" -Algorithm SHA256 | Select-Object -ExpandProperty Hash
@{
    "sys" = @{
        "ver"      = [string]$sysVer
        "vercn"    = $sysVerCN
        "date"     = $sysDate
        "datefull" = $sysDateFull
        "file"     = "$sysFile.esd"
        "size"     = "$sysFileSize GB"
        "byte"     = $sysFileByte
        "md5"      = $sysFileMD5
        "sha256"   = $sysFileSHA256
        "url"      = "$Server/d/pxy/Xiaoran%20Studio/System/Nightly/$sysDate/$sysFile.esd"
    }
    "os"  = @{
        "arch"    = $osArch
        "ver"     = $osVer
        "version" = $osVersion
        "file"    = $osFile
        "index"   = $osIndex
    }
} | ConvertTo-Json | Out-File -FilePath ".\$sysFile.json" -Encoding utf8

# Publish image
.\bin\rclone.exe copy "$sysFile.esd" "odp:/Share/Xiaoran Studio/System/Nightly/$sysDate" --progress
if ($?) { Write-Host "Upload Successfully!" } else { Write-Error "Upload Failed!" }
.\bin\rclone.exe copy "$sysFile.json" "odp:/Share/Xiaoran Studio/System/Nightly/$sysDate" --progress
# Set latest
if ($Latest) {
    .\bin\rclone.exe copyto "$sysFile.json" "odp:/Share/Xiaoran Studio/System/Nightly/$sysVer.json" --progress
}