$ips = @()
$connectionResults = @()
$cloudOneUrls = @("workload.us-1.cloudone.trendmicro.com",
    "agents.deepsecurity.trendmicro.com",
    "agent-comm.workload.us-1.cloudone.trendmicro.com",
    "dsmim.deepsecurity.trendmicro.com",
    "relay.deepsecurity.trendmicro.com",
    "xdr-resp-ioc.workload.us-1.cloudone.trendmicro.com",
    "files.trendmicro.com",
    "iaus.activeupdate.trendmicro.com",
    "iaus.trendmicro.com",
    "dsaas1100-en-census.trendmicro.com",
    "ds200-en.fbs25.trendmicro.com",
    "ds200-jp.fbs25.trendmicro.com",
    "dsaas.icrc.trendmicro.com",
    "dsaas-en-f.trx.trendmicro.com",
    "dsaas-en-f.trx.trendmicro.com",
    "deepsecaas11-en.gfrbridge.trendmicro.com",
    "dsaas.url.trendmicro.com",
    "agents.deepsecurity.trendmicro.com",
    "trendmicro.georedirector.akadns.net",
    "activeupdate.trendmicro.com.edgekey.net")

foreach ($i in 1..9) {$cloudOneUrls += "agents-00$i.workload.us-1.cloudone.trendmicro.com"}
foreach ($i in 10..99) {$cloudOneUrls += "agents-0$i.workload.us-1.cloudone.trendmicro.com"} 

foreach ($url in $cloudOneUrls) {try {
    (([System.Net.Dns]::GetHostAddresses($url) |
    where {$_.AddressFamily -eq 'InterNetwork'}).IPAddressToString).ForEach({$ips += [PSCustomObject]@{'Trend Ips'="$_"
                                                                                        URL="$url"}})}
    catch {"$url not found"}}

foreach ($url in $cloudOneUrls) {try {
    $test = tnc $url -Port 443
    $connectionResults += [PSCustomObject]@{'URL'= "$url" 
                                            'Port'= $test.RemotePort
                                            'Succeeded'= $test.TcpTestSucceeded}
    }
    catch {"connection to $url unsuccessful."}
    }


$ips | Format-Table
"`n`n"
$connectionResults | Format-Table 
