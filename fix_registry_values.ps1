# # Define the registry path and value name

# Problem: "Your network doesn't meet the requirements"
# Solution: Turn off "Windows Defender" completely, try different VPN

# To run with Full admin & no restrictions:
# powershell -ExecutionPolicy Bypass -File "C:\Users\john\Downloads\vm_obfuscator.ps1"

# $valueName = "HardwareID"                # Replace with the actual value name

# $webcamPath = ""
# $webcamValueName = "FriendlyName"

# Define the boolean variable
$isVBox = $false  # Change this to $false to test the alternative value

# Define the values based on the condition
$hardwareConfigUUID = if ($isVBox) { "eca91fed-d3c1-486b-97b9-86697965b5bf" } else { "05e00838-9ec1-4485-9642-d488dd267810" }

# Define list of registry key paths
$registryPaths = @(
    # ~Disk name
    "HKLM:\SYSTEM\ControlSet001\Enum\SCSI\Disk&Ven_VBOX&Prod_HARDDISK\4&2617aeae&0&000000",
    #webcam
    "HKLM:\SYSTEM\ControlSet001\Enum\USB\VID_80EE&PID_0030&MI_00\6&24953ea&0&0000"
    #webcam 2
    "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses\{65e8773d-8f56-11d0-a3b9-00a0c9223196}\##?#USB#VID_80EE&PID_0030&MI_00#6&24953ea&0&0000#{65e8773d-8f56-11d0-a3b9-00a0c9223196}\#GLOBAL\Device Parameters",
    #webcam 3
    "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses\{65e8773e-8f56-11d0-a3b9-00a0c9223196}\##?#USB#VID_80EE&PID_0030&MI_00#6&24953ea&0&0000#{65e8773e-8f56-11d0-a3b9-00a0c9223196}\#GLOBAL\Device Parameters"

    #webcam 4
    "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses\{6994ad05-93ef-11d0-a3cc-00a0c9223196}\##?#USB#VID_80EE&PID_0030&MI_00#6&24953ea&0&0000#{6994ad05-93ef-11d0-a3cc-00a0c9223196}\#GLOBAL\Device Parameters",

    #webcam 5
    "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses\{cc7bfb41-f175-11d1-a392-00e0291f3959}\##?#USB#VID_80EE&PID_0030&MI_00#6&24953ea&0&0000#{cc7bfb41-f175-11d1-a392-00e0291f3959}\#GLOBAL\Device Parameters"

    # webcam6
    "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceClasses\{e5323777-f976-4f5b-9b55-b94699c46e44}\##?#USB#VID_80EE&PID_0030&MI_00#6&24953ea&0&0000#{e5323777-f976-4f5b-9b55-b94699c46e44}\#GLOBAL\Device Parameters"
) + `
# append identitcal registry keys for BIOS info to this list
(@("HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation") * 3) + `

# append identitcal Reg keys for other BIOS info
(@("HKLM:\SYSTEM\HardwareConfig\{$hardwareConfigUUID}") * 2)

# Parallels ACPI 

# ComputerIds path
$computerIdsPath = "HKLM:\SYSTEM\HardwareConfig\{$hardwareConfigUUID}\ComputerIds"

$computerIds = (Get-ItemProperty -Path $computerIdsPath | Select-Object * -ExcludeProperty PS*).PSObject.Properties.Name

# "ComputerIds" reg key
$registryPaths += (@($computerIdsPath) * $computerIds.Count)

# TODO populate these dynamically by just getting the list of keys from the corresponding parent reg path
# $vboxComputerIds = 
# )

# Define list of registry Values
$valueNames = @(
    "HardwareID",
    "FriendlyName",
    "FriendlyName",
    "FriendlyName",
    "FriendlyName",
    "FriendlyName",
    "FriendlyName",

    # BIOS info
    "BIOSVersion",
    "SystemManufacturer",
    "SystemProductName",

    # BIOS info 2
    "BIOSVersion",
    "SystemBiosVersion"

    # ComputerIds, computed dynamically 
) + $computerIds

Write-Host ""
Write-Host "registryPaths.Count = $($registryPaths.Count)"
Write-Host "valueNames.Count    = $($valueNames.Count)"
Write-Host ""

