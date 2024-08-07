$ErrorActionPreference = 'Stop'
$server = "https://alist.xrgzs.top"

function Get-OsBySearch {
    param (
        $Path,
        $Search
    )
    # parse server file list
    $obj1 = (Invoke-WebRequest -Uri "$server/api/fs/list" `
    -Method "POST" `
    -ContentType "application/json;charset=UTF-8" `
    -Body (@{
        path = $Path
        page = 1
        password = ""
        per_page = 0
        refresh = $false
    } | Convertto-Json)).Content | ConvertFrom-Json
    
    # get original system direct link
    $obj2 = (Invoke-WebRequest -UseBasicParsing -Uri "$server/api/fs/get" `
    -Method "POST" `
    -ContentType "application/json;charset=UTF-8" `
    -Body (@{
        path = $Path+'/'+($obj1.data.content | Where-Object -Property Name -Like $Search).name
        password = ""
    } | Convertto-Json)).Content | ConvertFrom-Json
    $out = @{}
    $out.osurl = $obj2.data.raw_url
    $out.osfile = $obj2.data.name
    return $out
}

# set original system info
switch ($makeversion) {
    "w1124h264" {
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/11/24H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/11/24H2/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 4
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win11_24H2_Pro_x64_CN_Full"
        $sysvercn = "潇然系统_Win11_24H2_专业_x64_完整"
    }
    "w1123h264" {
        # $obj = Get-OsBySearch -Path "/潇然工作室/System/Win11" -Search "MSUpdate_Win11_23H2*.esd"
        # $osurl = $obj.osurl
        # $osfile = $obj.osfile
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/11/23H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/11/23H2/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 4
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win11_23H2_Pro_x64_CN_Full"
        $sysvercn = "潇然系统_Win11_23H2_专业_x64_完整"
    }
    "w1022h264" {
        # $obj = Get-OsBySearch -Path "/潇然工作室/System/Win10" -Search "MSUpdate_Win10_22H2*.esd"
        # $osurl = $obj.osurl
        # $osfile = $obj.osfile
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/10/22H2/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/10/22H2/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 4
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win10_22H2_Pro_x64_CN_Full"
        $sysvercn = "潇然系统_Win10_22H2_专业_x64_完整"
    }
    "w11lt2464" {
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/11/LTSC2024/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/11/LTSC2024/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 1
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win11_LTSC2024_EntS_x64_CN_Full"
        $sysvercn = "潇然系统_Win11_LTSC2024_企业S_x64_完整"
    }
    "w10lt2164" {
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/10/LTSC2021/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/10/LTSC2021/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 1
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win10_LTSC2021_EntS_x64_CN_Full"
        $sysvercn = "潇然系统_Win10_LTSC2021_企业S_x64_完整"
    }
    "w10lt1964" {
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/10/LTSC2019/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/10/LTSC2019/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 1
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win10_LTSC2019_EntS_x64_CN_Full"
        $sysvercn = "潇然系统_Win10_LTSC2019_企业S_x64_完整"
    }
    "w10lt1664" {
        $obj = (Invoke-WebRequest -Uri "$server/d/mount/oofutech/MSUpdate/10/LTSB2016/latest_x64.json").Content | ConvertFrom-Json
        $osurl = "$server/d/mount/oofutech/MSUpdate/10/LTSB2016/" + $obj.os_version + '/' + $obj.name
        $osfile = $obj.name
        $osindex = 1
        $osver = $obj.os_ver
        $osversion = $obj.os_version
        $sysver = "XRSYS_Win10_LTSB2016_EntS_x64_CN_Full"
        $sysvercn = "潇然系统_Win10_LTSB2016_企业S_x64_完整"
    }
    Default {
        Write-Error "Unknown version.
        Example:
            `$makeversion = [string] `"w1123h264`"
            .\makexrsys.ps1
        "
    }
}

if ($isosd -eq $true) {
    if ($sysver -like "*LTSB2016*") {
        $osdrvurl = "$server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_noDCH_x64_Lite.iso"
    } else {
        $osdrvurl = "$server/d/pxy/System/Driver/DrvCeo_Mod/Drvceo_Win10_Win11_x64_Lite.iso"
    }
    $sysver = $sysver + "_DrvCeo"
    $sysvercn = $sysvercn + "_驱动总裁"
}

