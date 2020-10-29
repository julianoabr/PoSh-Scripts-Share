#Requires -RunAsAdministrator
#Requires -Version 4.0
<#
.Synopsis
   Generate and Export BPA Results
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.AUTHOR
  Juliano Alves de Brito Ribeiro (jaribeiro@uoldiveo.com or julianoalvesbr@live.com or https://github.com/julianoabr/)
.VERSION
  0.3
.ENVIRONMENT
  DEV
  
#BASED ON https://www.jorgebernhardt.com/using-powershell-bpa-reports-html/

.TOTHINK

This is was written more than 2000 years ago, and we are so close to this. Revelation Chapter 13. 

15 The second beast was given power to give breath to the image of the first beast, so that the image could speak and cause all who refused to worship the image to be killed.
16 It also forced all people, great and small, rich and poor, free and slave, to receive a mark on their right hands or on their foreheads, 
17 so that they could not buy or sell unless they had the mark, which is the name of the beast or the number of its name.

#>
Clear-Host

#FULL BPA ID LIST
    $tmpBPAIdList = @(
('Application-Server','Microsoft/Windows/ApplicationServer'),
('ADRMS','Microsoft/Windows/ADRMS'),
('AD-Certificate','Microsoft/Windows/CertificateServices'),
('Failover-Clustering','Microsoft/Windows/ClusterAwareUpdating'),
('DHCP','Microsoft/Windows/DHCPServer'),
('AD-Domain-Services','Microsoft/Windows/DirectoryServices'),
('DNS','Microsoft/Windows/DNSServer'),
('File-Services','Microsoft/Windows/FileServices'),
('Hyper-V','Microsoft/Windows/Hyper-V'),
('ADLDS','Microsoft/Windows/LightweightDirectoryServices'),
('NPAS','Microsoft/Windows/NPAS'),
('RemoteAccess','Microsoft/Windows/RemoteAccessServer'),
('Remote-Desktop-Services','Microsoft/Windows/TerminalServices'),
('OOB-WSUS','Microsoft/Windows/UpdateServices'),
('VolumeActivation','Microsoft/Windows/VolumeActivation'),
('Web-Server','Microsoft/Windows/WebServer')
)


$shortDate = (Get-date -Format ddMMyyyy-HH).ToString()

$outputPath = "$env:SystemDrive\Temp"


if (Test-Path $outputPath){
        
    Write-Output "O caminho para salvar o Report existe."
                        
}#end IF
else{
        
    Write-Output "O caminho para salvar o Report não existe."

    New-Item -Path "$env:SystemDrive\" -ItemType Directory -Name "Temp" -Force -Verbose -ErrorAction Continue
            
}#end Else


#FUNCTION TO PAUSE SCRIPT
function Pause-PSScript
{

   Read-Host 'Pressione [ENTER] para continuar' | Out-Null

}

#FUNCTION PING TO TEST CONNECTIVITY
function Ping
([string]$hostname, [int]$timeout = 100) 
{
    $ping = new-object System.Net.NetworkInformation.Ping #creates a ping object
    
    try { $result = $ping.send($hostname, $timeout).Status.ToString() }
    catch { $result = "Failure" }
    return $result
}


#VALIDATE IF OPTION IS NUMERIC
function isNumeric ($x) {
    $x2 = 0
    $isNum = [System.Int32]::TryParse($x, [ref]$x2)
    return $isNum
} #end function is Numeric


function Create-PSMenu
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                  Position=0)]
        [System.Object[]]$arrayExternalList,
        
        [Parameter(Mandatory=$true,
                   Position=1)]
        [System.Boolean]$addALLOption = $true
      

    )

$arrayInternal = @()

if ($addALLOption){
    
    $arrayInternal = $arrayExternalList

    $arrayExternalList += 'All'

}else{

    $arrayInternal = $arrayExternalList

}

$workingArrayIDNum = ""
$tmpWorkingArrayIDNum = ""
$script:WorkingArrayIDType = ""
$iCounter = 0

#MENU SELECT SYNC TYPE
foreach ($arrayValue in $arrayExternalList){
	   
        $MenuValue = $arrayValue
	    
        Write-Output "            [$iCounter].- $MenuValue ";	
	    
        $iCounter++	
        
        }#end foreach	
        
        Write-Output "            [$iCounter].- Exit this script";

        
        while(!(isNumeric($tmpWorkingArrayIDNum)) ){
	        $tmpWorkingArrayIDNum = Read-Host "Select a Option from a Above Powershell Menu"
        }#end of while

            $workingArrayIDNum = ($tmpWorkingArrayIDNum / 1)

        if(($workingArrayIDNum -ge 0) -and ($workingArrayIDNum -le ($iCounter-1))  ){
	        $script:WorkingArrayIDType = $arrayExternalList[$workingArrayIDNum]
        }
        else{
            
            Write-Host "Exit selected, or Invalid choice number. End of Script " -ForegroundColor Red -BackgroundColor White
            
            Exit;

        }#end of else

        Write-Host "You choose Option: $script:WorkingArrayIDType" -ForegroundColor White -BackgroundColor DarkBlue
        
        return $script:WorkingArrayIDType


}#End of Function


