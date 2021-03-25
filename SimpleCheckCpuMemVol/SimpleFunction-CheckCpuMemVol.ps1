<#
.Synopsis
   Simple Functions to get CPU, MEM E DISK USAGE OF REMOTE COMPUTER
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.AUTHOR
  Juliano Alves de Brito Ribeiro (Find me at jaribeiro@uoldiveo.com or julianoalvesbr@live.com or https://github.com/julianoabr)
.VERSION
  0.1
.ENVIRONMENT
  PROD
.NEXT IMPROVEMENTS
  NOT YET  
  
.TOTHINK

This is was written more than 2000 years ago, and we are so close to this. Revelation Chapter 13. 

15 The second beast was given power to give breath to the image of the first beast, so that the image could speak and cause all who refused to worship the image to be killed.
16 It also forced all people, great and small, rich and poor, free and slave, to receive a mark on their right hands or on their foreheads, 
17 so that they could not buy or sell unless they had the mark, which is the name of the beast or the number of its name.

#>


# The function will check the processor counter and check for the CPU usage. Takes an average CPU usage for 5 seconds. It check the current CPU usage for 5 secs.
Function CheckCpuUsage() 
{ 
	param ($hostname)
	Try { $CpuUsage=(Get-WmiObject -ComputerName $hostname -class win32_processor -ErrorAction Stop | Measure-Object -property LoadPercentage -Average | Select-Object -ExpandProperty Average)
    $CpuUsage = [math]::round($CpuUsage, 1); return $CpuUsage


	} Catch { Write-Host "Error returned while checking the CPU usage. Perfmon Counters may be fault" -ForegroundColor White -BackgroundColor Red } 
}


# The function check the memory usage and report the usage value in percentage
Function CheckMemoryUsage()
{ 
	param ($hostname)
    Try 
	{   $SystemInfo = (Get-WmiObject -ComputerName $hostname -Class Win32_OperatingSystem -ErrorAction Stop | Select-Object TotalVisibleMemorySize, FreePhysicalMemory)
    	$TotalRAM = $SystemInfo.TotalVisibleMemorySize/1MB 
    	$FreeRAM = $SystemInfo.FreePhysicalMemory/1MB 
    	$UsedRAM = $TotalRAM - $FreeRAM 
    	$RAMPercentUsed = ($UsedRAM / $TotalRAM) * 100 
    	$RAMPercentUsed = [math]::round($RAMPercentUsed, 2);
    	return $RAMPercentUsed
	} Catch { Write-Host "Error returned while checking the Memory usage. Perfmon Counters may be fault" -ForegroundColor White -BackgroundColor Red } 
}


# The function check the HardDrive usage and report the usage value in percentage and free space
Function CheckHardDiskUsage() 
{ 
	param ($hostname, $deviceID)
    Try 
	{   
    	$HardDisk = $null
		$HardDisk = Get-WmiObject -ComputerName $hostname -Class Win32_LogicalDisk -Filter "DeviceID='$deviceID'" -ErrorAction Stop | Select-Object Size,FreeSpace
        if ($null -ne $HardDisk)
		{
		$DiskTotalSize = $HardDisk.Size 
        $DiskFreeSpace = $HardDisk.FreeSpace 
        $frSpace=[Math]::Round(($DiskFreeSpace/1073741824),2)
		$PercentageDS = (($DiskFreeSpace / $DiskTotalSize ) * 100); $PercentageDS = [math]::round($PercentageDS, 2)
		
		Add-Member -InputObject $HardDisk -MemberType NoteProperty -Name PercentageDS -Value $PercentageDS
		Add-Member -InputObject $HardDisk -MemberType NoteProperty -Name frSpace -Value $frSpace
		} 
		
    	return $HardDisk
	} Catch {Write-Host "Error returned while checking the Hard Disk usage. Perfmon Counters may be fault" -ForegroundColor White -BackgroundColor Red} 
}


#USAGE

CheckCpuUsage -hostname Server
CheckMemoryUsage -hostname Server
CheckHardDiskUsage -hostname Server












