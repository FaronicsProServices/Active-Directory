# Variables - Update these before deployment
$DomainName = "contoso.local"
$OUPath = "OU=DeepFreezeCloud,DC=contoso,DC=local"
$DomainUser = "CONTOSO\user1"
$DomainPassword = "Partners@2024"

# Convert password to secure string
$SecurePassword = ConvertTo-SecureString $DomainPassword -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential ($DomainUser, $SecurePassword)

# Check if already domain joined
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
