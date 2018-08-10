#Disable depreciation warnings for the session
Set-PowerCLIConfiguration -Scope Session -DisplayDeprecationWarnings $false -Confirm: $false

#Check status of vROPs server and connect if Disconnected
if($global:DefaultOMServers.Name){
    Write-Host Connected to $global:DefautOMservers.Name
    }else{
    Connect-OMServer -server (Read-Host "Enter your vROPs server name") -Authsource (Read-host "Enter your vRealize Authorization Source")}
#Check status of vCenter server and connect if disconnected
if($global:DefaultVIServer.IsConnected){
    Write-Host Connected to $global:DefaultVIServer.Name
    }else{
    Connect-VIServer (Read-Host "Enter vCenter Server")}
CLS
 Write-Host Connected to $global:DefaultOMservers.Name
 Write-Host Connected to $global:DefaultVIServer.Name

$TroubleVM=(Read-Host "Which VM are you concerned about?")

get-vm $TroubleVM |Format-Table name, Powerstate, @{N="IPAddress"; E={$_.Guest.IPAddress[0,1,2]}}, @{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}},NumCPU,MemoryGB

Write-host Hard drive capacity and free space
get-wmiobject -Query "select * from win32_logicaldisk where DriveType=3" -ComputerName $TroubleVM |Select-Object DeviceID,Size,FreeSpace | ForEach-Object {write-host $_.PSComputerName,$_.DeviceID,Size:([math]::truncate($_.Size/1GB)),Free:([math]::truncate($_.FreeSpace/1GB))}

Write-host Average usage stats over the past day
Get-OMResource $TroubleVM| Get-OMStat -key 'mem|usage_average','cpu|usage_average','cpu|readyPct','cpu|costoppct' -From ([DateTime]::Now).AddDays(-1) -RollupType Avg -IntervalType Days -IntervalCount 1|Sort-Object Key|Format-table Key,@{N="Value in %"; E={[math]::Truncate($_.value)}}

Write-host Average usages stats over the past 14 days
Get-OMResource $TroubleVM| Get-OMStat -key 'mem|usage_average','cpu|usage_average','cpu|readyPct','cpu|costoppct' -From ([DateTime]::Now).AddDays(-14) -RollupType Avg -IntervalType Days -IntervalCount 15|Sort-Object Key|Format-table Key,@{N="Value in %"; E={[math]::Truncate($_.value)}}

Write-host Sizing Recommendations Stress=%
Get-OMResource $TroubleVM| Get-OMStat -key 'cpu|stress','cpu|numbertoadd','mem|stress','mem|underusedpercent','mem|waste'  -From ([DateTime]::Now).AddDays(-14) -RollupType Avg -IntervalType Days -IntervalCount 15|Sort-object Key|Format-table Key,Value


Write-host Most Recent vCenter Events for $TroubleVM
Get-VM $TroubleVM| Get-VIEvent -MaxSamples 5 | Format-Table UserName, CreatedTime, FullFormattedMessage

if((Read-host "Would you like to check System event logs for errors? Could take 5 minutes yes/no") -like 'yes'){
    Write-host Last 5 System Event Log Errors
Get-Eventlog -LogName System -computer $TroubleVM -EntryType Error -Newest 5 | Format-Table TimeGenerated, Source, Message
}else{
    Write-host "Skipping System Event Logs"}

if((Read-host "Would you like to check Application event logs for errors? Could take 5 minutes yes/no") -like 'yes'){
    Write-host Last 5 Application Event Log Errors
Get-Eventlog -LogName Application -computer $TroubleVM -EntryType Error -Newest 5 | Format-Table TimeGenerated, Source, Message
}else{
    Write-host "Skipping Application Event Logs"}