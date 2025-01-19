#windows static IP and RDP setup

This script will do multiple things: 

1) try to do a windows update

2) try to enable RDP

3) try to configure the network card you choose with a static IP address that you chose, a gateway, and a DNS


To be able to run this script, you will need to run this command first: Set-ExecutionPolicy RemoteSigned

Then run it inside of powershell. You will need admin privilages to do all of this. 

The Gateway is programmed in to be a constant. With an IP address of XXX.XXX.XXX.BBB, the Gateway will always be XXX.XXX.XXX.(BBB - 1). Meaning that it will always be one less than the final octet. So if the ip address is 192.168.1.2, then the gateway will be 192.168.1.1. 

You can set your DNS servers to be whatever you desire. There are variables at the top of the script called $dns1 and $dns2. Change these to your desired DNS server. 

This is a prompt based script, so follow the prompts and be sure to read all the information.

