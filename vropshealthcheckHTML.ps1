#Disable depreciation warnings for the session
Set-PowerCLIConfiguration -Scope Session -DisplayDeprecationWarnings $false -Confirm: $false

#Gather Credentials for Windows VMs
$ADName = read-host "Enter User Account with access to the troubled VM, then enter the password when prompted"

Read-host -assecurestring | convertfrom-securestring | out-file cred.txt

$password = get-content cred.txt | convertto-securestring

$credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $ADName,$password

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

$TroubleVM = (Read-Host "Which VM are you concerned about?")

$basicConfig = get-vm $TroubleVM | ConvertTo-EnhancedHTMLFragment -Properties name, Powerstate, @{N='IP Address';E={$_.ExtensionData.Guest.IPAddress}}, @{N="DNS Name"; E={$_.ExtensionData.Guest.Hostname}}, NumCPU, MemoryGB -As List -PreContent "<h2>Configuration info</h2>"

# Hard drive capacity and free space
$HDDInfo = get-wmiobject -ComputerName $TroubleVM -Credential $credential Win32_LogicalDisk | Where {$_.DriveType -eq 3}|  ConvertTo-EnhancedHTMLFragment -As Table -PreContent "<h2>Hard Drive Information</h2>" -Properties @{N='Drive';E={$_.DeviceID}}, @{N='Size';E={([math]::Round($_.Size/1GB))}},@{N='Free';E={([math]::Round($_.FreeSpace/1GB))}},@{N='FreePct';E={[Math]::Round(((1 - (($_.FreeSpace/1GB)/($_.Size/1GB))) * 100),2)}}

# Average usage stats over the past day
$DayAverage = Get-OMResource $TroubleVM| Get-OMStat -key 'mem|usage_average','cpu|usage_average','cpu|readyPct','cpu|costoppct' -From ([DateTime]::Now).AddDays(-1) -RollupType Avg -IntervalType Days -IntervalCount 1|Sort-Object Key|Select @{N='Daily Average'; E={$_.Key}},@{N="Value in %"; E={[math]::round($_.value)}}| ConvertTo-EnhancedHTMLFragment -As Table -PreContent "<h2>Daily Average Utilization</h2>"

# Average usages stats over the past 14 days
$14average = Get-OMResource $TroubleVM| Get-OMStat -key 'mem|usage_average','cpu|usage_average','cpu|readyPct','cpu|costoppct' -From ([DateTime]::Now).AddDays(-14) -RollupType Avg -IntervalType Days -IntervalCount 15|Sort-Object Key|Select @{N='Fourteen Day Average'; E={$_.Key}},@{N="Value in %"; E={[math]::round($_.value)}}| ConvertTo-EnhancedHTMLFragment -As Table -PreContent "<h2>Fourteen Day Average Utilization</h2>"

# Sizing Recommendations Stress=%
$Reccomendation = Get-OMResource $TroubleVM| Get-OMStat -key 'cpu|stress','cpu|numbertoadd','mem|stress','mem|underusedpercent','mem|waste'  -From ([DateTime]::Now).AddDays(-14) -RollupType Avg -IntervalType Days -IntervalCount 15|Sort-object Key|Select @{N='Sizing Recommendation'; E={$_.Key}},@{N="Value"; E={[math]::Truncate($_.value)}} | ConvertTo-EnhancedHTMLFragment -As Table -PreContent "<h2> Sizing Recommendations</h2>"


# Most Recent vCenter Events
$VMEvents = Get-VM $TroubleVM| Get-VIEvent -MaxSamples 5 | select UserName, CreatedTime, FullFormattedMessage | ConvertTo-EnhancedHtmlFragment -PreContent "<h2> vCenter Events (previous five)</h2>"

# Last 5 System Event Log Errors
$SysEvents = Get-Eventlog -LogName System -computer $TroubleVM -EntryType Error -Newest 5  | Select TimeGenerated, Source, Message | ConvertTo-Html -Fragment -PreContent "<h2>System Event Log Errors</h2>"

# Last 5 Application Event Log Errors
$AppEvents = Get-Eventlog -LogName Application -computer $TroubleVM -EntryType Error -Newest 5 | Select TimeGenerated, Source, Message | ConvertTo-Html -Fragment -PreContent "<h2>Application Event Log Errors</h2>"


ConvertTo-EnhancedHTML -HTMLFragments $BasicConfig, $HDDinfo, $DayAverage, $14average, $Reccomendation, $VMEvents, $SysEvents, $AppEvents -Title "Health Check" -CssUri styles2.css -PreContent "<h1>Health Check for $TroubleVM</h1>" | Out-file "EnhancedVMHealthCheck.html" -Encoding ASCII

Write-Host "Script Complete"
