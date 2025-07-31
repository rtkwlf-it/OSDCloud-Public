# Enable location services so the time zone will be set automatically (even when skipping the privacy page in OOBE) when an administrator signs in
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type "String" -Value "Allow" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" -Name "SensorPermissionState" -Type "DWord" -Value 1 -Force
Start-Service -Name "lfsvc" -ErrorAction SilentlyContinue

# Checks Auto Time Zone service status, and sets it to Manual if needed
#region Settings
$ServiceName = 'tzautoupdate'
$Action = 'Manual'
#endregion
#region Functions
Function Manage-Services {
    Param
    (
        [string]$ServiceName,
        [ValidateSet("Start", "Stop", "Restart", "Disable", "Auto", "Manual")]
        [string]$Action
    )

    try {
        Start-Transcript -Path "C:\Windows\Temp\$($ServiceName)_Management.Log" -Force -ErrorAction SilentlyContinue
        Get-Date
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        $service
        if ($service) {
            Switch ($Action) {
                "Start" { Start-Service -Name $ServiceName; Break; }
                "Stop" { Stop-Service -Name $ServiceName; Break; }
                "Restart" { Restart-Service -Name $ServiceName; Break; }
                "Disable" { Set-Service -Name $ServiceName -StartupType Disabled -Status Stopped; Break; }
                "Auto" { Set-Service -Name $ServiceName -StartupType Automatic -Status Running; Break; }
                "Manual" { Set-Service -Name $ServiceName -StartupType Manual -Status Running; Break; }
            }
            Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        }
        Stop-Transcript -ErrorAction SilentlyContinue
    }
    catch {
        throw $_
    }
}
#endregion

#region Process
try {
    Write-Host "Fixing TimeZone service statup type to MANUAL."
    Manage-Services -ServiceName $ServiceName -Action $Action
    Exit 0
}
catch {
    Write-Error $_.Exception.Message
}
#endregion