@chcp 936 >nul
@echo off
setlocal enabledelayedexpansion
color a
title 潇然系统部署手动离线接管程序 - V2025.11.2.0
cd /d "%~dp0"
set silent=0

@REM 检测静默参数
if /i "%1"=="/S" (
    set silent=1
    @echo on
)

@REM 创建文件夹
for %%a in (
    Windows\Setup\Set\InDeploy
    Windows\Setup\Set\osc
    Windows\Setup\Set\Run
    Windows\Setup\Run\1
    Windows\Setup\Run\2
) do (
    mkdir "%%a" 2>nul
)

@REM 处理文件
if exist "unattend.xml" move /y "unattend.xml" "Windows\Panther\unattend.xml"
if exist "osc.exe" move /y "osc.exe" "Windows\Setup\Set\osc.exe"
if exist "MSVCRedist.AIO.exe" (
    mkdir "Windows\Setup\Set\osc\runtime" 2>nul
    move /y "MSVCRedist.AIO.exe" "Windows\Setup\Set\osc\runtime\MSVCRedist.AIO.exe"
)

@REM 判断文件完整性
if not exist "Windows\System32\config\SYSTEM" call :error "找不到系统注册表文件"
if not exist "Windows\Panther\unattend.xml" call :error "找不到unattend.xml文件"
if not exist "Windows\Setup\Set\osc.exe" call :error "找不到osc.exe文件"
find /i "IMAGE_STATE_COMPLETE" "Windows\Setup\State\State.ini" && call :error "不支持接管已经部署/未封装的映像"
goto main

:main
cls
echo.
echo 提示：即将接管系统部署，注入系统部署
echo.
echo 注意：1. 仅支持接管Win8.1x64、Win10x64、Win11x64系统；
echo 　　　2. 您的执行环境如果不带choice.exe，将无法完成后续配置；
echo 　　　3. 建议在PE环境或TrustedInstaller用户下运行此脚本
echo.
echo 信息：
if exist "Windows\Es4.Deploy.exe" echo 　　　该映像使用了IT天空ES4封装
if exist "Sysprep\ES5\EsDeploy.exe" echo 　　　该映像使用了IT天空ES5封装
if exist "Sysprep\ES5S\ES5S.exe" echo 　　　该映像使用了IT天空ES5S封装
if exist "Windows\ScData\ScData.sc" echo 　　　该映像使用了系统总裁SCPT3.0封装
echo.
echo 警告：此操作不可逆，请三思而后行！
echo.
if %silent% EQU 0 pause
goto inject

:inject
if not exist "Windows\Panther\unattend2.xml" copy /y "Windows\Panther\unattend.xml" "Windows\Panther\unattend2.xml"

echo 修改系统注册表
REG LOAD "HKLM\Mount_SYSTEM" "Windows\System32\config\SYSTEM"
echo 接管系统部署
REG ADD "HKLM\Mount_SYSTEM\Setup" /f /v "CmdLine" /t REG_SZ /d "deploy.exe" 
echo 干废WD服务
for %%a in (
MsSecFlt
Sense
WdBoot
WdFilter
WdNisDrv
WdNisSvc
WinDefend
SgrmAgent
SgrmBroker
webthreatdefsvc
webthreatdefsvc
) do REG ADD "HKLM\Mount_SYSTEM\ControlSet001\Services\%%a" /f /v "Start" /t REG_DWORD /d 4
echo 跳过系统配置检测
for %%a in (
BypassCPUCheck
BypassRAMCheck
BypassSecureBootCheck
BypassStorageCheck
BypassTPMCheck
) do REG ADD "HKLM\Mount_SYSTEM\Setup\LabConfig" /f /v "%%a" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SYSTEM\Setup\MoSetup" /f /v "AllowUpgradesWithUnsupportedTPMOrCPU" /t REG_DWORD /d 1
echo 禁用BitLocker自动加密
REG ADD "HKLM\Mount_SYSTEM\ControlSet001\BitLocker" /f /v "PreventDeviceEncryption" /t REG_DWORD /d 1
REG UNLOAD "HKLM\Mount_SYSTEM"

