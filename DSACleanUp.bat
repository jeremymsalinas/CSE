@setlocal enableextensions enabledelayedexpansion
@echo off

SET DT=%date:~4,2%%date:~7,2%%date:~12,2%%time:~0,2%%time:~3,2%%time:~6,2%
:: Get GUID
FOR /F "tokens=* USEBACKQ" %%F IN (`reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall /s /f "Trend Micro Deep Security Agent" ^| findstr {*}`) DO (SET GUID=%%F)
SET GUID=%GUID:~72,-1%

:: Get Product ID
FOR /F "tokens=* USEBACKQ" %%F IN (`reg query HKLM\SOFTWARE\Classes\Installer\Products /s /f "Trend Micro Deep Security Agent" ^| findstr Products\`) DO (SET ProdID=%%F)
reg delete %ProdID% /F

:: Variables
Set Services=ds_agent ds_notifier ds_monitor amsp tbimdsa tmactmon tmevtmgr tmcomm tmumh tmebc ds_nuagent tbimdsa tmeyes
Set Processes=ds_agent dsa notifier coreframeworkhost coreserviceshell AMSP_LogServer dsc
Set GUIDRegistryKeys=HKLM\SOFTWARE\Classes\Installer\Features\%GUID% HKLM\SOFTWARE\Classes\Installer\Products\%GUID% ^
HKLM\SOFTWARE\Classes\Installer\UpgradeCodes\%GUID% HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\%GUID% ^
HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{%GUID%}

Set RegistryKeys=HKLM\SYSTEM\CurrentControlSet\Services\ds_agent HKLM\SYSTEM\CurrentControlSet\Services\Amsp ^
HKLM\SYSTEM\CurrentControlSet\Services\ds_notifier HKLM\SYSTEM\CurrentControlSet\Services\ds_monitor ^
HKLM\SYSTEM\CurrentControlSet\Services\tmactmon HKLM\SYSTEM\CurrentControlSet\Services\tmcomm ^
HKLM\SYSTEM\CurrentControlSet\Services\tmevtmgr HKLM\SYSTEM\CurrentControlSet\Services\tbimdsa ^
HKLM\SYSTEM\CurrentControlSet\Services\tmeyes HKLM\SYSTEM\CurrentControlSet\Services\tmumh ^
"HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application\Deep Security Agent" HKLM\Software\TrendMicro\WL "HKLM\SYSTEM\CurrentControlSet\Services\EventLog\Application\Deep Security Relay" HKLM\SYSTEM\CurrentControlSet\Services\Eventlog\System\tbimdsa\ "HKLM\Software\TrendMicro\Deep Security Agent" HKLM\Software\TrendMicro\AMSP HKLM\Software\TrendMicro\AEGIS HKLM\Software\TrendMicro\AMSPStatus

Set x86Registry=HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308\ ^
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\689D08D76B5A47A4FB59D97D2C4B9308\ ^
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48\ ^
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\9595A43D099883B49B6A1D3194B54E48\ ^
HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\UpgradeCodes\FD7DF71DF377E464F8F59FDA68339BD0\ ^
HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UpgradeCodes\FD7DF71DF377E464F8F59FDA68339BD0\

Set Directories = "C:\Program Files\Trend Micro\Deep Security Agent" "C:\Program Files\Trend Micro\AMSP" C:\WINDOWS\System32\Drivers\tmebc.sys ^
C:\WINDOWS\System32\Drivers\TMEBC64.sys C:\WINDOWS\System32\Drivers\tmactmon.sys C:\WINDOWS\System32\Drivers\tmcomm.sys ^
C:\WINDOWS\System32\Drivers\tmevtmgr.sys C:\WINDOWS\System32\Drivers\tbimdsa.sys C:\WINDOWS\System32\Drivers\tmeyes.sys ^
C:\WINDOWS\System32\Drivers\tmumh.sys


:: Installed OS
Set os_arch=64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set os_arch=32
  )
Echo Operating System is %os_arch% bit

:: Stop Services
taskkill /f /im notifier.exe
timeout /t 10 /nobreak
for %%a in (%Services%) DO (sc stop %%a)
for %%a in (%Services%) DO (sc delete %%a)

:: Delete Registry Keys
reg export HKLM C:\%DT%HKLMBackup.Reg /y
for %%a in (%GUIDRegistryKeys%) DO (reg delete %%a /F)
for %%a in (%RegistryKeys%) DO (reg delete %%a /F)
for %%a in (%x86Registry%) DO (reg delete %%a /F)

:: Remove Directories and Files
for %%a in (%Directories%) DO (del /s /q %%a)
del /s /q "C:\Program Files\Trend Micro\Deep Security Agent"