# Loop through lists & fix registry values
for ($i = 0; $i -lt $registryPaths.Count; $i++) {

    try {
        # Check if the registry key exists
        if (Test-Path $registryPaths[$i]) {
            # Get the existing REG_MULTI_SZ value
            $existingValue = Get-ItemProperty -Path $registryPaths[$i] -Name $valueNames[$i] | Select-Object -ExpandProperty $valueNames[$i]

            if ($existingValue) {
                # Display the original value
                Write-Host "Original Value:" -ForegroundColor Yellow
                $existingValue | ForEach-Object { Write-Host $_ }

                # Replace "VBOX"/"VirtualBox" with "XBOX" in each string
                $modifiedValue = $existingValue | ForEach-Object { $_ -replace "VBOX", "Microsoft" }
                $modifiedValue = $modifiedValue | ForEach-Object { $_ -replace "VirtualBox", "Microsoft" }

                $modifiedValue = $modifiedValue | ForEach-Object { $_ -replace "Parallel", "Microsoft" }
                $modifiedValue = $modifiedValue | ForEach-Object { $_ -replace "prl", "msft" }

                # Replace "innotek.." with Microsoft
                # $modifiedValue = $modifiedValue | ForEach-Object { $_ -replace "innotek GmbH", "Microsoft" }
                # $modifiedValue = $modifiedValue | ForEach-Object { $_ -replace "International GmbH", "Microsoft" }

                # Display the modified value
                Write-Host "Modified Value:" -ForegroundColor Green
                $modifiedValue | ForEach-Object { Write-Host $_ }

                # Write the modified value back to the registry
                Set-ItemProperty -Path $registryPaths[$i] -Name $valueNames[$i] -Value $modifiedValue

                Write-Host "`"$($registryPaths[$i])`": Registry value updated successfully!" -ForegroundColor Cyan
            } else {
                Write-Host "`"$($registryPaths[$i])`": Registry value is empty or not found!" -ForegroundColor Red
            }
        } else {
            Write-Host "`"$($registryPaths[$i])`": Registry path does not exist!" -ForegroundColor Red
        }
    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
}

# Etherenet adapter fix
$ethernetDeviceRegPath = "HKLM:\SYSTEM\ControlSet001\Control\Network\{4D36E972-E325-11CE-BFC1-08002BE10318}\Descriptions"
Rename-ItemProperty -Path $ethernetDeviceRegPath -Name "Parallels VirtIO Ethernet Adapter" -NewName "Microsoft VirtIO Ethernet Adapter"
# Set-ItemProperty -Path $ethernetDeviceRegPath -Name $valueNames[$i] -Value $modifiedValue

# Parallels ACPI devices to fix
# HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\ACPI\PRL4000
# HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\ACPI\PRL4005
# HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\ACPI\PRL4006
# HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\ACPI\PRL4010
# accessCode=539-691-760 locale=en-US clickNum=507970322203904

# # Parallels Reg Keys to fix
# "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\SWD\COMPUTER\MFG_Parallels_International_GmbH.&FAM_Parallels_VM&PROD_Parallels_ARM_Virtual_Machine&SKU_Parallels_ARM_VM"

# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\eb40421b-7b88-4ed1-8aa1-2f71d8b6a801"
# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Environments\Windows ARM64\Drivers\Version-3\Parallels Shared Printer"
# # + "Manufacturer" + "Provider"

# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing\DeviceAttributes"

# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SystemInformation"

#"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\PCI\VEN_1AF4&DEV_1000&SUBSYS_00011AB8&REV_00\3&3259bad1&0&28":
#FriendlyName

# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\ROOT\SENSOR\0001 : DeviceDesc, Mfg

# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Parallels Coherence Service : DisplayName
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Parallels Tools Service : DisplayName
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\netkvm : DisplayName
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Parallels Coherence Service,  To

# oem10.inf - `prl_tg = "Microsoft Tool Device"`
# oem15.inf - `prl_mouf = "Microsoft Mouse Synchronization Device"`, `prl_umouf = "Microsoft USB Mouse Synchronization Device"`
# oem16.inf - `prl_dd = "Microsoft Display Adapter (WDDM)"`
# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\prl_fs ?


# HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\prl_strg ? DisplayName?

