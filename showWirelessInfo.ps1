# Author : Cemal Kilic <cemalkilic96 [at] gmail.com>
# Last Change : 31-Mar-2018

# Get-WinSystemLocale is not a default cmdlet.
# So this option has to be set manually.
$LANGUAGE = "tr"

if($LANGUAGE -eq "tr"){
    $strSSID = "SSID"
    $strBSSID = "BSSID"
    $strRadioType = "Radyo Türü"
    $strSignal = "Sinyal"
    $strAuthentication = "Kimlik Doðrulama"
    $strPhyAddress = "Fiziksel Adres"
    $strEncryption = "Þifre"
    $strChannel = "Kanal"
    $strIPAddress = "IP Adresi"
    $strDefaultGateway = "Varsayýlan Yönlendirici"
    $strKey = "Anahtar Ýçeriði"
    $strConnected = "Baðlandý"
    $strWireless = "Kablosuz"
    $fileTimeInfoMessage = "Bu rapor þu tarihte oluþturulmuþtur: "
    $fileConnectedInfoMessage = "Baðlý olduðunuz aða ait detaylý bilgiler aþaðýdadýr:"
    $fileNotConnectedInfoMessage = "Herhangi bir aða baðlý deðilsiniz ancak baðlanýlabilecek aðlar aþaðýda listelenmiþtir:"
} ElseIf($LANGUAGE -eq "en"){
    $strSSID = "SSID"
    $strBSSID = "BSSID"
    $strRadioType = "Radio Type"
    $strSignal = "Signal"
    $strAuthentication = "Authentication"
    $strPhyAddress = "Physical Address"
    $strEncryption = "Cipher"
    $strChannel = "Channel"
    $strIPAddress = "IP Address"
    $strDefaultGateway = "Default Gateway"
    $strKey = "Key Content"
    $strConnected = "Connected"
    $strWireless = "Wireless"
    $fileTimeInfoMessage = "This report created on "
    $fileConnectedInfoMessage = "Details about the network you are currently connected as follows: "
    $fileNotConnectedInfoMessage = "You are not connected any network, here is a list of available wlans:"
}

$currentTime = [DateTime]::Now.ToString("yyyyMMdd-HHmmss")
$fileName = "wifi_info_" + $currentTime + ".txt" 


# function to replace whitespaces with colons
# in the main code, i split original string on
# colons, physical addresses need colons
function correctMAC([string]$str){
    $str -replace " ", ":"
}

# function prints the header info to the file
# info includes report creation time, and whether
# computer is connected to a network or not.
function showInfoForFileOut([bool]$connected){
    $time = Get-Date
    $fileTimeInfoMessage + $time
    if($connected -eq 1){
        $fileConnectedInfoMessage
    } Else {
        $fileNotConnectedInfoMessage
    }
}

# function prints info to the command line
function showInfoForCommandLine([bool]$connected){
    if($connected -eq 1){
        if($LANGUAGE -eq "tr"){
            "Baðlý olduðunuz " + $ssid + " aðýna ait detaylar " + $fileName + " dosyasýna yazdýrýlmýþtýr."
        } ElseIf($LANGUAGE -eq "en"){
            "Details about the network " + $ssid + " printed to the file " + $fileName + "."
        }
    } Else {
        if($LANGUAGE -eq "tr"){
            "Herhangi bir aða baðlý deðilsiniz."
            "Baðlanabileceðiniz aðlarýn listesi " + $fileName + " dosyasýna yazdýrýlmýþtýr."
        } ElseIf($LANGUAGE -eq "en"){
            "You are not connected to any network."
            "A list of available wireless networks printed to the file " + $fileName + "."
        }
    }
}

$data = netsh interface show interface | Select-String $strWireless

$splitData = $data -split '\s+'

