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
$strChannel = "Kanal"

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
    
    # todo
    # get channel info

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
    
    
    # print out the header info
    
    "SSID`t`tSignal`tAuthentication`tEncryption`tRadioType`tChannel"
    "----`t`t------`t--------------`t----------`t---------`t--------"
    "`n"
    
    
    For($i = 0; $i -lt $ssids.count; $i++){
    
        # parse the info and remove all unnecessary whitespaces 
        $ssids[$i] = ($ssids[$i] -split ":")[1].Trim()
        $encryption[$i] = ($encryption[$i] -split ":")[1].Trim()
        $signal[$i] = ($signal[$i] -split ":")[1].Trim()
        $authentication[$i] = ($authentication[$i] -split ":")[1].Trim()
        $radioType[$i] = ($radioType[$i] -split ":")[1].Trim()
        $channel[$i] = ($channel[$i] -split ":")[1].Trim()
        
        # print network info
        $ssids[$i] + "`t" +
        $encryption[$i] + "`t" +
        $signal[$i] + "`t" +
        $authentication[$i] + "`t" +
        $radioType[$i] + "`t" +
        $channel[$i]
        
    }
    
    
    
}