# dealosdriver
if ($null -eq $osdrvurl) {
    $osdrvurl = "$server/d/pxy/System/Driver/DP/DPWin10x64.iso"
    $sysver = $sysver + "_Net"
    $sysvercn = $sysvercn + "_主板驱动"
}

# set version
Set-TimeZone -Id "China Standard Time" -PassThru
$sysdate = Get-Date -Format "yyyy.MM.dd.HHmm"
$sysfile = "${sysver}_${sysdate}_${osversion}"

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

Remove-Item -Path $osfile -Force -ErrorAction SilentlyContinue 
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -o "$osfile" "$osurl"
if ($?) {Write-Host "System Image Download Successfully!"} else {Write-Error "System Image Download Failed!"}

$osfileext = [System.IO.Path]::GetExtension("$osfile")
$osfilename = [System.IO.Path]::GetFileNameWithoutExtension("$osfile")

# extract iso
if ($osfileext -eq ".iso") {
    ."C:\Program Files\7-Zip\7z.exe" e -y "$osfile" sources\install.wim
    if (Test-Path -Path "install.wim") {
        Write-Host "extract iso Successfully!"
        $osfile = "install.wim"
        $osfilename = "install"
        $osfileext = ".wim"
    } else {
        ."C:\Program Files\7-Zip\7z.exe" e -y "$osfile" sources\install.esd
        if (Test-Path -Path "install.esd") {
            Write-Host "extract esd Successfully!"
            $osfile = "install.esd"
            $osfilename = "install"
            $osfileext = ".esd"
        } else {
            Write-Error "extract iso or esd failed!"
        }
    }
}
# convert esd to wim
if ($osfileext -eq ".esd") {
    .\bin\wimlib\wimlib-imagex.exe export "$osfile" all "$osfilename.wim" --compress fast
}

# make xrsys image
# mount image
New-Item -Path ".\mount\" -ItemType "directory" -ErrorAction SilentlyContinue 
Write-Host "Mounting $osfilename.wim, please wait..."
Mount-WindowsImage -ImagePath "$osfilename.wim" -Index $osindex -Path "mount"
# inject deploy
Expand-Archive -Path ".\injectdeploy.zip" -DestinationPath ".\mount" -Force
.\bin\aria2c.exe --check-certificate=false -s4 -x4 -d .\mount -o osc.exe "$server/d/pxy/Xiaoran%20Studio/Onekey/Config/osc.exe"
if ($?) {Write-Host "XRSYS-OSC Download Successfully!"} else {Write-Error "XRSYS-OSC Download Failed!"}
Copy-Item -Path ".\injectdeploy.bat" -Destination ".\mount" -Force
Copy-Item -Path ".\unattend.xml" -Destination ".\mount" -Force
.\mount\injectdeploy.bat /S
if ($?) {Write-Host "Inject Deploy Successfully!"} else {Write-Error "Inject Deploy Failed!"}
Remove-Item -Path ".\mount\injectdeploy.bat" -ErrorAction SilentlyContinue 

# add drivers
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\temp -o drivers.iso "$osdrvurl"
if ($?) {Write-Host "Driver Download Successfully!"} else {Write-Error "Driver Download Failed!"}
$isopath = Resolve-Path -Path ".\temp\drivers.iso"
# $isomount = (Mount-DiskImage -ImagePath $isopath -PassThru | Get-Volume).DriveLetter
# Copy-Item -Path "${isomount}:\" -Destination ".\mount\Windows\WinDrive" -Recurse -Force -ErrorAction SilentlyContinue 
# Dismount-DiskImage -ImagePath $isopath 
."C:\Program Files\7-Zip\7z.exe" x -r -y ".\temp\drivers.iso" -o".\mount\Windows\WinDrive"
Remove-Item -Path $isopath -ErrorAction SilentlyContinue 

