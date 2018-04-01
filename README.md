# BIL524 - Project

A Powershell script to show wireless networks info

## Info to show:
* If connected to a network, show info about network such as 
	 - SSID
	 - Signal
	 - Authentication type
	 - Cipher
	 - Physical address
	 - Channel
	 - IP address 
	 - Default Gateway
	 - and the password(key) of the connected SSID.
* If not connected to a network, show the available networks around along with the information including
	- SSID
	- Cipher
	- Signal
	- Authentication type
	- Radio type
	- Channel
	

## USAGE
Clone the repository and on the Powershell console simply run the command below. The lang option has to be set accordingly to your OS's language.
Turkish and English are the only supported languages.
```
./showWirelessInfo.ps1 -lang tr
```

## Help
To show the help, use the command below.
```
./showWirelessInfo.ps1 -help
```

## Screenshot

A sample screenshot of the script.

![alt text](https://github.com/cemalkilic/bil524project/blob/master/screenshots/sample_usage.jpg)