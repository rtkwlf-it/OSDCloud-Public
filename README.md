# OSDCloud
OSDCloud is a solution for deploying Windows 10/11 x64 over the internet using the OSD PowerShell Module.  This works by booting to WinPE where the OSDisk is wiped and partitioned.  Once this is complete, the Windows Operating System is downloaded from Microsoft Update (using CuRL), before finally being staged (expanded) on the OSDisk.  Driver Packs from Dell, Lenovo, and HP are downloaded directly from each of the manufacturers where they are installed in WinPE or in the Windows Specialize Phase.  For computers that do not have a Driver Pack, hardware drivers are downloaded from Microsoft Update, so this should work on just about any computer model out there.


# What is Edit-OSDCloudWinPE?
This is the function that is used to edit the WinPE in your OSDCloud Workspace.  The basic design of this function is to edit the Startnet.cmd in WinPE to perform a startup to run OSDCloud. Link to GitHub: [Edit-OSDCloudWinPE.md](https://github.com/OSDeploy/OSD/blob/master/Docs/Edit-OSDCloudWinPE.md)

# What is the startnet.cmd file?

This file first runs when OSDcloud does.

Mount the .iso, then inside the sources folder is boot.wim, open it with 7-zip then  \sources\boot.wim\Windows\System32\startnet.cmd.

 

# Powershell Commands:
```powershell
# Get all OSDCloud Templates that have been created
Get-OSDCloudTemplateNames

# Get Current OSDCloud Template that you are in
Get-OSDCloudTemplate

# Switch between OSDCloud Templates
Set-OSDCloudTemplate -Name 'YOUR-TEMPLATE-NAME'

# Create a named OSDCloud Template
New-OSDCloudTemplate -Name 'ENTERNAMEHERE'

# Add Edits of GUI JSON to iso
Edit-OSDCloudWinPE -PSModuleCopy OSD -StartOSDCloudGUI

# These 3 below edit the startnet.cmd file that lives inside the .iso
# This will run with the settings listed, zti means the gui is hidden

Edit-OSDCloudWinPE -StartOSDCloud "-OSName 'Windows 11 24H2 x64' -OSLanguage en-us -OSEdition Enterprise -OSActivation Retail -zti"

# This will run the .ps1 file that is copied to the scripts folder
Edit-OSDCloudWinPE -StartPSCommand "%systemdrive%\OSDCloud\Config\Scripts\StartNet\OSDCLoudCustomSetting.ps1"

# Add Github URL to run
Edit-OSDCloudWinPE -StartURL "URL goes here to github"

# This is the function that is used to edit the WinPE in your OSDCloud Workspace.
# The basic design of this function is to edit the Startnet.cmd in WinPE to perform a startup to run OSDCloud
Edit-OSDCloudWinPE -StartPSCommand "%systemdrive%\OSDCloud\Config\Scripts\StartNet\OSDCLoudCustomSetting.ps1"

# Spins up new Virtual Machine, documentation: https://www.osdcloud.com/osdcloud/setup/osdcloud-vm/new-osdcloudvm
New-OSDCloudVM

# Will display VM settings
Get-OSDCloudVMDefaults

# This is the function that is used to edit the WinPE in your OSDCloud Workspace.
# The basic design of this function is to edit the Startnet.cmd in WinPE to perform a startup to run OSDCloud
# This file points to the github settings file
Edit-OSDCloudWinPE -StartPSCommand "%systemdrive%\OSDCloud\Config\Scripts\StartNet\OSDCLoudCustomSetting.ps1"
```

# How the Settings work:
Link to Start-OSDCloud script, has all the setting you can choose to set: [Start-OSDCloud.ps1](https://github.com/OSDeploy/OSD/blob/master/Public/Start-OSDCloud.ps1)

Our settings live inside a script: OSDCloudCustomSettings.ps1

This is where any setting needs to be made. The goal is to have this file hosted in GitHub, so when an image happens it reaches out to this file.

More info: [OSDCloud Custom Execution](https://www.osdcloud.com/archive/recycle-bin/guides/custom-osdcloud#execution)

# How to create a bootable USB flash drive
1. Insert a USB flash drive into a running computer.
2. Open a Command Prompt window as an administrator.
3. Type diskpart, and then select ENTER.
4. In the new command line window that opens, determine the USB flash drive number or drive letter by typing list disk, and then select ENTER. The list disk command displays all the disks on the computer. Note the drive number or drive letter of the USB flash drive.
5. At the command prompt, type select disk <X>, where X is the drive number or drive letter of the USB flash drive, and then select ENTER.
6. Type clean, and then select ENTER. This command deletes all data from the USB flash drive.
7. To create a new primary partition on the USB flash drive, type create partition primary, and then select ENTER.
8. To select the partition that you just created, type select partition 1, and then select ENTER.
9. To format the partition, type format fs=ntfs quick, and then select ENTER.
10. Type active, and then select ENTER.
11. Type exit, and then select ENTER.

# How to copy the needed .iso file to the USB
1. Navigate to ISO file
2. You will see OSDCloud.iso
3. Mount the .iso
4. Copy everything from inside to the USB

# How to use the USB
1. Make sure computer is powered off
2. Make sure computer is not plugged into the network
3. Plug in the USB
4. Turn power on, continuously tap F12, this will boot into the Boot Menu
5. Plug network cable into computer
6. You should see the USB as a boot option on the left, select it
7. Let the magic happen!
8. When complete you should see the OOBE login screen

# Resources
[OSDCloud Main Web Site](https://www.osdcloud.com/)

[OSDCloud Github](https://github.com/OSDeploy/OSD/tree/master/Docs)

[Blog OSDCloud zti way](https://www.osdsune.com/home/archive/deployment/osdcloud-zti-way)

[Blog OSDCloud zero touch](https://akosbakos.ch/osdcloud-3-zero-touch-deployment/)

[Blog OSDCloud Deploy](https://4sysops.com/archives/deploy-windows-11-with-osdcloud/)
