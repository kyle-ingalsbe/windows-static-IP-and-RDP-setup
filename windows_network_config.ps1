# to be able to run this script, you will need to run this command first: Set-ExecutionPolicy RemoteSigned

$dns1 = "8.8.8.8"
$dns2 = "8.8.4.4"


#first check if the person is admin.
clear-host
write-host "Windows net config script V1.0 build date 9-29-24"
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($identity)

if (!$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
	write-host ""
	write-host ""
	write-host ""
	Write-host "This requires admin privs. Run this / powershell as administrator. Exiting..."
    write-host ""
    write-host ""
    write-host ""
    Exit

}


#DRP doesnt work right without windows update, so run a windows update first.
clear-host

$wu = Read-Host -Prompt "Do Windows update? [y/N] "

if ($wu -eq "y")
{
	Install-Module -Name PSWindowsUpdate -RequiredVersion 2.1.1.2
	Import-Module PSWindowsUpdate
	Get-WindowsUpdate
	Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot
	
	
}


$dne = 0

#grab the ip address
clear-host
while ($dne -eq 0) {


	$ip = Read-Host -Prompt "Enter an IP address"
	 $oip = $ip
	#$ipRegex = [regex]::Compile('\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b')
	
	if ($ip -match "\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b") {
		try {
			$ip = [ipaddress]"$ip"
		}
		catch {
			Write-Host "IP address conversion failed. Exiting..."
			exit
		}
	
		Write-Host "Valid IPaddress $ip"
		$dne = 1
	} Else {
		Write-Host ""
		Write-Host "Invalid IP address..."
		Write-Host ""
	}
	


}
#tmux

	#make the gateway
	$gtwy = $oip.Split('.')
	
	$ipa = $gtwy[0]
	$ipb = $gtwy[1]
	$ipc = $gtwy[2]

	$gtwye = $gtwy[3] -1
	
	$new_gtwy = "$ipa.$ipb.$ipc.$gtwye"
	
	
	$dne = 1
	
	$eth =""


#see how many network adapters there are. if only 1 then just auto grab it and not worry about it.

$adapters = Get-NetAdapter -Physical | Measure-Object | Select-Object -ExpandProperty Count


	Write-Host ""

if ($adapters -eq 1){  $eth = (Get-NetAdapter).InterfaceAlias }
else {
	Write-Host "Choose a network Adapter Nanme to apply the settings to:"
	Get-NetAdapter 
	write-host " "
	$eth =  Read-Host -Prompt "Card Name? "
}

#confiure the network card
Write-Host ""
Write-Host "Configuring the network card."
Write-Host ""


#Get-NetIPAddress -InterfaceAlias $eth | Remove-NetIPAddress -Confirm:$false
#Get-NetIPInterface -InterfaceAlias $eth | Set-NetIPInterface -DHCP Enabled=$false 

# Remove the static ip - doesnt work...
Remove-NetIPAddress -InterfaceAlias $eth -Confirm:$false

# Remove the default gateway 
Remove-NetRoute -InterfaceAlias $eth -Confirm:$false

# remove dns
get-netadapter $eth | Set-DnsClientServerAddress -ResetServerAddresses


#netsh int ip reset
write-host ""
write-host "erasing old config"
write-host ""

#the sleep is needed to allow the network card time to set the settings. otherwise, it will try to reset things and all bad juju happens.
Start-Sleep -Seconds 5

write-host ""
write-host "setting up new config"
write-host ""

New-NetIPAddress -InterfaceAlias $eth -AddressFamily IPv4 -IPAddress $ip -PrefixLength 29 -DefaultGateway $new_gtwy
Set-DnsClientServerAddress -InterfaceAlias $eth -ServerAddresses $dns1,$dns2 -Verbose 


Get-NetAdapterBinding -InterfaceAlias $eth


#set rdp

Write-Host "Configuring RDP. It will reboot afterwards"

Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1



Write-Host ""
Write-Host ""
$wu = Read-Host -Prompt "Setup Complete. Do you wish to reboot now? [y/N] "
Write-Host ""
Write-Host ""

#reset the script execution back to normality
Set-ExecutionPolicy Restricted

Write-Host "Script execution is now disabled. You will need to rerun Set-ExecutionPolicy RemoteSigned to run scripts again"
Write-Host ""
Write-Host ""
if ($wu -eq "y")
{
	Restart-Computer
	
	
}



