# Variables
$DomainName = "yourdomain.local"
$OUPath = "OU=YourOU,DC=yourdomain,DC=local"
$DomainUser = "YOURDOMAIN\domainuser"  # Update with your domain join account or domain admin account"
$DomainPassword = "Password"  # Update with your domain join account password
$DomainDNS = "12.0.1.11"  # Your domain controller or internal DNS IP

# Set DNS Server first
$Interface = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceAlias $Interface.Name -ServerAddresses ($DomainDNS)

# Convert password and join domain
$SecurePassword = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($DomainUser, $SecurePassword)

# Check domain join status
$ComputerSystem = Get-WmiObject Win32_ComputerSystem
if ($ComputerSystem.PartOfDomain -eq $false) {
    try {
        Add-Computer -DomainName $DomainName -OUPath $OUPath -Credential $Credential -Force -ErrorAction Stop
        Write-Output "Successfully joined $env:COMPUTERNAME to $DomainName under $OUPath."
        Restart-Computer -Force
    } catch {
        Write-Output "Error joining domain: $_"
    }
} else {
    Write-Output "$env:COMPUTERNAME is already joined to a domain."
}
