Get-VM -Name "<name>" | ForEach-Object {
  # Get VM by ID
  $vm = Get-View $_.Id

  Write-Output "For $($vm.Name):"

  # Get current VM ExtraConfig
  $vmExtraConfig = $vm.Config.ExtraConfig

  # Constant values for Mac config
  $macConfig_Constants = @{
    "board-id" = "Mac-551B86E5744E2388";
    "hw.model.reflectHost" = "False";
    "hw.model" = "MacBookPro14,3";
    "serialNumber.reflectHost" = "False";
    "smbios.reflectHost" = "False";
    "efi.nvram.var.ROM.reflectHost" = "False";
    "efi.nvram.var.MLB.reflectHost" = "False";
    "efi.nvram.var.ROM" = "3c0754a2f9be";
    "system-id.enable" = "True";
  }

  # Generated values for Mac config
  $macConfig_Generated = @{
    "serialNumber" = "C02" + [string](Get-Random -Minimum 100000 -Maximum 1000000) + "153";
    "bios.uuid" = [string]([guid]::NewGuid() -replace '-','' -split '(.{2})' -ne '' -join ' ' -replace '(^.{20}).*(.{26}$)','$1-$2');
  }

  # Array of Mac config properties to append
  $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

  # Loop through all constant Mac config properties
  foreach ($macConfigProperty in $macConfig_Constants.GetEnumerator()) {
    $vmConfigProperty = $vmExtraConfig | Where-Object { $_.Key -eq $macConfigProperty.Key }

    if ($vmConfigProperty) {
      Write-Output "$($macConfigProperty.Key) exists! Value: $($vmConfigProperty.Value)"
    } else {
      $vmConfigSpec.ExtraConfig += New-Object VMware.Vim.OptionValue -Property @{ Key = $macConfigProperty.Key; Value = $macConfigProperty.Value }
      Write-Output "$($macConfigProperty.Key) added!"
    }
  }

  # Loop through all generated Mac config properties
  foreach ($macConfigProperty in $macConfig_Generated.GetEnumerator()) {
    $vmConfigSpec.ExtraConfig += New-Object VMware.Vim.OptionValue -Property @{ Key = $macConfigProperty.Key; Value = $macConfigProperty.Value }
    Write-Output "$($macConfigProperty.Key) added!"
  }
  
  Write-Output $vmConfigSpec.ExtraConfig

  $vm.ReconfigVM($vmConfigSpec)
}