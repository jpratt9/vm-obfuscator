Read-Host -Prompt "Press any key to continue:"

# TODO check INF files
$infFolder = "C:\Windows\INF"

$infFiles = @(
    "usbvideo.inf",
    "oem3.inf",
    ""
)

# Function to safely rename a registry key if it exists
function Rename-RegistryKey {
    param (
        [string]$oldKeyPath,
        [string]$newName
    )

    if (Test-Path $oldKeyPath) {
        try {
            Rename-Item -Path $oldKeyPath -NewName $newName -ErrorAction Stop
            Write-Host "Successfully renamed $oldKeyPath to $newName"
        }
        catch {
            Write-Host "Error: Failed to rename $oldKeyPath" -ForegroundColor Red
            Write-Host "Exception message: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Registry key $oldKeyPath not found, skipping..."
    }
}

# Function to safely update a registry key's value if it exists
function Update-RegistryValue {
    param (
        [string]$keyPath,
        [string]$valueName,
        [string]$newValue
    )
    
    if (Test-Path $keyPath) {
        Set-ItemProperty -Path $keyPath -Name $valueName -Value $newValue
        Write-Host "Updated $valueName in $keyPath to $newValue"
    } else {
        Write-Host "Registry key $keyPath not found, skipping..."
    }
}
te
# Define the old and new registry keys for renaming in an array
$hardwarePrefix = "HKLM:\HARDWARE\ACPI"
$disksPrefix = "HKLM:\SYSTEM\ControlSet001\Enum\SCSI"
$oldCDROMKey_VMWare = "CdRom&Ven_NECVMWar&Prod_VMware_SATA_CD01"
$oldCDROMKey_VBox = "CdRom&Ven_VBOX&Prod_CD-ROM"
$oldCDROMKey_Parallels = "CdRom&Ven_&Prod_Virtual_DVD-ROM"

# TODO - finish this for VBox, later Parallels
$oldDiskKey_VMWare = "Disk&Ven_NVMe&Prod_VMware_Virtual_N"
$oldDiskKey_VBox = "Disk&Ven_VBOX&Prod_HARDDISK"

# TODO add sc stop's for Parallels & VirtualBox stuff
sc stop vmtools
sc delete vmtools

$registryRenames = @(

    # These need to be done everytime the system restarts.
    @{ OldKey = "$hardwarePrefix\DSDT\PRLS__"; NewName = "PLLS__" },
    @{ OldKey = "$hardwarePrefix\DSDT\VMWARE"; NewName = "XXWARE" },
    @{ OldKey = "$hardwarePrefix\DSDT\VBOX__"; NewName = "XBOX__" },
    
    @{ OldKey = "$hardwarePrefix\DSDT\PLLS__\PRLS_OEM"; NewName = "PLLS_OEM" },
    @{ OldKey = "$hardwarePrefix\DSDT\XXWARE\VMWVBSA!"; NewName = "XXWVBSA!" },
    @{ OldKey = "$hardwarePrefix\DSDT\XBOX__\VBOXBIOS"; NewName = "XBOXBIOS" },

    @{ OldKey = "$hardwarePrefix\FADT\PRLS__"; NewName = "PLLS__" },
    @{ OldKey = "$hardwarePrefix\FADT\VMWARE"; NewName = "XXWARE" },
    @{ OldKey = "$hardwarePrefix\FADT\VBOX__"; NewName = "XBOX__" },

    @{ OldKey = "$hardwarePrefix\FADT\PLLS__\PRLS_OEM"; NewName = "PLLS_OEM" },
    @{ OldKey = "$hardwarePrefix\FADT\XXWARE\VMWVBSA!"; NewName = "XXWVBSA!" },
    @{ OldKey = "$hardwarePrefix\FADT\XBOX__\VBOXFACP"; NewName = "XBOXFACP" },

    @{ OldKey = "$hardwarePrefix\RSDT\PRLS__"; NewName = "PLLS__" },
    @{ OldKey = "$hardwarePrefix\RSDT\VMWARE"; NewName = "XXWARE" },
    @{ OldKey = "$hardwarePrefix\RSDT\VBOX__"; NewName = "XBOX__" },

    @{ OldKey = "$hardwarePrefix\RSDT\PLLS__\PRLS_OEM"; NewName = "PLLS_OEM" }
    @{ OldKey = "$hardwarePrefix\RSDT\XXWARE\VMWVBSA!"; NewName = "XXWVBSA!" }
    @{ OldKey = "$hardwarePrefix\RSDT\XBOX__\VBOXFACP"; NewName = "XBOXFACP" }

    @{ OldKey = "$hardwarePrefix\SSD1\VBOX__"; NewName = "XBOX__" }
    @{ OldKey = "$hardwarePrefix\SSD1\XBOX__\VBOXCPUT"; NewName = "XBOXCPUT" }

    @{ OldKey = "$hardwarePrefix\SSDT\VMWARE"; NewName = "XXWARE" },
    @{ OldKey = "$hardwarePrefix\SSDT\VBOX__"; NewName = "XBOX__" },

    @{ OldKey = "$hardwarePrefix\SSDT\XXWARE\VMWVBSA!"; NewName = "XXWVBSA!" }
    @{ OldKey = "$hardwarePrefix\SSDT\XBOX__\VBOXTPMT"; NewName = "XBOXTPMT" }
)
Read-Host -Prompt "Press any key to continue:"

# Loop through the array to rename registry keys
foreach ($rename in $registryRenames) {
    Rename-RegistryKey -oldKeyPath $rename.OldKey -newName $rename.NewName
}

# Define the registry paths and values to update
$biosKeyPaths = "HKLM:\HARDWARE\DESCRIPTION\System\BIOS", "HKLM:\SYSTEM\HardwareConfig\Current"

$registryUpdates1 = @(
    @{ValueName = "BaseBoardManufacturer"; NewValue = "Microsoft" },
    @{ValueName = "BaseBoardProduct"; NewValue = "Microsoft ARM Platform" },
    @{ValueName = "BIOSVendor"; NewValue = "Microsoft" },
    @{ValueName = "SystemManufacturer"; NewValue = "Microsoft" },
    @{ValueName = "SystemProductName"; NewValue = "Microsoft ARM Laptop" },
    @{ValueName = "SystemSKU"; NewValue = "MSFT_ARM" }
    @{ValueName = "SystemFamily"; NewValue = "Microsoft Machines" }
)

$computerKeyPrefix = "HKLM:\SYSTEM\ControlSet001\Enum\SWD\COMPUTER"
$computerKey_VMWare = "MFG_VMware__Inc.&FAM_VMware&PROD_VMware20_1&SKU_0000000000000001"
$computerKey_VBox = "MFG_innotek_GmbH&FAM_Virtual_Machine&PROD_VirtualBox"
$computerKey_Parallels = "MFG_Parallels_International_GmbH.&FAM_Parallels_VM&PROD_Parallels_ARM_Virtual_Machine&SKU_Parallels_ARM_VM"

$registryUpdates2 = @(
    
    @{ KeyPath = "$disksPrefix\$oldCDROMKey_VMWare\4&224cbe83&0&010000"; ValueName = "FriendlyName"; NewValue = "Microsoft SATA CD01" }

    @{ KeyPath = "$disksPrefix\$oldCDROMKey_VBox\4&2617aeae&0&010000"; ValueName = "FriendlyName"; NewValue = "Microsoft SATA CD01" }
    @{ KeyPath = "$disksPrefix\$oldCDROMKey_VMWare\4&2617aeae&0&020000"; ValueName = "FriendlyName"; NewValue = "Microsoft SATA CD01" }
    @{ KeyPath = "$disksPrefix\$oldCDROMKey_Parallels\3&4b87e29&0&010000"; ValueName = "FriendlyName"; NewValue = "Microsoft SATA CD01" }
    @{ KeyPath = "$disksPrefix\$oldCDROMKey_Parallels\3&4b87e29&0&020000"; ValueName = "FriendlyName"; NewValue = "Microsoft SATA CD01" }

    @{ KeyPath = "$disksPrefix\$oldDiskKey_VMWare\5&14eaf08e&0&000000"; ValueName = "FriendlyName"; NewValue = "Microsoft NVMe Disk" }
    @{ KeyPath = "$disksPrefix\$oldDiskKey_VBox\4&2617aeae&0&000000"; ValueName = "FriendlyName"; NewValue = "MICROSOFT HARD DISK" }

    # Computer name - under Device manager
    # VMware
    @{ KeyPath = "$computerKeyPrefix\$computerKey_VMWare"; ValueName = "FriendlyName"; NewValue = "Microsoft PC" }
    # VBox
    @{ KeyPath = "$computerKeyPrefix\$computerKey_VBox"; ValueName = "FriendlyName"; NewValue = "Microsoft PC" }
    # Parallels
    @{ KeyPath = "$computerKeyPrefix\$computerKey_Parallels"; ValueName = "FriendlyName"; NewValue = "Microsoft PC" }
)

# Loop through the array to update registry key values
foreach ($keyPath in $biosKeyPaths) {
    foreach ($update in $registryUpdates1) {
        Update-RegistryValue -keyPath $keyPath -valueName $update.ValueName -newValue $update.NewValue
    }
}

foreach ($u in $registryUpdates2) {
    $curr = (Get-ItemProperty -Path $u.KeyPath -Name $u.ValueName -ErrorAction SilentlyContinue).$($u.ValueName)
    if ($curr -eq $u.NewValue) {
        Write-Output "Skipped: $($u.KeyPath)\$($u.ValueName) already '$($u.NewValue)'."
    }
    else {
        Update-RegistryValue -keyPath $u.KeyPath -valueName $u.ValueName -newValue $u.NewValue
        Write-Output "Updated: $($u.KeyPath)\$($u.ValueName): '$curr' -> '$($u.NewValue)'."
    }
}

$vmItems = @{
    Services = Get-Service | Where-Object { $_.Status -eq 'Running' -and $_.DisplayName -match 'virtual|vm|parallel' }
    # Services = Get-Service -Name 'vm*','parallel*','virtual*' | Where-Object { $_.Status -eq 'Running' }
    Processes = Get-Process | Where-Object { $_.Name -like 'vm*' -or $_.Name -like 'parallel*' -or $_.Name -like 'virtualbox*' }
}

foreach ($type in $vmItems.Keys) {
    if ($vmItems[$type]) {
        Write-Output "Terminating $type`: $($vmItems[$type].Name -join ', ')"
        $vmItems[$type] | ForEach-Object { 
            try { 
                if ($type -eq 'Services') { Stop-Service $_.Name -Force -ErrorAction Stop }
                else { Stop-Process $_.Id -Force -ErrorAction Stop }
            } catch { Write-Output "Failed to stop $($type.TrimEnd('s')) $($_.Name): $($Error[0].Exception.Message)" }
        }
    }
}

if (-not ($vmItems.Values | Where-Object { $_ })) { Write-Output "No VM-related items to terminate." }

try {
    Write-Host "Attempting to find any VM-related devices..."
    # Comma-separated, trimmed list 
    $vmwareDevices = (Get-WmiObject -Class Win32_PnPEntity | Select-Object -ExpandProperty Name | findstr -i "vmware vbox parallel").Trim() -join ", "
    Write-Output "WARNING: Found VM-related devices: $vmwareDevices"
} catch {
    Write-Host "No VM-related devices found."
}

# TODO check DiskDrive & fix registry key value if it's VM-related
if ([bool](Get-WmiObject Win32_DiskDrive | Where-Object { ($_.Model, $_.Caption) -match 'vbox*|vm*|parallel*'})) {
    Write-Host "WARNING: Found VM-related Hard Disk! Fixing..."
    # TODO dynamically fix vmware/virtualbox/parallels VM
    $path = "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Enum\SCSI\Disk&Ven_VMware_&Prod_VMware_Virtual_S&22be34f&0&000000"

}
Get-WmiObject -class Win32_DiskDrive | Select-Object -ExpandProperty Model
Get-WmiObject -class Win32_DiskDrive | Select-Object -ExpandProperty Caption

# Check if BIOS is displaying any VirtualBox stuff
# TODO LATER - check for VMware
if ([bool](Get-WmiObject -Class Win32_BIOS | Out-String | findstr /i "virtual innotek vbox parallel")) {
    Write-Host "WARNING: BIOS Data displaying VirtualBox info!"
    Write-Host "INFO: Fixing..."
    mofcomp "hideVM.mof"
}

# Fix HardwareID
Write-Host "The script is located in: $PSScriptRoot"
& "$PSScriptRoot\fix_registry_values.ps1"

# Pause at the end until the user presses Enter
Read-Host -Prompt "Press Enter to exit"