# add software pack
# .\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\temp -o pack.7z "$server/d/pxy/Xiaoran%20Studio/Onekey/Config/pack64.7z"
# ."C:\Program Files\7-Zip\7z.exe" x -r -y -p123 ".\temp\pack.7z" -o".\mount\Windows\Setup\Set\osc"
# if ($?) {Write-Host "software pack Download Successfully!"} else {Write-Error "software pack Download Failed!"}
# Remove-Item -Path ".\temp\pack.7z" -ErrorAction SilentlyContinue 
# Remove-Item -Path ".\mount\Windows\Setup\Set\osc\搜狗拼音输入法.exe" -ErrorAction SilentlyContinue 
$msedge = (Invoke-RestMethod https://github.com/Bush2021/edge_installer/raw/main/data.json).'msedge-stable-win-x64'
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\mount\Windows\Setup\Set\osc\runtime\Edge -o "$($msedge.文件名)" "$($msedge.下载链接)"
if ($?) {Write-Host "Edge Download Successfully!"} else {Write-Error "Edge Download Failed!"}
.\bin\aria2c.exe --check-certificate=false -s16 -x16 -d .\mount\Windows\Setup\Set\Run -o 安装常用工具.exe "$server/d/pxy/Xiaoran%20Studio/Tools/Tools.exe"
if ($?) {Write-Host "XRSYS-Tools Download Successfully!"} else {Write-Error "XRSYS-Tools Download Failed!"}
"isxrsys" > ".\mount\Windows\Setup\zjsoftonlinexrsys.txt"

# remove preinstalled appx
$preinstalled = Get-AppxProvisionedPackage -Path ".\mount"
foreach ($appName in @(
    'clipchamp.clipchamp',
    'Microsoft.549981C3F5F10',
    'microsoft.microsoftteams',
    'microsoft.skypeapp',
    'microsoft.todos',
    'microsoft.bingnews',
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
    'MicrosoftCorporationII.MicrosoftFamily',
    'MicrosoftTeams'
    'MSTeams'
)) {
    $preinstalled | 
        Where-Object {$_.packagename -like "*$appName*"} | 
            Remove-AppxProvisionedPackage -Path ".\mount" -ErrorAction SilentlyContinue 
}

# disable default wd
Get-WindowsOptionalFeature -Path ".\mount" | Where-Object {$_.FeatureName -like "*Defender*"} | Disable-WindowsOptionalFeature

# write version
"${sysvercn}_${sysdate} 
${sysver}_${sysdate}
" | Out-File -FilePath ".\mount\Windows\Version.txt" -Encoding gbk

# capture system image
Write-Host "Packing $sysfile.wim, please wait..."
New-WindowsImage -ImagePath ".\$sysfile.wim" -CapturePath ".\mount" -Name $sysver -Description $sysvercn

# clean up mount dir
# Dismount-DiskImage -Path ".\mount" -Discard
# I am irresponsible

# convert to esd
.\bin\wimlib\wimlib-imagex.exe export "$sysfile.wim" all "$sysfile.esd" --solid
if ($?) { Write-Host "Convert Successfully!"} else {Write-Error "Convert Failed!"}

# Get file information
$sysfilebyte = (Get-ItemProperty ".\$sysfile.esd").Length
$sysfilesize = [Math]::Round($sysfilebyte / 1024 /1024 /1024, 2)
$sysfilemd5 = Get-FileHash ".\$sysfile.esd" -Algorithm MD5 | Select-Object -ExpandProperty Hash
$sysfilesha256 = Get-FileHash ".\$sysfile.esd" -Algorithm SHA256 | Select-Object -ExpandProperty Hash

"[${sysvercn}_每夜版]
describe=${sysver}
Time=${sysdate}
OSUrl=${server}/d/pxy/Xiaoran%20Studio/System/Nightly/${sysfile}.esd
OSFile=${sysfile}.esd
Icon=${osver}
UEFI=1
Index=1
Bit=${sysfilesize} GB
md5=${sysfilemd5}
" | Out-File -FilePath ".\${sysfile}.OsList.ini" -Encoding gbk

"文件名称：${sysfile}.esd
文件大小：${sysfilesize} GB ($sysfilebyte bytes)
MD5     ：${sysfilemd5}
SHA256  ：${sysfilesha256}
" | Out-File -FilePath ".\${sysfile}.txt" -Encoding utf8

# Publish image
.\bin\rclone.exe copy "$sysfile.esd" "oofutech:/Xiaoran Studio/System/Nightly" --progress
if ($?) {Write-Host "Upload Successfully!"} else {Write-Error "Upload Failed!"}
.\bin\rclone.exe copy "$sysfile.OsList.ini" "oofutech:/Xiaoran Studio/System/Nightly" --progress
.\bin\rclone.exe copy "$sysfile.txt" "oofutech:/Xiaoran Studio/System/Nightly" --progress