# splitData[1] includes info about connection state
if ($splitData[1] -eq $strConnected){

    # obj holds info about the current connected network
    $obj = new-object psobject
    
    # get wifi info
    $wifiInfo = netsh wlan show interfaces
    
    # search for SSID, split on the colon, get the second element and trim it.
    $ssidSearch = $wifiInfo | Select-String -Pattern $strSSID
    $tmpSsidSearch = ($ssidSearch -split ":")
    $ssid = $tmpSsidSearch[1].Trim()
    $obj | add-member noteproperty $strSSID ($ssid)
    
    # get bssid info
    $bssid = $tmpSsidSearch[3..$tmpSsidSearch.count] -replace "\n"   
    $bssid = $bssid -replace "^\s" # remove only the first whitespace
    $bssid = correctMAC($bssid)
    $obj | add-member noteproperty $strBSSID ($bssid)
    
    # get radio type
    $radioTypeSearch = $wifiInfo | Select-String -Pattern $strRadioType
    $radioType = ($radioTypeSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strRadioType ($radioType)
    
    # get signal info
    $signalSearch = $wifiInfo | Select-String -Pattern $strSignal
    $signal = ($signalSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strSignal ($signal)
    
    # get authentication info
    $authenticationSearch = $wifiInfo | Select-String -Pattern $strAuthentication
    $authentication = ($authenticationSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strAuthentication ($authentication)
    
    # get the encryption type
    $encryptionSearch = $wifiInfo | Select-String -Pattern $strEncryption
    $encryption = ($encryptionSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strEncryption ($encryption)
    
    # get physical address
    $physicalAddrSearch = $wifiInfo | Select-String -Pattern $strPhyAddress
    $tmpPhysicalAddr = $physicalAddrSearch -split ":"
    $physicalAddr = ($tmpPhysicalAddr)[1..$tmpPhysicalAddr.count]
    $physicalAddr = $physicalAddr -replace "^\s"  # remove only the first whitespace
    $physicalAddr = correctMAC($physicalAddr)
    $obj | add-member noteproperty $strPhyAddress ($physicalAddr)
    
    # get channel info
    $channelSearch = $wifiInfo | Select-String -Pattern $strChannel
    $channel = ($channelSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strChannel ($channel)

    # get IP address
    $ipAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {($_.IPEnabled -eq $true) -and ($_.DHCPEnabled -eq $true)} | Select IPAddress).IPAddress[0]
    $obj | add-member noteproperty $strIPAddress ($ipAddress)
    
    # detailed info contains info about default gateway router
    $detailedInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*   
    # get default gateway info
    $defaultGatewaySearch = $detailedInfo | findstr /C:"DefaultIPGateway" #this is always "DefaultIPGateway", so no need for localizing
    # trim and remove the curly braces
    $defaultGateway = ($defaultGatewaySearch -split ":")[1].Trim() -replace "{" -replace "}"
    $obj | add-member noteproperty $strDefaultGateway ($defaultGateway)
    
    # get the password of the connected wlan
    $pwdSearch = netsh wlan show profiles name = $ssid key = clear | Select-String $strKey
    $pwd = ($pwdSearch -split ":")[1].Trim()
    $obj | add-member noteproperty $strKey ($pwd)
    
    showInfoForFileOut(1) | Out-File $fileName
    showInfoForCommandLine(1)
    
    # when outputting to the file, there is no need 
    # to be formatted as a table.
    # so just output it to a file
    Write-Output $obj | Out-File $fileName -Append
   
    
} Else{
    # show available network SSIDs
    
    # get all the networks info
    $networks = netsh wlan show networks mode=bssid
    
    # get necessary info
    $ssids = $networks | Select-String "^SSID"
    $encryption = $networks | Select-String $strEncryption
    $signal = $networks | Select-String $strSignal
    $authentication = $networks | Select-String $strAuthentication
    $radioType = $networks | Select-String $strRadioType
    $channel = $networks | Select-String $strChannel
    

    # array holds info about every ssid
    $outArray = @()
    
    For($i = 0; $i -lt $ssids.count; $i++){
    
        # parse the info and remove all unnecessary whitespaces 
        $ssids[$i] = ($ssids[$i] -split ":")[1].Trim()
        $encryption[$i] = ($encryption[$i] -split ":")[1].Trim()
        $signal[$i] = ($signal[$i] -split ":")[1].Trim()
        $authentication[$i] = ($authentication[$i] -split ":")[1].Trim()
        $radioType[$i] = ($radioType[$i] -split ":")[1].Trim()
        $channel[$i] = ($channel[$i] -split ":")[1].Trim()
        
        $obj = new-object psobject
        $obj | add-member noteproperty $strSSID ($ssids[$i])
        $obj | add-member noteproperty $strEncryption ($encryption[$i])
        $obj | add-member noteproperty $strSignal ($signal[$i])
        $obj | add-member noteproperty $strAuthentication ($authentication[$i])
        $obj | add-member noteproperty $strRadioType ($radioType[$i])
        $obj | add-member noteproperty $strChannel ($channel[$i])
        #write-output $obj | Format-Table -Property * -AutoSize | Out-String -Width 4096 | Out-File -Append test.txt 
        $outArray += $obj
        
    }
    
    showInfoForFileOut(0) | Out-File $fileName
    
    # when outputting to the file,
    # formatting output as a table makes it easier to read
    $outArray | Format-Table -Property * -AutoSize | Out-String -Width 4096 | Out-File $fileName -Append
    
    showInfoForCommandLine(0)
}