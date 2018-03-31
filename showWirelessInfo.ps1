# handle language setting later
$language = "tr"

# for localization
$strSSID = "SSID"
$strBSSID = "BSSID"
$strRadioType = "Radyo Türü"
$strSignal = "Sinyal"
$strAuthentication = "Kimlik Doðrulama"
$strPhyAddress = "Fiziksel Adres"
$strEncryption = "Þifre"

# for turkish, get the wireless network info
$data = netsh interface show interface | findstr /C:"Kablosuz"

$splitData = $data -split '\s+'

# splitData[1] includes info about connection state
if ($splitData[1] -eq "Baðlandý"){
    #get wifi info
    $wifiInfo = netsh wlan show interfaces
    
    # search for SSID, split on the colon, get the second element and trim it.
    $ssidSearch = $wifiInfo | Select-String -Pattern $strSSID
    $tmpSsidSearch = ($ssidSearch -split ":")
    $ssid = $tmpSsidSearch[1].Trim()
    "SSID: " + $ssid
    
    # get bssid info
    $bssid = $tmpSsidSearch[3..$tmpSsidSearch.count] -replace "\n"
    "BSSID: " + $bssid
    
    # get radio type
    $radioTypeSearch = $wifiInfo | Select-String -Pattern $strRadioType
    $radioType = ($radioTypeSearch -split ":")[1].Trim()
    "Radyo türü: " + $radioType
    
    # get signal info
    $signalSearch = $wifiInfo | Select-String -Pattern $strSignal
    $signal = ($signalSearch -split ":")[1].Trim()
    "Sinyal: " + $signal
    
    # get authentication info
    $authenticationSearch = $wifiInfo | Select-String -Pattern $strAuthentication
    $authentication = ($authenticationSearch -split ":")[1].Trim()
    "Kimlik Doðrulama: " + $authentication
    
    # get the encryption type
    $encryptionSearch = $wifiInfo | Select-String -Pattern $strEncryption
    $encryption = ($encryptionSearch -split ":")[1].Trim()
    "Þifreleme: " + $encryption
    
    # get physical address
    $physicalAddrSearch = $wifiInfo | Select-String -Pattern $strPhyAddress
    $tmpPhysicalAddr = $physicalAddrSearch -split ":"
    $physicalAddr = ($tmpPhysicalAddr)[1..$tmpPhysicalAddr.count]
    "Fiziksel Adres: " + $physicalAddr

    # show network info
    # get IP address
    $ipAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {($_.IPEnabled -eq $true) -and ($_.DHCPEnabled -eq $true)} | Select IPAddress).IPAddress[0]
    "IP adresi: " + $ipAddress
    
    $detailedInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*
    #$detailedInfo
    
    # get default gateway info
    $defaultGatewaySearch = $detailedInfo | findstr /C:"DefaultIPGateway"
    # trim and remove the curly braces
    $defaultGateway = ($defaultGatewaySearch -split ":")[1].Trim() -replace "{" -replace "}"
    "Default gateway: " + $defaultGateway
    
} 