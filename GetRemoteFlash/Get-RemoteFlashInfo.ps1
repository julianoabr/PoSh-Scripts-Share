#Requires -RunAsAdministrator
#Requires -Version 4.0
<#
.Synopsis
   Get Remote Flash Player Installed on Servers
.DESCRIPTION
   Get Remote Flash Player Installed on Servers
.EXAMPLE
   Open PS_ISE as Administrator and run
.EXAMPLE
   Open PS Console as Administrator and run
.AUTHOR
  Juliano Alves de Brito Ribeiro (Find me at jaribeiro@uoldiveo.com or julianoalvesbr@live.com or https://github.com/julianoabr)
.VERSION
  0.1
.ENVIRONMENT
  WINDOWS
.Flash Info

##### x64

FileVersionRaw     : 24.0.0.194
ProductVersionRaw  : 24.0.0.194
Comments           :
CompanyName        : Adobe Systems, Inc.
FileBuildPart      : 0
FileDescription    : Adobe Flash Player 24.0 r0
FileMajorPart      : 24
FileMinorPart      : 0
FileName           : \\server1\c$\Windows\SysWOW64\Macromed\Flash\Flash32_24_0_0_194.ocx
FilePrivatePart    : 194
FileVersion        : 24,0,0,194
InternalName       : Adobe Flash Player 24.0
IsDebug            : False
IsPatched          : False
IsPrivateBuild     : False
IsPreRelease       : False
IsSpecialBuild     : False
Language           : English (United States)
LegalCopyright     : Adobe® Flash® Player. Copyright © 1996-2017 Adobe Systems Incorporated. All Rights Reserved. Adobe and Flash are either trademarks or registered trademarks in the United States
                     and/or other countries.
LegalTrademarks    : Adobe Flash Player
OriginalFilename   : Flash.ocx
PrivateBuild       :
ProductBuildPart   : 0
ProductMajorPart   : 24
ProductMinorPart   : 0
ProductName        : Shockwave Flash
ProductPrivatePart : 194
ProductVersion     : 24,0,0,194
SpecialBuild       :

#### x32

FileVersionRaw     : 11.2.202.235
ProductVersionRaw  : 11.2.202.235
Comments           :
CompanyName        : Adobe Systems, Inc.
FileBuildPart      : 202
FileDescription    : Adobe Flash Player 11.2 r202
FileMajorPart      : 11
FileMinorPart      : 2
FileName           : \\server2\c$\WINDOWS\system32\Macromed\Flash\Flash32_11_2_202_235.ocx
FilePrivatePart    : 235
FileVersion        : 11,2,202,235
InternalName       : Adobe Flash Player 11.2
IsDebug            : False
IsPatched          : False
IsPrivateBuild     : False
IsPreRelease       : False
IsSpecialBuild     : False
Language           : English (United States)
LegalCopyright     : Adobe® Flash® Player. Copyright © 1996-2012 Adobe Systems Incorporated. All Rights Reserved. Adobe and Flash are either trademarks or registered trademarks in the United States
                     and/or other countries.
LegalTrademarks    : Adobe Flash Player
OriginalFilename   : Flash.ocx
PrivateBuild       :
ProductBuildPart   : 202
ProductMajorPart   : 11
ProductMinorPart   : 2
ProductName        : Shockwave Flash
ProductPrivatePart : 235
ProductVersion     : 11,2,202,235
SpecialBuild       :


  PROD
.NEXT IMPROVEMENTS
  This Script works only on Windows Server 2003 and above. The source computer (where you run this) must have Powershell v4 or superior
  

.TOTHINK

This is was written more than 2000 years ago, and we are so close to this. Revelation Chapter 13. 

15 The second beast was given power to give breath to the image of the first beast, so that the image could speak and cause all who refused to worship the image to be killed.
16 It also forced all people, great and small, rich and poor, free and slave, to receive a mark on their right hands or on their foreheads, 
17 so that they could not buy or sell unless they had the mark, which is the name of the beast or the number of its name.

#>
Clear-Host

#GET START TIME
$scriptstart = Get-Date

function Pause-PSScript
{

   Read-Host 'Pressione [ENTER] para continuar' | Out-Null

}

#FUNCTION PING TO TEST CONNECTIVITY
function PS-Ping
([string]$hostname, [int]$timeout = 50) 
{
    $ping = new-object System.Net.NetworkInformation.Ping #creates a ping object
    
    try { $result = $ping.send($hostname, $timeout).Status.ToString() }
    catch { $result = "Failure" }
    return $result
}


WorkFlow WFRemoteFlashVersion {

   param([System.String[]]$rServerList)

   foreach –parallel ($rServer in $rServerList){

       
    InLineScript {

        $x32partPath = '\c$\WINDOWS\system32\Macromed\Flash\'

        $x32Path = '\\' + $using:rServer + $x32partPath

        $x64partPath = '\c$\Windows\SysWOW64\Macromed\Flash\'

        $x64Path = '\\' + $using:rServer + $x64partPath
       
       
       if (Test-Path -Path $x32Path -ErrorAction SilentlyContinue){
       
        $flashItem = Get-ChildItem -Path $x32Path -Include *.ocx -Depth 1 | Select-Object -First 1

        $rFlashInfo = $flashItem.VersionInfo 

        $rFlashInfo | Select-Object -Property @{label='ServerName';expression={$using:rServer}},InternalName,FileName,FileVersionRaw,FileDescription,FileBuildPart,FilePrivatePart,FileMajorPart,FileMinorPart,Language
       
       }#end of x32test

        if (Test-Path -Path $x64Path -ErrorAction SilentlyContinue){
       
        $flashItem = Get-ChildItem -Path $x64Path -Include *.ocx -Depth 1 | Select-Object -First 1

        $rFlashInfo = $flashItem.VersionInfo 

        $rFlashInfo | Select-Object -Property @{label='ServerName';expression={$using:rServer}},InternalName,FileName,FileVersionRaw,FileDescription,FileBuildPart,FilePrivatePart,FileMajorPart,FileMinorPart,Language
       
       }#end of x64test



    }#end of Sequence

   }#End of ForEach Parallel

}#end of WorkFlow


$rServerList = @()

$rFinalServerList = @()

$currentDate = (Get-date -Format "ddMMyyyyHHmm").ToString()

#PUT THE NAME OF FOLDER TO GENERATE CSV REPORT

$folderName = 'Temp'

$outputPath = "$env:SystemDrive" + '\' + $folderName

#PUT THE NAME OF FOLDER TO GENERATE CSV REPORT

If (Test-Path $outputPath){

    Write-Host "I can record files in specified path: $outputPath" -ForegroundColor White -BackgroundColor DarkGreen

    }
else{

     Write-Host "The path: $outputPath was not found. I will create it now" -ForegroundColor White -BackgroundColor DarkRed

     New-Item -Path "$env:SystemDrive\" -ItemType Directory -Name $folderName -Force -Confirm:$false 
     

}

Do {
    
    Write-Output "

---------- MENU GET REMOTE FLASH VERSION ----------

1 = Get Flash Version from a list of Computers (Read from File List)
2 = Get Flash Version from a list of Computers (From AD Filter Consult)
3 = Exit
--------------------------------------------"

$choiceST = Read-host -prompt "Select an Option & Press Enter"

} until ($choiceST -eq "1" -or $choiceST -eq "2" -or $choiceST -eq "3")

switch ($choiceST)
{
    '1' {
    
        #CREATE FILE WITH VM INPUT LIST IF NOT EXIST
        if (Test-Path -Path "$outputPath\ServerInputList.txt"){
            
            Write-Host "File ServerInputList.txt Already Exists. If file is empty, this Script Will through an Error" -ForegroundColor White -BackgroundColor DarkYellow
            
            Pause-PSScript          
        
        }#end of IF
        else{
        
            New-Item -Path "$outputPath" -ItemType File -Name 'ServerInputList.txt' -Confirm:$true -Verbose

            Write-Host "NOW I WILL OPEN THE FILE. PLEASE PUT THE SERVERS TO BE TESTED. ATTENTION: THE FILE CAN'T HAVE BLANK SPACES"

            Pause-PSScript
                
            Start-Process -FilePath "notepad" -Wait -WindowStyle Maximized -ArgumentList "$outputPath\ServerInputList.txt"
        
            Start-Sleep -Seconds 5
             
        }#end of Else

        #READ FILE WITH SERVER LIST TO CONSULT
        $rServerList = (Get-Content -Path "$outputPath\ServerInputList.txt")

        $rServerCount = $rServerList.Count

        Write-Host "I found $rServerCount Servers today to scan..." -ForegroundColor White -BackgroundColor Green

        [System.Int64]$counterI = 0

        foreach ($rServer in $rServerList)
        {
    
            Write-Progress -Activity "Testing Servers" -Status "Progress: $rServer" -PercentComplete ($counterI/$rServerCount*100)

            $result = PS-Ping -hostname $rServer -timeout 5

             if ($result -eq 'SUCCESS'){


                $rFinalServerList += $rServer

             }
             else{
    
                Write-Host "I can't ping the server: $rServer" -ForegroundColor White -BackgroundColor Red

            }#end of Else Ping

            $counterI ++

        }#End of Foreach

        $rFinalServerListCount = $rFinalServerList.Count

        Write-Host "I can reach $rFinalServerListCount Servers today to get Flash Version..." -ForegroundColor White -BackgroundColor Green
        
        WFRemoteFlashVersion -rServerList $rFinalServerList | Export-Csv -NoTypeInformation -Path "$outputPath\ServersWithFlashPlayer-$currentDate.txt" -Encoding UTF8
        
    
    }#end of 1
    '2' {
        
        #DATE OS LAST COMMUNICATION WITH AD
        $trimDate = (Get-date).AddDays(-30)
        
        ############################## MODIFY CONSULT ACCORDING TO YOUR ENVIRONMENT ##################

        $rServerList = Get-ADComputer -SearchBase 'dc=your,dc=company,dc=local' -SearchScope Subtree -Filter {((ServicePrincipalName -notlike '*MSServerCluster*') -or 
        (ServicePrincipalName -notlike 'msclustervirtualserver*')) -and 
        (Modified -ge $trimdate) -and 
        ((OperatingSystem -Like 'Windows Server 2003*') -or (OperatingSystem -Like 'Windows Server 2008*') -or (OperatingSystem -like 'Windows Server 201*')) -and 
        (DNSHostName -notlike 'STRING1*') -and
        (DNSHostName -notlike 'STRING2*') -and 
        (DNSHostName -notlike 'STRING3*') -and
        (DNSHostName -notlike 'STRING4*') -and
        (DNSHostName -notlike 'STRING5*') -and 
        (DNSHostName -notlike 'STRING6*') -and 
        (DNSHostName -notlike 'STRING7*') -and 
        (DNSHostName -notlike 'STRING8*')}  | Where-Object -FilterScript {$PSItem.DistinguishedName -notlike "*OU=CustomPath,OU=CustomOU*"} | Select-Object -ExpandProperty Name | Sort-Object

        ############################### MODIFY CONSULT ACCORDING TO YOUR ENVIRONMENT ##################

        $rServerCount = $rServerList.Count

        Write-Host "I found $rServerCount Servers today to scan..." -ForegroundColor White -BackgroundColor Green

        [System.Int64]$counterI = 0

        foreach ($rServer in $rServerList)
        {
    
            Write-Progress -Activity "Testing Servers" -Status "Progress: $rServer" -PercentComplete ($counterI/$rServerCount*100)

            $result = PS-Ping -hostname $rServer -timeout 5

             if ($result -eq 'SUCCESS'){


                $rFinalServerList += $rServer

             }
             else{
    
                Write-Host "I can't ping the server: $rServer" -ForegroundColor White -BackgroundColor Red

            }#end of Else Ping

            $counterI ++

        }#End of Foreach

        $rFinalServerListCount = $rFinalServerList.Count

        Write-Host "I can reach $rFinalServerListCount Servers today to get Flash Version..." -ForegroundColor White -BackgroundColor Green
        
        WFRemoteFlashVersion -rServerList $rFinalServerList | Export-Csv -NoTypeInformation -Path "$outputPath\ServersWithFlashPlayer-$currentDate.csv" -Encoding UTF8
        
    
    }#end of 2
    '3' {
    
        Write-Output " "
    
        Write-Output "Finishing the Script..."
    
    }#end of 3
    
}#end of Switch

#VIEW RUNTIME SCRIPT
$scriptend = Get-Date

$scriptruntime =  $scriptend - $scriptstart

if ($scriptruntime.TotalSeconds -lt 60)
{
    
    $scriptruntimeInSeconds = $scriptruntime.TotalSeconds

    "Script was running for {0:n2} seconds " -f $scriptruntimeInSeconds

}

if ($scriptruntime.TotalSeconds -gt 60)
{
    
    $scriptruntimeInMinutes = $scriptruntime.TotalMinutes
    
    "Script was running for {0:n2} minutes " -f $scriptruntimeInMinutes

}
