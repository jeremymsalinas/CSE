$SelfProtectionPath = "HKLM:Software\TrendMicro\Deep Security Agent"
$DSA

# Check system architecture and find uninstall command
if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
    $DSA = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -eq "Trend Micro Deep Security Agent"}
} else {
    $DSA = Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object {$_.DisplayName -eq "Trend Micro Deep Security Agent"}
}

# Check if computer is booted into safe mode and start msi service
if((Get-WmiObject win32_computersystem | Select-Object -ExpandProperty BootupState) -like "Fail-safe*"){
    Write-Warning "Safe Mode Detected! Adding Installer service..."
    REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" /VE /T REG_SZ /F /D "Service"
    REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer" /VE /T REG_SZ /F /D "Service"
    net start msiserver
    }

# Check if Self Protection is enabled and disable it
if ((Get-ItemProperty $SelfProtectionPath)."Self Protect" -eq 1){
    Set-ItemProperty -Path $SelfProtectionPath -Name "Self Protect" -Value 0
    Write-Warning "Self Protection Enabled. Disabling before agent removal."
}

$DSAProcess = Get-Process -Name dsa -ErrorAction SilentlyContinue

# Check if ds_agent is running and stop it
if ($DSAProcess){
    $DSAProcess | Stop-Process -Force
}

$uninstall = $DSA.UninstallString.Split(" ")

# Uninstall DSA
if ($DSA){
    Write-Warning "DS Agent found! Starting uninstall."
    Start-Process $uninstall[0] -ArgumentList $uninstall[1],"/qn" -PassThru -Wait
    Write-Warning "Deep Security Agent uninstalled. Please reboot your machine."
} else {
    Write-Warning "Deep Security Agent not detected!"
    exit
    }

$MSI = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer" -ErrorAction SilentlyContinue

# Clean-up registry keys created for msi service
if ($MSI){
    REG DELETE "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer"
    REG DELETE "HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer"
    Write-Warning "Rebooting Machine in 5 seconds..."
    Start-Sleep 5
    Restart-Computer
}

