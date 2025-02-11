<#
.SYNOPSIS
Xiaoran System Image Builder

.DESCRIPTION
Build Windows image file with xrsys-osc, drivers and custom configurations.
#>

param(
    # Setting the target version to make
    [string]$Target,

    [switch]$FullDrv
)

$ErrorActionPreference = 'Stop'
$Server = "https://alist.xrgzs.top"

function Get-OsBySearch {
    param (
        $Path,
        $Search
    )
    # parse server file list
    $obj1 = (Invoke-WebRequest -Uri "$Server/api/fs/list" `
            -Method "POST" `
            -ContentType "application/json;charset=UTF-8" `
            -Body (@{
                path     = $Path
                page     = 1
                password = ""
                per_page = 0
                refresh  = $false
            } | Convertto-Json)).Content | ConvertFrom-Json
    
    # get original system direct link
    $obj2 = (Invoke-WebRequest -UseBasicParsing -Uri "$Server/api/fs/get" `
            -Method "POST" `
            -ContentType "application/json;charset=UTF-8" `
            -Body (@{
                path     = $Path + '/' + ($obj1.data.content | Where-Object -Property Name -Like $Search).name
                password = ""
            } | Convertto-Json)).Content | ConvertFrom-Json
    $out = @{}
    $out.osurl = $obj2.data.raw_url
    $out.osfile = $obj2.data.name
    return $out
}

