#*****************************************************************************
# Mouule: jcstudio.os
# Author: jclee95
# Chinese name: 李俊才
# Email: 291148484@163.com
# Author blog: https://blog.csdn.net/qq_28550263?spm=1001.2101.3001.5343
# Copyright Jack Lee. All rights reserved.
# Licensed under the MIT License.
#*****************************************************************************

class sysinfos {

    static [object]GetServiceInfos() {
        <# Get the related data of the specified service. #>
        $services = Get-WmiObject -Class Win32_Service
        $service_info=@{}
        foreach ($i in $services) {
            $ServiceName = $i.Name
            if($ServiceName -ne $null){
                
                $service_info[$ServiceName] =  @{};
                $service_info[$ServiceName]["ExitCode"] = $i.ExitCode;
                $service_info[$ServiceName]["ProcessID"] = $i.ProcessID;
                $service_info[$ServiceName]["StartMode"] = $i.StartMode;
                $service_info[$ServiceName]["State"] = $i.State;
                $service_info[$ServiceName]["Status"] = $i.Status;
            }
            
        }
        return $service_info
    }
    # (GetServiceInfos)["JBoss"] | ConvertTo-Json

    static [object]IP4RouteTable(){
        <# Information that controls the routing of network packets #>
        return Get-WmiObject -Class Win32_IP4RouteTable
    }
   


    static [object]GetProcessInfos() {
        <# Get the relevant data of all processes #>
        $process = Get-WmiObject -Class Win32_Process;
        $process_info=@{};
        
        foreach ($i in $process) {

            $ProcessName = $i.Name
            if($ProcessName -ne $null){
                
                $process_info[$ProcessName] = @{};
                $process_info[$ProcessName]["Path"] = $i.Path; 
                $process_info[$ProcessName]["ExecutablePath"] = $i.ExecutablePath; 
                $process_info[$ProcessName]["Description"] = $i.Description;
                $process_info[$ProcessName]["CreationDate"] = $i.CreationDate;
                $process_info[$ProcessName]["InstallDate"] = $i.InstallDate;
                $process_info[$ProcessName]["TerminationDate"] = $i.TerminationDate;
                $process_info[$ProcessName]["UserModeTime"] = $i.UserModeTime;
                $process_info[$ProcessName]["Prioroty"] = $i.Prioroty;
                $process_info[$ProcessName]["Status"] = $i.Status;
                $process_info[$ProcessName]["SessionID"] = $i.SessionID;
                $process_info[$ProcessName]["ThreadCount"] = $i.ThreadCount;
                $process_info[$ProcessName]["CSName"] = $i.CSName;
                $process_info[$ProcessName]["Handle"] = $i.Handle;
                $process_info[$ProcessName]["HandleCount"] = $i.HandleCount;
                $process_info[$ProcessName]["VirtualSize"] = $i.VirtualSize;
                $process_info[$ProcessName]["WorkSetSize"] = $i.WorkSetSize;
            }
            
        }
        return $process_info
    }

    static [object]GetSystemRunningTime() {
        <# Get the running time of the system #>
        return ([Environment]::TickCount /86400000).ToString().Substring(0,3)+" D"
    }

    static [object]GetCPULoad(){
        <# Get the utilization rate of each core of CUP #>
        return @((Get-WmiObject -Class Win32_processor).LoadPercentage)
    }

    static [object]GetThread(){
        <# Get execution thread #>
        return Get-WMIObject -Class Win32_Thread
    }

    static [object]GetIpAddress(){
        $items = @{}
        $Name = "_?"
        foreach ($i in (ipconfig|findstr ":")) {
            
            if ($i.Split(":")[1] -eq ""){
                $Name = ($i.Split(":")[0]).Replace(" ","_")
                $items[$Name] = @{}
            }
            
            if($i.Contains("DNS")){
                $items[$Name]["DNS Suffix"] = ($i.Split(": ")[1])
            }
            if($i.Contains("IPv4")){
                $items[$Name]["IPv4"] = ($i.Split(": ")[1])
            }
            if($i.Contains("IPv6")){
                $items[$Name]["IPv6"] = ($i.Split(": ")[1])
            }
            
            
        }
        return $items
    }

    static [object]GetNetAdapterByDeviceID([int]$DeviceID){
        return Get-WMIObject -class Win32_NetworkAdapter -Filter DeviceID=$DeviceID
    }

    static [object]GetNetAdapterByName([string]$Name){
        return Get-WMIObject -class Win32_NetworkAdapter -Filter Name=$Name
    }

    static [object]GetNetAdapterByMACAddress([string]$MACAddress){
        return Get-WMIObject -class Win32_NetworkAdapter -Filter MACAddress=$MACAddress
    }

    static [object]GetVolume(){
        <# Get the storage area on the computer #>
        return Get-WmiObject -Class Win32_Volume
    }

