#Author:  https://github.com/terracuda/workpow


ECHO "Collecting the report..."

# Variables
$DateStamp = get-date -uformat "%m-%d-%Y"
$TimeStamp = get-date
$file = "D:\workspace\script\HyperV_Report_$DATEStamp.txt"       #Mask of the path where the reports will be saved
$VMS = get-vm
$computers = $Env:COMPUTERNAME
$snps = get-vmsnapshot -vmname *
$vmcnt = (get-vm).Count
$hpath = (Get-VMHost).VirtualHardDiskPath
$hsize = "{0:N2} MB" -f ((Get-ChildItem $hpath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
$rec = out-file $file -append



# put date and time in the file
echo "Date: $TimeStamp" | out-file $file

# get host uptime
Get-CimInstance Win32_OperatingSystem | Select @{Name="HostName";Expression={$_."csname"}},@{Name="Uptime=D.H:M:S.Millseconds";Expression={(Get-Date) - $_.LastBootUpTime}},LastBootUpTime | format-list | out-file $file -append

# get host name, total virtual CPU count, total RAM, virtualharddiskpath and virtualmachinepath
Get-VMHost | Select @{Name="HostName";Expression={$_."Name"}},@{N="Total RAM(GB)";E={""+ [math]::round($_.Memorycapacity/1GB)}},logicalprocessorcount,virtualharddiskpath,virtualmachinepath | out-file $file -append

echo "HOST Server IP Addresses and NIC's" | out-file $file -append
Get-WMIObject win32_NetworkAdapterConfiguration |   Where-Object { $_.IPEnabled -eq $true } | Select IPAddress,macaddress,Description | format-table -autosize | out-file $file -append

echo "HOST Server drive D: Disk Space" | out-file $file -append
Get-psdrive D | Select Root,@{N="Total(GB)";E={""+ [math]::round(($_.free+$_.used)/1GB)}},@{N="Used(GB)";E={""+ [math]::round($_.used/1GB)}},@{N="Free(GB)";E={""+ [math]::round($_.free/1GB)}} |format-table -autosize | out-file $file -append

echo "Hosts virtual switch(s) information" | out-file $file -append
get-vmswitch * | out-file $file -append

echo "+++++++++ Total number of VM's: $vmcnt +++++++++" | out-file $file -append
echo "+++++++++ Disk space used: $hsize +++++++++" | out-file $file -append
echo " " | out-file $file -append

echo "---------Detailed VMs information---------" | out-file $file -append
$outputArray = @()
foreach($VM in $VMS)
    { 
      $VMsRAM = [math]::round($VM.Memoryassigned/1MB)
      $VMsCPU = $VM.processorCount
      $VMsState = $VM.State
      $VMsStatus = $VM.Status
      $VMsUptime = $VM.Uptime
      $VMsAutomaticstartaction = $VM.Automaticstartaction
      $VMsIntegrationServicesVersion = $VM.IntegrationServicesVersion
      $VMsReplicationState = $VM.ReplicationState
      $VHDs = Get-VHD -VMId $VM.VMiD
      $VHDsMB = [math]::round($VHDs.FileSize/1MB)
      $VMDVD = Get-vmdvddrive -VMname $VM.VMname
    
      $output = new-object psobject
      $output | add-member noteproperty "VM Name" $VM.Name
      $output | add-member noteproperty "RAM(MB)" $VMsRAM
      $output | add-member noteproperty "Cores" $VMsCPU
      $output | add-member noteproperty "State" $VMsState
      $output | add-member noteproperty "Uptime" $VMsUptime
      $output | add-member noteproperty "Status" $VMsStatus
      $output | add-member noteproperty "VHD Size(MB)" $VHDsMB
      $output | add-member noteproperty "VHD Path" $VHDs.Path
      $output | add-member noteproperty "VHD Type" $VHDs.vhdtype
      $output | add-member noteproperty "DVD Type" $VMDVD.dvdmediatype
      $output | add-member noteproperty "DVD Path" $VMDVD.path
 #     $output | add-member noteproperty "Start Action" $VMsAutomaticstartaction
 #     $output | add-member noteproperty "Integration Tools" $VMsIntegrationServicesVersion
 #     $output | add-member noteproperty "Replication State" $VMsReplicationState     
 #     $output | add-member noteproperty "VHD Format" $VHDs.vhdformat
       $outputArray += $output
     }
write-output $outputarray | sort "VM Name" | format-table * -autosize  | out-string -width 600 | out-file $file -append

echo "---------VM's Snapshot and location---------" | out-file $file -append
get-vmsnapshot -vmname * | sort "VMName" | format-table -autosize | out-file $file -append

echo "---------VM's BIOS settings---------" | out-file $file -append
Get-VMBios * -ErrorAction SilentlyContinue | sort "VMName" | Format-Table -autosize | out-file $file -append
Get-VMFirmware * -ErrorAction SilentlyContinue | sort "VMName" | Format-Table -autosize | out-file $file -append

echo "---------Additional VMs network info---------" | out-file $file -append
get-vmnetworkadapter * | Select vmname,macaddress,ipaddresses | sort "VMName" | format-list | out-file $file -append

Get-Content $file 

#load the report in notepad
notepad.exe $file #"D:\workspace\script\Report_$DATEStamp.txt"

