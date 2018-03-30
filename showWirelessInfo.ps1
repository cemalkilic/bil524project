# handle language setting later
$language = "tr"

# for turkish, get the wireless network info
$data = netsh interface show interface | findstr /C:"Kablosuz"

$splitData = $data -split '\s+'

# splitData[1] includes info about connection state
if ($splitData[1] -eq "Baðlandý"){
    #get wifi info
    $wifiInfo = netsh wlan show interfaces
    
    # search for SSID, split on the colon, get the second element and trim it.
    $ssidSearch = $wifiInfo | Select-String -Pattern "SSID"
    $ssid = ($ssidSearch -split ":")[1].Trim()
    "SSID: " + $ssid
    
    # get radio type
    $radioTypeSearch = $wifiInfo | Select-String -Pattern "Radyo türü"
    $radioType = ($radioTypeSearch -split ":")[1].Trim()
    "Radyo türü: " + $radioType
    
    # get signal info
    $signalSearch = $wifiInfo | Select-String -Pattern "Sinyal"
    $signal = ($signalSearch -split ":")[1].Trim()
    "Sinyal: " + $signal
    
    # get authentication info
    $authenticationSearch = $wifiInfo | Select-String -Pattern "Kimlik Doðrulama"
    $authentication = ($authenticationSearch -split ":")[1].Trim()
    "Kimlik Doðrulama: " + $authentication
    
    # get physical address
    $physicalAddrSearch = $wifiInfo | Select-String -Pattern "Fiziksel Adres"
    $tmpPhysicalAddr = $physicalAddrSearch -split ":"
    $physicalAddr = ($tmpPhysicalAddr)[1..$tmpPhysicalAddr.count]
    "Fiziksel Adres: " + $physicalAddr
    
    

    # show network info
    $ipAddress = (Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {($_.IPEnabled -eq $true) -and ($_.DHCPEnabled -eq $true)} | Select IPAddress).IPAddress[0]
    
    $detailedInfo = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property [a-z]* -ExcludeProperty IPX*,WINS*

}