$wmiOSBlock = {param($hostname)
  try { $wmi=Get-WmiObject -class Win32_OperatingSystem -ComputerName $hostname -ErrorAction Stop }
  catch { $wmi = $null }
  return $wmi
}


#RUN SCRIPT LOCAL OR REMOTE
do
{
 
 $answerLR = ""
 $tmpAnswerLR = ""

 [System.String]$tmpanswerLR = Read-Host "Write [LOCAL] to run script in this computer. Write [REMOTE] to run script in another computer"
 
 $answerLR = $tmpanswerLR.ToUpper() 
  
}
while ($answerLR -notmatch '^(?:LOCAL\b|REMOTE\b)')

Write-Host "You chooose run script in mode: $answerLR" -ForegroundColor White -BackgroundColor DarkBlue


if ($answerLR -eq 'LOCAL'){

 $bpaIDList = @()
 
foreach ($tmpBPAIdValue in $tmpBPAIdList){
    
    $featureName = $tmpBPAIDValue[0]
    
    $bpaName = $tmpBPAIDValue[1]

    if ((Get-WindowsFeature -Name $featureName).Installed) { 
        
        $bpaIDList += $bpaName
    } 

}#end of ForEach

$bpaIDList
 
Create-PSMenu -arrayExternalList $bpaIDList -addALLOption $true
 
           
        if ($script:WorkingArrayIDType -eq 'All'){
            
            $runBPAIDList = @()

            #Remove All from Array
            [System.Collections.ArrayList]$tmpRunBPAIDList = $bpaIDList

            $tmpRunBPAIDList.Remove('All')
            
            #RUN BPA#
            foreach ($runBpaID in $tmpRunBPAIDList){
                
                $bpaResult = ""
                
                #$bpaResult = Invoke-BpaModel -ModelId $runBpaID -ErrorAction SilentlyContinue
                
                $bpaResult = Invoke-BpaModel -ModelId $runBpaID -Mode Analysis -ThrottleLimit 8 -ErrorAction SilentlyContinue 
                                
                if ($bpaResult.Success){
                
                    $runBPAIDList += $runBpaID
                
                }#End of If equal success

            }#end of ForEach BPA Run

            #HTML BPA CONFIG
            $head = '<Style>
            BODY {font-size:0.9em; font-family:Lucida Console;background-color:#A4A4A4;}
            TABLE{font-size:0.8em; border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}
            TH {font-size:1.2em; border-width: 2px;padding: 2px;border-style:solid;border-color: black; background-color: #0099cc}
            TD {border-width: 1px;padding: 2px;border-style:solid;border-color: black; background-color: #ffffff}
            </style>'
 
            $body = "<H1>Best Practices Analyzer Report</H1><h2>$env:ComputerName</h2>"

            $title = "Best Practices Analyzer Report For Computer - $env:ComputerName"

            
            #GET BPA RESULTS
            foreach ($runbpaId in $runBPAIDList){
    
                $bpaName = ""

                [System.String]$bpaName = $runbpaID.Split("/")[2]

                Get-BpaResult -ModelId $runBpaID | Where-Object -FilterScript {($PSItem.Severity -eq "Error") -or ($PSItem.Severity -eq "Warning")} | Sort-Object -Property Severity | 
                Select-Object -Property ComputerName,Category,Severity,Title,Problem,Impact,Resolution,Help |
                ConvertTo-Html -Head $head -Body $body -PreContent "MSFT Model ID: $bpaName" -Title $title | Out-File "$outputPath\BPAResults-$Hostname-$shortDate.html" -Append

}#End of ForEach
            
        
        }#End of If BPA Report
        else{
        
        
            Invoke-BpaModel -ModelId $script:WorkingArrayIDType -Verbose


            #HTML BPA CONFIG
            $head = '<Style>
            BODY {font-size:0.9em; font-family:Lucida Console;background-color:#A4A4A4;}
            TABLE{font-size:0.8em; border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}
            TH {font-size:1.2em; border-width: 2px;padding: 2px;border-style:solid;border-color: black; background-color: #0099cc}
            TD {border-width: 1px;padding: 2px;border-style:solid;border-color: black; background-color: #ffffff}
            </style>'
 
            $body = "<H1>Best Practices Analyzer Report</H1><h2>$env:ComputerName</h2>"

            $title = "Best Practices Analyzer Report For Computer - $env:ComputerName"

            $bpaName = ""

            [System.String]$bpaName = $script:WorkingArrayIDType.Split("/")[2]

            Get-BpaResult -ModelId $script:WorkingArrayIDType | Where-Object -FilterScript {($PSItem.Severity -eq "Error") -or ($PSItem.Severity -eq "Warning")} | Sort-Object -Property Severity | 
            Select-Object -Property ComputerName,Category,Severity,Title,Problem,Impact,Resolution,Help |
            ConvertTo-Html -Head $head -Body $body -PreContent "MSFT Model ID: $bpaName" -Title $title | Out-File "$outputPath\BPAResults-$Hostname-$shortDate.html" -Append

        
        }#End of Else BPA Report
        


}#End of Local Mode
else{

#REMOTE MODE ONLY SUPPORTS ONE COMPUTER
$rComputerName = Read-Host "Type the Remote ComputerName"


#VALIDATE REMOTE WMI
$rJob = Start-Job -ScriptBlock $wmiOSBlock -ArgumentList $rComputerName
    
$rWmi = Wait-job $rJob -Timeout 15 | Receive-Job


    if ($null -ne $rWmi){
    
        $rSession = New-PSSession -ComputerName $rComputerName
    
        $rTmpBpaIDList = @()
    
        foreach ($tmpBPAIdValue in $tmpBPAIdList){
    
            $featureName = $tmpBPAIDValue[0]
    
            $bpaName = $tmpBPAIDValue[1]

            if ((Get-WindowsFeature -ComputerName $rComputerName -Name $featureName).Installed) { 
        
                $rTmpBpaIDList += $bpaName
            }#end of If
            else{
            
                Write-Host "I can't find the feature named: $featureName in remote computer: $rComputerName"

            }#end of Else 

}#end of ForEach

$rTmpBpaIDList

if ($rTmpBpaIDList){

    #Array to Work
    [System.Collections.ArrayList]$rBPAIDList = $rTmpbpaIDList

    #HTML BPA CONFIG
    $head = '<Style>
    BODY {font-size:0.9em; font-family:Lucida Console;background-color:#A4A4A4;}
    TABLE{font-size:0.8em; border-width: 2px;border-style: solid;border-color: black;border-collapse: collapse;}
    TH {font-size:1.2em; border-width: 2px;padding: 2px;border-style:solid;border-color: black; background-color: #0099cc}
    TD {border-width: 1px;padding: 2px;border-style:solid;border-color: black; background-color: #ffffff}
    </style>'
 
    $body = "<H1>Best Practices Analyzer Report</H1><h2>$rComputerName</h2>"

    $title = "Best Practices Analyzer Report For Computer - $rComputerName"


    #INVOKE BPA LIST
    foreach ($rBpaValue in $rBpaIDList){

      #Invoke-Command -Session $rSession -ScriptBlock{Invoke-BpaModel -ModelId $Using:rBpaID -Verbose}

      Invoke-Command -Session $rSession -ScriptBlock{Invoke-BpaModel -ModelId $Using:rBpaValue -Mode Analysis -ThrottleLimit 1 -Verbose}

      #WAIT TO GENERATE VALUES
      Start-Sleep -Seconds 20

    }#end of ForEach

    #GET BPA RESULTS
    foreach ($rBpaId in $rBPAIDList){
   
        $bpaName = ""

        [System.String]$bpaName = $rBpaID.Split("/")[2]

        $tmpObjectBPA = Invoke-Command -Session $rSession -ScriptBlock{Get-BpaResult -ModelId $Using:rBpaID | Where-Object -FilterScript {($PSItem.Severity -eq "Error") -or ($PSItem.Severity -eq "Warning")} | Sort-Object -Property Severity | 
        Select-Object -Property ComputerName,Category,Severity,Title,Problem,Impact,Resolution,Help}
        
        #WAIT TO GENERATE VALUES
        Start-Sleep -Seconds 5
    
        if ($tmpObjectBPA -ne $null){
    
            $tmpObjectBPA | ConvertTo-Html -Head $head -Body $body -PreContent "MSFT Model ID: $bpaName" -Title $title | Out-File "$outputPath\BPAResults-$rComputerName-$shortDate.html" -Append

        }
        else{
    
            Write-Host "I can't get BPA Result of $bpaName" -ForegroundColor White -BackgroundColor Red
    
        }

    }#End of ForEach GET BPA RESULTS


}#IF OK TO RUN IF NOT NULL
else{

    Write-Host "I can't run BPA on Remote Computer: $rComputerName because I didn't find any BPA Model there" -ForegroundColor White -BackgroundColor Red


}#END OF ELSE NOT OK TO RUN
    
    
    }#IF WMI REMOTE IS OK
    else{
    
    
        Write-Host "Please Verifiy WMI in Remote Server: $rComputerName. Or Run This script directly in Remote Server through Console or RDP Session" -ForegroundColor White -BackgroundColor DarkRed
               
        $rJobID = $rJob.Id

        Get-Job -Id $rJobID | Remove-Job -Force
    
    }#ELSE WMI REMOTE IS NOT OK

      

}#End of Remote Mode

Explorer $outputPath
