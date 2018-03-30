# handle language setting later
$language = "tr"

# for turkish, get the wireless network info
$data = netsh interface show interface | findstr /C:"Kablosuz"

$splitData = $data -split '\s+'

# splitData[1] includes info about connection state
if ($splitData[1] -eq "Baðlandý"){
    # show network info
}

