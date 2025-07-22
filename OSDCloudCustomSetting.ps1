﻿#Variables to define the Windows OS / Edition etc to be applied during OSDCloud
$Product = (Get-MyComputerProduct)
$Model = (Get-MyComputerModel)
$Manufacturer = (Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer
$OSVersion = 'Windows 11' #Used to Determine Driver Pack
$OSReleaseID = '24H2' #Used to Determine Driver Pack
$OSName = 'Windows 11 24H2 x64'
$OSEdition = 'Enterprise'
$OSActivation = 'Retail'
$OSLanguage = 'en-us'


#Set OSDCloud Vars
$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$True
    WindowsUpdate = [bool]$true
    WindowsUpdateDrivers = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    #SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$False
    ShutdownSetupComplete = [bool]$false
}

#Update local Driver Pack Catalog
Update-DellDriverPackCatalog -UpdateModuleCatalog | Out-Null

#Used to Determine Driver Pack
$DriverPack = Get-OSDCloudDriverPack -Product $Product -OSVersion $OSVersion -OSReleaseID $OSReleaseID

if ($DriverPack){
    $Global:MyOSDCloud.DriverPackName = $DriverPack.Name
}

#write variables to console
Write-Output $Global:MyOSDCloud

#Update Files in Module that have been updated since last PowerShell Gallery Build (Testing Only)
$ModulePath = (Get-ChildItem -Path "$($Env:ProgramFiles)\WindowsPowerShell\Modules\osd" | Where-Object {$_.Attributes -match "Directory"} | select -Last 1).fullname
import-module "$ModulePath\OSD.psd1" -Force

#Launch OSDCloud
Write-Host "Starting OSDCloud" -ForegroundColor Green
write-host "Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSLanguage $OSLanguage -OSActivation $OSActivation"

Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSLanguage $OSLanguage -OSActivation $OSActivation -zti

# Create or modify SetupComplete.ps1 with content at specific location
  $setupCompletePath = "C:\windows\setup\scripts\SetupComplete.ps1"
  $contentToAdd = @'
 Start-Transcript -Path 'C:\OSDCloud\Logs\AWNCustomSetupComplete.log' -ErrorAction Ignore
 $url = 'https://raw.githubusercontent.com/rtkwlf-it/OSDCloud-Public/main/OSDCloudSetupComplete.ps1'; $scriptContent = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content; Invoke-Expression $scriptContent.substring(1)
 Stop-Transcript
'@
 
    #Read all content
     $fileContent = Get-Content -Path $setupCompletePath -Raw
     
      # Check if file contains 'Restart-Computer -Force'
     if ($fileContent -match 'Restart-Computer -Force') {
        # Insert content before Restart-Computer line
        $newContent = $fileContent -replace 'Restart-Computer -Force', "$contentToAdd`r`nRestart-Computer -Force"
        # Write modified content back to file
        Set-Content -Path $setupCompletePath -Value $newContent -Encoding ascii -Force
        Write-Host "Content added before Restart-Computer line" -ForegroundColor Green
     } else {
        #Just append to the end if no restart line found
        Add-Content -Path $setupCompletePath -Value $contentToAdd -Encoding ascii -Force
        Write-Host "Content appended to the end of file (no Restart-Computer line found)" -ForegroundColor Yellow
     } 
Write-Host  -ForegroundColor Green "Restarting now!"
wpeutil reboot