# set original system info
switch ($Target) {
    "w1124h2a64" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/24H2/latest_arm64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/24H2/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_24H2_Pro_ARM64_CN_Full"
        $sysVerCN = "潇然系统_Win11_24H2_专业_ARM64_完整"
        Invoke-WebRequest https://c.xrgzs.top/unattend/arm64.xml -OutFile .\unattend.xml
    }
    "w1124h264" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/24H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/24H2/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_24H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_24H2_专业_x64_完整"
    }
    "w1123h2a64" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/23H2/latest_arm64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/23H2/" + $obj.os_version + '/' + $obj.name
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
        # $osurl = $obj.osurl
        # $osFile = $obj.osfile
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/23H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/23H2/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_23H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_23H2_专业_x64_完整"
    }
    "w1022h264" {
        # $obj = Get-OsBySearch -Path "/潇然工作室/System/Win10" -Search "MSUpdate_Win10_22H2*.esd"
        # $osurl = $obj.osurl
        # $osFile = $obj.osfile
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/10/22H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/10/22H2/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 4
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_22H2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_22H2_专业_x64_完整"
    }
    "w11lt2464" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/LTSC2024/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/LTSC2024/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win11_LTSC2024_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win11_LTSC2024_企业S_x64_完整"
    }
    "w11lt24a64" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/11/LTSC2024/latest_arm64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/11/LTSC2024/" + $obj.os_version + '/' + $obj.name
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
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/10/LTSC2021/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/10/LTSC2021/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSC2021_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSC2021_企业S_x64_完整"
    }
    "w10lt1964" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/10/LTSC2019/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/10/LTSC2019/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSC2019_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSC2019_企业S_x64_完整"
    }
    "w10lt1664" {
        $obj = (Invoke-WebRequest -Uri "$Server/d/mount/oofutech/MSUpdate/10/LTSB2016/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$Server/d/mount/oofutech/MSUpdate/10/LTSB2016/" + $obj.os_version + '/' + $obj.name
        $osFile = $obj.name
        $osIndex = 1
        $osVer = $obj.os_ver
        $osVersion = $obj.os_version
        $osArch = $obj.os_arch
        $sysVer = "XRSYS_Win10_LTSB2016_EntS_x64_CN_Full"
        $sysVerCN = "潇然系统_Win10_LTSB2016_企业S_x64_完整"
    }
    "w7pro64" {
        $obj = (Invoke-RestMethod https://c.xrgzs.top/OSList.json).'【更新】7_SP1_IE11_自选_64位_无驱动_原版无接管'
        $osurl = $obj.osurl2
        $osFile = $obj.osfile
        $osIndex = 4
        $osVer = '7'
        $osVersion = ($obj.osfile -split '_')[-2]
        $osArch = 'x64'
        $sysVer = "XRSYS_Win7_SP2_Pro_x64_CN_Full"
        $sysVerCN = "潇然系统_Win7_SP2_专业_x64_完整"
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
    }
    elseif ($osArch -eq "x64" -and [float]$osVersion -ge 10240.0) {
        # noDCH x64
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_noDCH_x64_Lite.iso"
    }
    elseif ($osArch -eq "x64" -and [float]$osVersion -ge 7600.0) {
        # Win7 x64
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win7x64_Lite.iso"
    }
    elseif ($osArch -eq "x86" -and [float]$osVersion -ge 7600.0) {
        # Win7 x86
        $osdrvurl = "$Server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win7x86_Lite.iso"
    }
    else {
        Write-Error "Cannot match related driver iso."
    }
    $sysVer = $sysVer + "_DrvCeo"
    $sysVerCN = $sysVerCN + "_驱动总裁"
}

# dealosdriver
if ($null -eq $osdrvurl) {
    if ($osArch -eq "x64" -and [float]$osVersion -ge 19041.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/NET/NET10x64.iso"
    }
    elseif ($osArch -eq "arm64" -and [float]$osVersion -ge 19041.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/NET/NET10a64.iso"
    }
    elseif ($osArch -eq "x64" -and [float]$osVersion -ge 10240.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin10x64.iso"
    }
    elseif ($osArch -eq "x64" -and [float]$osVersion -ge 7600.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin7x64.iso"
    }
    elseif ($osArch -eq "x86" -and [float]$osVersion -ge 7600.0) {
        $osdrvurl = "$Server/d/pxy/System/Driver/DP/DPWin7x86.iso"
    }
    else {
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

Remove-Item -Path $osFile -Force -ErrorAction SilentlyContinue 
.\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s16 -x16 -o "$osFile" "$osurl"
if ($?) { Write-Host "System Image Download Successfully!" } else { Write-Error "System Image Download Failed!" }

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
    }
    else {
        ."C:\Program Files\7-Zip\7z.exe" e -y "$osFile" sources\install.esd
        if (Test-Path -Path "install.esd") {
            Write-Host "extract esd Successfully!"
            $osFile = "install.esd"
            $osFilename = "install"
            $osFileext = ".esd"
        }
        else {
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
.\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s4 -x4 -d $mountDir -o osc.exe "$Server/d/pxy/Xiaoran%20Studio/Onekey/Config/osc.exe"
if ($?) { Write-Host "XRSYS-OSC Download Successfully!" } else { Write-Error "XRSYS-OSC Download Failed!" }
Copy-Item -Path ".\injectdeploy.bat" -Destination "$mountDir" -Force
Copy-Item -Path ".\unattend.xml" -Destination "$mountDir" -Force
& "$mountDir\injectdeploy.bat" /S
if ($?) { Write-Host "Inject Deploy Successfully!" } else { Write-Error "Inject Deploy Failed!" }
Remove-Item -Path "$mountDir\injectdeploy.bat" -ErrorAction SilentlyContinue 

# add drivers
.\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s16 -x16 -d .\temp -o drivers.iso "$osdrvurl"
if ($?) { Write-Host "Driver Download Successfully!" } else { Write-Error "Driver Download Failed!" }
$isopath = Resolve-Path -Path ".\temp\drivers.iso"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Copy-Item -Path "${isomount}:\" -Destination "$mountDir\Windows\WinDrive" -Recurse -Force -ErrorAction SilentlyContinue 
# Dismount-DiskImage -ImagePath $isopath 
."C:\Program Files\7-Zip\7z.exe" x -r -y ".\temp\drivers.iso" -o"$mountDir\Windows\WinDrive"
Remove-Item -Path $isopath -ErrorAction SilentlyContinue 

# add software pack
# .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s16 -x16 -d .\temp -o pack.7z "$Server/d/pxy/Xiaoran%20Studio/Onekey/Config/pack64.7z"
# ."C:\Program Files\7-Zip\7z.exe" x -r -y -p123 ".\temp\pack.7z" -o"$mountDir\Windows\Setup\Set\osc"
# if ($?) {Write-Host "software pack Download Successfully!"} else {Write-Error "software pack Download Failed!"}
# Remove-Item -Path ".\temp\pack.7z" -ErrorAction SilentlyContinue 
# Remove-Item -Path "$mountDir\Windows\Setup\Set\osc\搜狗拼音输入法.exe" -ErrorAction SilentlyContinue 
if ([int]$osVer -ge 10) {
    # add edge runtime Windows 10+ 
    $msedge = (Invoke-RestMethod https://github.com/Bush2021/edge_installer/raw/main/data.json)."msedge-stable-win-$osArch"
    .\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s16 -x16 -d "$mountDir\Windows\Setup\Set\osc\runtime\Edge" -o "$($msedge.文件名)" "$($msedge.下载链接)"
    if ($?) { Write-Host "Edge Download Successfully!" } else { Write-Error "Edge Download Failed!" }
}
.\bin\aria2c.exe -c -R --retry-wait=5 --check-certificate=false -s16 -x16 -d "$mountDir\Windows\Setup\Set\Run" -o 安装常用工具.exe "$Server/d/pxy/Xiaoran%20Studio/Tools/Tools.exe"
if ($?) { Write-Host "XRSYS-Tools Download Successfully!" } else { Write-Error "XRSYS-Tools Download Failed!" }
# add tag
# "isxrsys" > "$mountDir\Windows\Setup\zjsoftonlinexrsys.txt"

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
}

# write version
"${sysvercn}_${sysdate} 
${sysver}_${sysdate}
" | Out-File -FilePath "$mountDir\Windows\Version.txt" -Encoding gbk

# capture system image
# Write-Host "Packing $sysFile.wim, please wait..."
# New-WindowsImage -ImagePath ".\$sysFile.wim" -CapturePath "$mountDir" -Name $sysVer -Description $sysVerCN
.\bin\wimlib\wimlib-imagex.exe capture "$mountDir" "$sysFile.esd" "$sysVer" "$sysVerCN" --solid
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
.\bin\rclone.exe copy "$sysFile.esd" "oofutech:/Xiaoran Studio/System/Nightly/$sysDate" --progress
if ($?) { Write-Host "Upload Successfully!" } else { Write-Error "Upload Failed!" }
.\bin\rclone.exe copy "$sysFile.json" "oofutech:/Xiaoran Studio/System/Nightly/$sysDate" --progress
.\bin\rclone.exe copyto "$sysFile.json" "oofutech:/Xiaoran Studio/System/Nightly/$sysVer.json" --progress