    static [object]GetMemoryInfos(){
        $PhysicalMemory = Get-WmiObject -Class Win32_PhysicalMemory
        $free_total = ([math]::round(((Get-WmiObject -Class Win32_OperatingSystem).FreePhysicalMemory / (1mb)), 2))
        $Speed = @($PhysicalMemory.Speed);
        $Speed_Average = [math]::round((($PhysicalMemory.Capacity | Measure-Object -Average).Average /1000000),1)
        $capacity_total = [math]::round((($PhysicalMemory.Capacity | Measure-Object -Sum).Sum /1gb))
        return @{
            Capacitys = $PhysicalMemory.Capacity;
            Speeds=$Speed;
            Speed_Average = $Speed_Average
            Capacity_total = $capacity_total.ToString()+' Gb';
            Free_total = $free_total.ToString()+' Gb';
            Usage_Rate = ([math]::round(($capacity_total-$free_total)/$capacity_total, 2)).ToString() + '%'
        }

    }

    static [object]GetLocalTime(){
        <# This method is used to obtain the local time of the computer #>
        return Get-WmiObject -Class Win32_LocalTime
    }

    static [object]GetSessionProcess(){
        <# Get the association between the login session and the process associated with the session #>
        return Get-WmiObject -Class Win32_SessionProcess
    }

    static [object]GetSystemAccount(){
        <# Get Windows system account #>
        return Get-WmiObject -Class Win32_SystemAccount
    }

    static [object]GetUserAccount(){
        <# Get user account information on Windows system #>
        return Get-WmiObject -Class Win32_UserAccount
    }

    static [object]GetStartupCommand(){
        <# Get the command that runs automatically when the user logs in to the computer #>
        return Get-WmiObject -Class Win32_StartupCommand
    }

    static [object]GetUserInDomain(){
        <# Get associated user account and Windows NT domain #>
        return Get-WmiObject -Class Win32_UserInDomain
    }

    static [object]GetNTLogEvent(){
        <# Get Windows events #>
        return Get-WmiObject -Class Win32_NTLogEvent
    }

    static [object]GetNTEventLogFile(){
        <# Get the data stored in the windows event log #>
        return Get-WmiObject -Class Win32_NTEventLogFile
    }

    static [object]GetDiskPartition(){
        <# Get the function and management capacity of the physical disk partition area on the computer system running Windows. #>
        return Get-WmiObject -Class Win32_DiskPartition
    }

    static [object]GetDiskUsage() {
        <# Get all partition usage #>
        $logicaldisk = Get-WmiObject -Class Win32_Logicaldisk
        $disk_info=@{}
        foreach ($i in $logicaldisk) {
            $DeviceID = ($i.DeviceID).ToString();
            
            if($DeviceID -ne $null){
                $disk_info[$DeviceID] = @{}
            
                if(($i.Size -ne 0) -and  ($i.Size -ne $null)){
                    $disk_info[$DeviceID]['Total'] = ($i.Size/1073741824).ToString().Substring(0,5)+"Gb";
                    $disk_info[$DeviceID]['Free'] = ($i.FreeSpace/1073741824).ToString().Substring(0,5)+"Gb";
                    $disk_info[$DeviceID]['Usage'] = ((($i.Size-$i.FreeSpace) / $i.Size)*100).ToString().Substring(0,5)+"%"
                }else{
                    $disk_info[$DeviceID]['Total'] = $null
                    $disk_info[$DeviceID]['Free'] = $null
                    $disk_info[$DeviceID]['Usage'] = $null
                }
            }  
        }
        return $disk_info
    }

    # start menu

    static [object]GetLogicalProgramGroup(){
        <# Get the program group in the computer system running Windows #>
        return Get-WmiObject -Class Win32_LogicalProgramGroup
    }

    static [object]GetLogicalProgramGroupDirectory(){
        <# Associating logical program groups (grouping them into the Start menu) and the file directory where they are stored #>
        return Get-WmiObject -Class Win32_LogicalProgramGroupDirectory
    }

    static [object]GetLogicalProgramGroupItem(){
        <# Represents an element contained by a Win32_ProgramGroup instance, which is not another Win32_ProgramGroup instance #>
        return Get-WmiObject -Class Win32_LogicalProgramGroupItem
    }

    static [object]GetLogicalProgramGroupItemDataFile(){
        <# Associates the program group items in the Start menu with the files stored in them #>
        return Get-WmiObject -Class Win32_LogicalProgramGroupItemDataFile
    }

    static [object]GetProgramGroupContents(){
        <# Associates the sequence of program groups and the contained individual program groups or items #>
        return Get-WmiObject -Class Win32_ProgramGroupContents
    }

    static [object]GetProgramGroupOrItem(){
        <# Get the logical grouping of programs on the user's Start menu |Programs menu #>
        return et-WmiObject -Class Win32_ProgramGroupOrItem
    }

}