echo 修改软件注册表
REG LOAD "HKLM\Mount_SOFTWARE" "Windows\System32\config\SOFTWARE"
echo 干废WD组策略
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "DisableAntiSpyware" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "DisableAntiVirus" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender" /f /v "AllowFastServiceStartup" /t REG_DWORD /d 0
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableIOAVProtection" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableOnAccessProtection" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1
echo 干废WD设置
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender" /f /v "DisableAntiSpyware" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender" /f /v "DisableAntiVirus" /t REG_DWORD /d 1
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Features" /f /v "TamperProtection" /t REG_DWORD /d 4
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Features" /f /v "TamperProtectionSource" /t REG_DWORD /d 2
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Spynet" /f /v "SpyNetReporting" /t REG_DWORD /d 0
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows Defender\Spynet" /f /v "SubmitSamplesConsent" /t REG_DWORD /d 0
echo 禁用保留存储的空间占用
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "MiscPolicyInfo" /t REG_DWORD /d "2" /f
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "PassedPolicy" /t REG_DWORD /d "0" /f
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager" /v "ShippedWithReserves" /t REG_DWORD /d "0" /f
echo 处理OOBE
REG ADD "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /t REG_DWORD /d "1" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe" /v "DevHomeUpdate" /f
@REM REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\EdgeUpdate" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\CrossDeviceUpdate" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\DevHomeUpdate" /f
@REM REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\EdgeUpdate" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\OutlookUpdate" /f
REG DELETE "HKLM\Mount_SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator\UScheduler\CrossDeviceUpdate" /f

REG UNLOAD "HKLM\Mount_SOFTWARE"



echo 修改默认用户注册表
REG LOAD "HKLM\Mount_Default" "Users\Default\NTUSER.DAT"
echo 跳过系统配置检测
for %%a in (SV1,SV2) do REG ADD "HKLM\Mount_Default\Control Panel\UnsupportedHardwareNotificationCache" /f /v "%%a" /t REG_DWORD /d 0
echo 禁用 OneDriveSetup自动启动
REG DELETE "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f /v "OneDriveSetup"
echo 屏蔽“同意个人数据跨境传输”
REG ADD "HKLM\Mount_Default\Software\Microsoft\Windows\CurrentVersion\CloudExperienceHost\Intent\PersonalDataExport" /f /v "PDEShown" /t REG_DWORD /d 2
echo 禁用 Windows 全新安装后擅自安装三方 App
for %%a in (
ContentDeliveryAllowed
DesktopSpotlightOemEnabled
FeatureManagementEnabled
OemPreInstalledAppsEnabled
PreInstalledAppsEnabled
PreInstalledAppsEverEnabled
RemediationRequired
SilentInstalledAppsEnabled
SlideshowEnabled
SoftLandingEnabled
SystemPaneSuggestionsEnabled
SubscribedContentEnabled
) do REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "%%a" /t REG_DWORD /d "0" /f
echo 禁用 Windows 在各处无用的建议提示
for %%a in (
310093Enabled
338388Enabled
338389Enabled
338393Enabled
353694Enabled
353696Enabled
) do REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-%%a" /t REG_DWORD /d "0" /f
echo 禁用游戏栏 Game Bar
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f
echo 隐藏任务栏小组件
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d "0" /f
echo 隐藏任务栏聊天
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d "0" /f
echo 任务栏显示搜索图标
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "1" /f
echo 任务栏禁用资讯和兴趣
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarOpenOnHover" /t REG_DWORD /d "0" /f
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "IsFeedsAvailable" /t REG_DWORD /d "0" /f
REG ADD "HKLM\Mount_Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" /v "IsEnterpriseDevice" /t REG_DWORD /d "1" /f

REG UNLOAD "HKLM\Mount_Default"
>"Windows\Setup\xrsys.txt" echo isxrsys
if %silent% EQU 0 (
    if /i "%systemdrive%"=="x:" if not exist "%windir%\System32\choice.exe" (
        copy /y "Windows\System32\choice.exe" "%windir%\System32\choice.exe"
        copy /y "Windows\System32\zh-CN\choice.exe.mui" "%windir%\System32\zh-CN\choice.exe.mui"
    )
    choice /? || goto :success
)
goto :success

:ask
cls
echo.
echo # 是否设置为纯净模式？
choice
if %errorlevel% equ 1 (
    del /f /q "Windows\Setup\zjsoftforce.txt" >nul 2>nul
    >"Windows\Setup\zjsoftonlinexrsys.txt" echo 1
)

echo.
echo # 是否设置为Administrator账户登录？（不推荐）
choice
if %errorlevel% equ 1 (
    >"Windows\Setup\xrsysadmin.txt" echo 1
) else (   
    del /f /q "Windows\Setup\xrsysadmin.txt" >nul 2>nul
    echo.
    echo ## 是否设置新建账户的用户名？（默认会自动检测）
    choice
    if !errorlevel! equ 1 (
        echo.
        set /p username=### 请输入用户名：
        >"Windows\Setup\xrsysnewuser.txt" echo !username!
    )
)
goto :success

:success
cls
echo.
echo 恭喜您，系统接管成功，
echo 　　尽情享受潇洒、自然的装机体验吧！
echo.
if %silent% EQU 0 (
    pause
    del %0
)
exit 0

:error
echo.
echo 错误：%~1
echo.
echo 接管错误, 请检查文件是否释放正确！！！
echo.
if %silent% EQU 0 pause
exit 1