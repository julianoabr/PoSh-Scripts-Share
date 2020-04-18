#Requires -Version 5.0
#Requires -RunAsAdministrator   

<#
.Synopsis
   Script para definir o tipo de sincronismo em servidores remotos
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
. TO THINK
  A origem da vida não pode ter ocorrido por meio de um processo gradual, mas instantâneo [pois] toda máquina precisa ter um número correto de partes para funcionar...Até mesmo a bactéria requer milhares de genes
  para executar para executarem as funções necessárias à vida...A espécie mais simples de bactéria, Clamídia e Rickéttsia [que são] tão pequenas quanto possível para ainda serem um ser vivo..requerem milhões de partes 
  atômicas...Todas as inúmeras macromoléculas necessárias para a vida são construídas a partir de átomos...compostos de partes ainda menores...e a única discussão é sobre como inúmeroas milhões de partes funcionalmente integradas são necessárias...
  De maneira muito simples, a vida depende de um arranjo complexo de três classes de moléculas: DNA, que armazena o planejamento completo; RNA, que transporta uma cópia da informação contida no DNA para a estação de montagem de proteína; e as proteínas,
  que compõe tudo desde os ribossomos até as enzimas.
  Além disso, chaperonas e muitas outras ferramentas de montagem são necessárias para garantir que a proteína será corretamente montada. Todas estas partes são necessárias e precisam existir como uma unidade propriamente montada e integrada...
  As partes não poderiam evoluir separadamente e não poderiam existir independentemente por muito tempo, pois elas se decomporiam no ambiente sem proteção...
  Por este motivo, somente uma criação instantânea de todas as partes necessárias de uma unidade em funcionamento poderia produzir vida.
  Nenhum dispositivo convincente já foi apresentado que refute esta conclusão é há muita evidência em favor da exigência de uma criação instantânea...Uma célula só pode vir através de uma célula em funcionamento e não pode ser construída de maneira fragmentada...
  Para existir como organismo vivo, o corpo humano precisa ter sido criado completo. 1

  1. Bergman, In Six Days, 15-21

.AUTHOR
  Juliano Alves de Brito Ribeiro (jaribeiro@uoldiveo.com or julianoalvesbr@live.com)
.VERSION
  0.4
.ENVIRONMENT
  DEV
#>

Clear-Host

Set-Location "$env:SystemDrive\Scripts\Box\Process\Windows\DateTime\Set-SyncType"

#MAIN VARIABLES

$tmpLocation = Get-Location

$location = $tmpLocation.Path

$Script:outputPath = $location + "\SyncTypeReport\"

#Validate Path
if (Test-Path -Path $Script:outputPath){

Write-Output "The Path to Report Exists. Let's Go"

}else{

Write-Output "The Path to Report Does Not Exists. Let's Create"

New-Item -Path .\ -ItemType Directory -Name "SyncTypeReport" -Force -Verbose

}

$dataAtual = (Get-Date -Format ddMMyyyy)

$completeDate = (Get-Date -Format ddMMyyyyHHmm)

$trimDate = (Get-date).AddDays(-30)

#$ServerList = Get-ADComputer -Filter {ServicePrincipalName -notlike 'msclustervirtualserver*' -and  Modified -ge $trimdate -and OperatingSystem -Like 'Windows Server*' -and DNSHostName -notlike 'UBSN*' -and DNSHostName -notlike 'NOSERVERNAME*' -and DNSHostName -notlike 'NODCNAME*' -and DNSHostName -notlike 'NODCNAME2*'}  | Select-Object -ExpandProperty DNSHostName | Sort-Object -Descending
#$NumberOfComputersinADLA = $ServerList.Count

$ServerList = @()

$ServerName = ""

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


#FUNCTION TO PAUSE SCRIPT
function Pause-PSScript
{

   Read-Host 'Pressione [ENTER] para continuar' | Out-Null

}

#VALIDATE REMOTE WMI
function Validate-RemoteWMI
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String]$ServerName

      
    )
      
    try {

    $wmiR = $true

    Write-Host "Checking connectivity to $ServerName" -ForegroundColor Blue -BackgroundColor White

    Get-WmiObject -Class Win32_Bios -ComputerName $ServerName -ErrorAction Stop | Out-Null
}
catch {

    Write-Warning "$ServerName failed to connect"

    $wmiR = $false

    Continue
}
return $wmiR


}#end of Function


#CHANGE SYNC TYPE ON REMOTE COMPUTERS
function Set-SyncTypeRemote
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.Object[]]$Computer,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [System.String]$SyncType,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [System.String]$manualPeerList = 'server1.local,server2.local'
    )

    Begin
    {

    Write-Host "Start of Config in computer: $Computer" -BackgroundColor White -ForegroundColor Red
    
    If ($SyncType -eq 'NT5DS'){
    
        #This sets that the value in the registry to NT5DS and notifies the W32Time service that settings have changed
        Invoke-Command -ComputerName $Computer -ScriptBlock {w32tm /config /syncfromflags:domhier /update} -Verbose -ErrorAction Continue
    
        Start-Sleep -Seconds 1 -Verbose

    }#end of IF
    Elseif ($SyncType -eq 'AllSync'){
    
        Invoke-Command -ComputerName $Computer -ScriptBlock {Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Parameters' -Name Type -Value 'AllSync'}
    
    }#end of First Elseif
    Elseif ($SyncType -eq 'NoSync'){
    
        Invoke-Command -ComputerName $Computer -ScriptBlock {Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\w32time\Parameters' -Name Type -Value 'NoSync'}
    
    }#End of Seconf ElseIf
    Else{
    
        #This will modify the value in the registry to NTP.
        #Note: if you are using a DNS name for the time server, it is important to add the 0x1 to the end. If using and IP address this is not required
        Invoke-Command -ComputerName $Computer -ScriptBlock {param($rManualPeerList)W32tm /config /syncfromflags:manual /manualpeerlist:$rManualPeerList /reliable:yes /update} -ArgumentList $manualPeerList
    
        }#End of Else NTC

       

    }#END OF BEGIN
    Process
    {

       #Verify if Service is Disabled
       $serviceStartypeType = Get-Service -ComputerName $Computer -Name W32Time | Select-Object -ExpandProperty StartType
       If ($serviceStartypeType -eq "Disabled"){
       
            Get-service -ComputerName $Computer -Name w32time | Set-Service -StartupType Automatic -Verbose

            Get-service -ComputerName $Computer -Name w32time | Start-Service -Verbose
              
       }#end of IF StartType

    #After change Stop and Start w32time
    
      
    #STOP SERVICE
    $counter = 1
  
    do {
        
       Write-Host "Tentativa: $counter de parar o serviço" -BackgroundColor Cyan  -ForegroundColor White

       $serviceState = Get-Service -ComputerName $Computer -Name "W32Time" | Select-Object -ExpandProperty Status 
       
       if ($serviceState -eq 'Stopped'){
       
        Write-Output "The Service W32Time is already Stopped on $Computer"

       }else{
       
       Get-Service -ComputerName $Computer -Name "W32Time" | Stop-Service -Verbose

       Start-Sleep -Seconds 3 -Verbose
              
       }

       $counter ++
       

      }while(($serviceState -notlike 'Stopped') -xor ($counter -gt 6))
      
    #START SERVICE
    $counter = 1
  
    do {
        
       Write-Host "Tentativa: $counter de iniciar o serviço" -BackgroundColor White -ForegroundColor DarkCyan
        
       $serviceState = Get-Service -ComputerName $Computer -Name "W32Time" | Select-Object -ExpandProperty Status 

       Get-Service -ComputerName $Computer -Name "W32Time" | Start-Service -Verbose

       Start-Sleep -Seconds 3 -Verbose
       
       $counter ++

      }while (($serviceState -notlike 'Running') -xor ($counter -gt 6))
    
    #The system should then update its time with the following command:
        w32tm /resync /computer:$Computer

        Start-Sleep -Seconds 2 -Verbose
    
    }#END OF PROCESS
    End
    {

    Write-Host "End of Config in computer: $Computer" -BackgroundColor White -ForegroundColor Red

    }#END OF END
}#end of Function Set-SyncTypeRemote

function Save-TimeConfig
{
    [CmdletBinding()]
    Param
   (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String[]]$ServerList,
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [ValidateSet("Before","After")]
        [System.String]$StateConfig,

        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [System.String]$dcToCompare = 'server.local'
      
    )


 if ($StateConfig -eq "Before"){
 
     foreach ($Server in $ServerList)
        {
        
        $wmiResult = Validate-RemoteWMI -ServerName $ServerName
        
        #Validate connection to WMI
        if ($wmiResult -ne $null){
                         
            $osBuild = ""
        
            $osCaption = ""
        
            $osBuild =  (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).BuildNumber
        
            $osCaption = (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).Caption
                
            #IF ELSE IF ELSE STATEMENT TO VALIDATE OS VERSION
            if ($osBuild -ge 9600){

               #SAVE CONFIG BEFORE CHANGES
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /status} | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
    
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /source} | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
    
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /configuration} | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
           
               Invoke-Command -ComputerName $Server -ScriptBlock {param($rDcToCompare)w32tm /stripchart /computer:$rDCToCompare /dataonly /samples:3} -ArgumentList $dcToCompare | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

               #Create CIM SESSION 
               $tmpSession = New-CimSession -ComputerName $Server

               Get-CimInstance –CimSession $tmpSession –ClassName Win32_TimeZone | Select-Object -Property Caption,Bias,DaylightBias,DaylightName,StandardName | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
                    
               #Save Hour Before Change
               Get-CimInstance –CimSession $tmpSession -ClassName Win32_OperatingSystem | Select-Object -Property CSName,CurrentTimeZone,LocalDateTime | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
           
               #REMOVE CIM SESSION
               $tmpSession | Remove-CimSession

            }#end of IF Build Version
            elseif ($osBuild -ge 3790){
          
              Invoke-Command -ComputerName $Server -ScriptBlock {Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\W32Time\Config'} -ErrorAction SilentlyContinue | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append    
          
              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
                          
              Invoke-Command -ComputerName $Server -ScriptBlock {Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\W32Time\Parameters'} -ErrorAction SilentlyContinue | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append    

              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

              Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /tz} | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
          
              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append

              Invoke-Command -ComputerName $Server -ScriptBlock {param($rDcToCompare)w32tm /stripchart /computer:$rDCToCompare /dataonly /samples:3} -ArgumentList $dcToCompare  | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
          
              #Save Current Hour Before Change
              Get-WmiObject -ComputerName $Server -Class Win32_OperatingSystem | Select-Object -Property @{label='Computername';Expression={$_.CSName}},@{LABEL='LocalDateTime';EXPRESSION={$_.ConverttoDateTime($_.LocalDateTime)}} | Out-File -FilePath "$outputPath\NTC-Before-$Server-$completeDate.txt" -Append
                        
        }#end of ELSEIF STATEMENT
        else{
        
            Write-Output "The Server $Server has Windows Version: $osCaption and the script can't run on it"

            Write-Output "Please Verify Manually"
        
        }#end of Else 

               
                           
                  
               }#end of IF validate WMI
        else{
        
           Write-Host "Failed to Connect to $serverName" -ForegroundColor Red -BackgroundColor White 
        
           Write-Output "Error to connect to $ServerName. Verify WMI" | Out-file -FilePath "$Script:OutputPath\Error-Validate-WMI-$dataAtual.txt" -Append

        }#End of Else Validate WMI
      

    }#end ForEach
 
 }#End of BEFORE

if ($StateConfig -eq "After"){

     foreach ($Server in $ServerList)
     {
        
        $wmiResult = Validate-RemoteWMI -ServerName $ServerName
        
        #Validate connection to WMI
        if ($wmiResult -ne $null){
                    
               
            $osBuild = ""
        
            $osCaption = ""
        
            $osBuild =  (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).BuildNumber
        
            $osCaption = (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).Caption
                
            #IF ELSE IF ELSE STATEMENT TO VALIDATE OS VERSION
            if ($osBuild -ge 9600){

               #SAVE CONFIG BEFORE CHANGES
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /status} | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
    
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /source} | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
    
               Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /query /configuration} | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
           
               Invoke-Command -ComputerName $Server -ScriptBlock {param($rDcToCompare)w32tm /stripchart /computer:$rDCToCompare /dataonly /samples:3} -ArgumentList $dcToCompare | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

               #Create CIM SESSION 
               $tmpSession = New-CimSession -ComputerName $Server

               Get-CimInstance –CimSession $tmpSession –ClassName Win32_TimeZone | Select-Object -Property Caption,Bias,DaylightBias,DaylightName,StandardName | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

               Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
                    
               #Save Hour Before Change
               Get-CimInstance –CimSession $tmpSession -ClassName Win32_OperatingSystem | Select-Object -Property CSName,CurrentTimeZone,LocalDateTime | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
           
               #REMOVE CIM SESSION
               $tmpSession | Remove-CimSession

            }#end of IF Build Version
            elseif ($osBuild -ge 3790){
          
              Invoke-Command -ComputerName $Server -ScriptBlock {Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\W32Time\Config'} -ErrorAction SilentlyContinue | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append    
          
              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
                          
              Invoke-Command -ComputerName $Server -ScriptBlock {Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Services\W32Time\Parameters'} -ErrorAction SilentlyContinue | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append    

              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

              Invoke-Command -ComputerName $Server -ScriptBlock {w32tm /tz} | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
          
              Write-Output "`n" | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append

              Invoke-Command -ComputerName $Server -ScriptBlock {param($rDcToCompare)w32tm /stripchart /computer:$rDCToCompare /dataonly /samples:3} -ArgumentList $dcToCompare | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
          
              #Save Current Hour Before Change
              Get-WmiObject -ComputerName $Server -Class Win32_OperatingSystem | Select-Object -Property @{label='Computername';Expression={$_.CSName}},@{LABEL='LocalDateTime';EXPRESSION={$_.ConverttoDateTime($_.LocalDateTime)}} | Out-File -FilePath "$outputPath\NTC-After-$Server-$completeDate.txt" -Append
                        
        }#end of ELSEIF STATEMENT
        else{
        
            Write-Output "The Server $Server has Windows Version: $osCaption and the script can't run on it"

            Write-Output "Please Verify Manually"
        
        }#end of Else 

               
                           
                  
               }#end of IF validate WMI
        else{
        
           Write-Host "Failed to Connect to $serverName" -ForegroundColor Red -BackgroundColor White 
        
           Write-Output "Error to connect to $ServerName. Verify WMI" | Out-file -FilePath "$Script:OutputPath\Error-Validate-WMI-$dataAtual.txt" -Append

        }#End of Else Validate WMI
      

    }#end ForEach


    }#END OF AFTER

}#end of Function Save-TimeConfig

function Set-RegFileRemoteComputer
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String]$Server
      
    )

        $pathRemoteReg = ""

        $fileName = ""

        $remoteFileReg = ""
        
        $osBuild = ""
        
        $osCaption = ""
        
        $osBuild =  (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).Version
        
        $osCaption = (Get-WmiObject -ComputerName $Server -Class win32_operatingsystem).Caption

        #IF ELSE IF ELSE STATEMENT TO VALIDATE OS VERSION
        if ($osBuild -ge 6.0){

            #Windows 2008 or Superior Reg File
            $pathRemoteReg = '\\server\path\path2\path3\'

            $fileName = 'Hv_2019_2008R2.reg'

            $remoteFileReg = $pathRemoteReg + $fileName
        
            Write-Output "The Server $Server has Windows Version: $osCaption and the script can run on it"
        
            $targetComputer = "\\$Server\c$\temp"


            if (Test-Path $targetComputer){
        
                Write-Output "O caminho remoto existe no server $server. Copiarei o arquivo de registro para lá"

                Set-Location $pathRemoteReg -Verbose

                Get-ChildItem -File $fileName | ForEach-Object {Copy-Item $_.FullName -Destination (("$targetComputer\") + $_.Name) -Force -Verbose}

                Invoke-Command -ComputerName $server -ScriptBlock {Start-Process -filepath "C:\windows\regedit.exe" -argumentlist "/s C:\Temp\Hv_2019_2008R2.reg"} -Verbose

                

                        
            }#end IF
            else{
        
                Write-Output "O caminho remoto não existe no server $server. Criarei a pasta e copiarei o arquivo de registro para lá"

                New-Item -Path "\\$server\c$\" -ItemType Directory -Name "Temp" -Force -Verbose -ErrorAction Continue
            
                Set-Location $pathRemoteReg -Verbose

                Get-ChildItem -File $fileName | ForEach-Object {Copy-Item $_.FullName -Destination (("$targetComputer\") + $_.Name) -Force -Verbose} 

                Invoke-Command -ComputerName $server -ScriptBlock {Start-Process -filepath "C:\windows\regedit.exe" -argumentlist "/s C:\Temp\Hv_2019_2008R2.reg"} -Verbose
            
             }#end Else


        }#end of IF Build Version
        elseif ($osBuild -ge 5.2){
                
                #Windows 2003 or Superior Reg File
                $pathRemoteReg = '\\cl_psrepo_fs\NeoTools\MSFT\REG\HV2K19\2003R2\'

                $fileName = 'HV_2019_2003R2.reg'

                $remoteFileReg = $pathRemoteReg + $fileName
        
                Write-Output "The Server $Server has Windows Version: $osCaption and the script can run on it"
                
                $targetComputer = "\\$server\c$\temp"


                if (Test-Path $targetComputer){
        
                    Write-Output "O caminho remoto existe no server $server. Copiarei o arquivo de registro para lá"

                    Set-Location $pathRemoteReg -Verbose

                    Get-ChildItem -File $fileName | ForEach-Object {Copy-Item $_.FullName -Destination (("$targetComputer\") + $_.Name) -Force -Verbose}

                    Invoke-Command -ComputerName $server -ScriptBlock {Start-Process -filepath "C:\windows\regedit.exe" -argumentlist "/s C:\Temp\HV_2019_2003R2.reg"} -Verbose

               }#end IF
                else{
        
                    Write-Output "O caminho remoto não existe no server $server. Criarei a pasta e copiarei o arquivo de registro para lá"

                    New-Item -Path "\\$server\c$\" -ItemType Directory -Name "Temp" -Force -Verbose -ErrorAction Continue
            
                    Set-Location $pathRemoteReg -Verbose

                    Get-ChildItem -File $fileName | ForEach-Object {Copy-Item $_.FullName -Destination (("$targetComputer\") + $_.Name) -Force -Verbose} 

                    Invoke-Command -ComputerName $server -ScriptBlock {Start-Process -filepath "C:\windows\regedit.exe" -argumentlist "/s C:\Temp\HV_2019_2003R2.reg"} -Verbose
            
              }#end Else

                        
        }#end of ELSEIF STATEMENT
        else{
        
        
            Write-Output "The Server $Server has Windows Version: $osCaption and the script can't run on it"

            Write-Output "Please Verify Manually"
        
        }#end of Else    
    
    Set-location "$env:SystemDrive\" -Verbose

    Write-Host "Reg File Imported to Server $Server . Doing in the next" -ForegroundColor Red -BackgroundColor White
    

}#end of Function Set-RegFileRemoteComputer

do
{
  
  Write-host "Deseja Alterar o Sync Type (1) ou Aplicar a Chave de Registro do Horário de Verão (2)? " -ForegroundColor Yellow -BackgroundColor Black
  
  Write-Output "`n"

    $ActionChoice = Read-Host " Digite ( 1 ou 2 ) " 
    
    Switch ($ActionChoice) 
     { 
       "1"{
       
        #CREATE Type List
        $w32TmSyncTypeList = @();
        $w32TmSyncTypeList = ("NoSync","NTP","NT5DS","AllSync")

        $workingSyncTypeNum = ""
        $tmpWorkingSyncTypeNum = ""
        $WorkingSyncType = ""
        $i = 0

#MENU SELECT SYNC TYPE
foreach ($SyncType in $w32TmSyncTypeList){
	   
        $TypeValue = $SyncType
	    
        Write-Output "            [$i].- $TypeValue ";	
	    $i++	
        }#end foreach	
        Write-Output "            [$i].- Exit this script ";

        while(!(isNumeric($tmpWorkingSyncTypeNum)) ){
	        $tmpWorkingSyncTypeNum = Read-Host "Select The Number of Sync Type That You Want to Apply"
        }#end of while

            $workingSyncTypeNum = ($tmpWorkingSyncTypeNum / 1)

        if(($workingSyncTypeNum -ge 0) -and ($WorkingSyncTypeNum -le ($i-1))  ){
	        $WorkingSyncType = $w32TmSyncTypeList[$workingSyncTypeNum]
        }
        else{
            
            Write-Host "Exit selected, or Invalid choice number. End of Script " -ForegroundColor Red -BackgroundColor White
            
            Exit;
        }#end of else

        Do {
    
    Write-Output "

---------- MENU SET SYNC TYPE ON REMOTE COMPUTERS ----------

Sync Time That will be applied: $WorkingSyncType

1 = Set Sync Type in a Single Computer
2 = Set Sync Type in two or more Computers
3 = Set Sync Type in two or more Computers (Read from File List)
4 = Disable Time Synchronization in Hyper-V VMs
5 = Generate File With Time Config of Servers
6 = Exit

--------------------------------------------"

$choiceST = Read-host -prompt "Select an Option & Press Enter"
} until ($choiceST -eq "1" -or $choiceST -eq "2" -or $choiceST -eq "3" -or $choiceST -eq "4" -eq $choiceST -eq "5" -or $choiceST -eq "6")

switch ($choiceST)
{
    1 {
    
    $ServerName = Read-Host "Digite o Nome do Servidor que deseja alterar o Sync Type para: $workingSyncType"
    
    #Validate Ping to Server
    $result = Ping $ServerName -timeout 100
    
    if ($result -eq "SUCCESS") { 
       
       Save-TimeConfig -ServerList $ServerName -StateConfig "Before"
        
       Set-SyncTypeRemote -Computer $ServerName -SyncType $WorkingSyncType -Verbose

       Save-TimeConfig -ServerList $ServerName -StateConfig "After"

     }#end of If
    else { 

      Write-Output "Sorry. I can't connect to $ServerName"  

    }#end of Else
    
    
}#end of 1
    2 {
    
    $Response = 'Y'
    $ServerName = $Null
    $Serverlist = @()
    
        Do 
            { 
            $ServerName = Read-Host 'Please type a server name that you want to change the Sync Type.'
            
            $Response = Read-Host 'Would you like to add additional servers to this list? (y/n)'
            
            $Serverlist += $ServerName
            }
       Until ($Response -eq 'n')

    foreach ($ServerName in $Serverlist){
    
        #Validate Ping to Server
        $result = Ping $ServerName -timeout 30
    
        if ($result -eq "SUCCESS") { 
            
            Save-TimeConfig -ServerList $ServerName -StateConfig "Before"

            Set-SyncTypeRemote -Computer $ServerName -SyncType $WorkingSyncType 

            Save-TimeConfig -ServerList $ServerName -StateConfig "After"

        }#end of If
        else { 

        Write-Output "Sorry. I can't connect to $ServerName"  

        }#end of Else
        
        Start-Sleep -Seconds 2
              
    
    }#end ForEach

}#end of 2
    3 {

    $ServerList = (Get-Content -Path "$env:SystemDrive\YourLocalPath\WindowsSyncTypeComputerList.txt")

    foreach ($ServerName in $ServerList){
       
        $result = Ping $ServerName 100
	
            if ($result -ne "Success"){ 

                Write-Host "Ping Error - $ServerName" -ForegroundColor Red -BackgroundColor White   

                Write-Output "Ping Error - $ServerName" | Out-File -FilePath "$outputPath\Error-Validate-Ping-$dataAtual.txt" -Append
      
        }#end of IF PING
        else { 
    
        Write-Output "Ping successfully - $ServerName"

        #VALIDE WMI CONNECTION
        try
        {
            $wmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ServerName -ErrorAction SilentlyContinue
        }
        catch 
        {
            $wmi = $null
        }

        # Perform WMI related checks
    if ($null -ne $wmi){
      
        Write-Output "WMI connection Ok: $ServerName "
    
        Save-TimeConfig -ServerList $ServerName -StateConfig "Before"

        Set-SyncTypeRemote -Computer $ServerName -SyncType $WorkingSyncType

        Save-TimeConfig -ServerList $ServerName -StateConfig "After"
        
        }#end of if wmi try catch
    else
        { 
    
            Write-Output "WMI connection failed to Computer $ServerName - Check WMI" | Out-file -FilePath "$outputPath\Error-Validate-WMI-$dataAtual.txt" -Append
      
        }#end Else wmi try catch

    }#end of Else PING
    
}#end Foreach computer
   

}#end of 3
    4 {
    
  
    if ((Get-module -Name virtualmachinemanager -ErrorAction SilentlyContinue) -eq $null){

    try
    {
        Import-Module -Name virtualmachinemanager -ErrorAction Stop -WarningAction Continue
    }#try
    catch 
    {
        Write-Host "The Module VirtualMachineManager could not be imported. Install SCVMM Management console first" -BackgroundColor Red -ForegroundColor White
        
    }#catch
   

}#end of IF
else{

    Write-Output "I found VirtualMachineManager Module. This is OK"
}

    $SCVMMListVMs = Get-VMMServer -ComputerName 'yourVMMServer' | Get-SCVMHostCluster -Name 'yourVMMCluster' | Get-SCVMHost | Get-VM | Select-Object -ExpandProperty Name
    
    $vmmListVMs = @()

    foreach ($vmmVM in $SCVMMListVMs){
    
        $tmpNameforList = Get-SCVirtualMachine -Name $vmmVM | Where-Object -FilterScript {$PSItem.TimeSynchronizationEnabled -eq $true} | Select-Object -ExpandProperty Name 

        if (!($tmpNameforList)){
        
            Write-Output "VM $vmmVM does not has time sync enabled with hyper-v server"
        
        }#end of IF
        else{
        
            Write-Output "VM $vmmVM has time sync enabled with hyper-v server"  
            
            $vmmListVMs += $vmmVM  
        
        }
        
    
    } 



    #GET FROM FILE
    #$scvmmListVMs = (Get-content -Path "$env:SystemDrive\Scripts\Box\Input\Windows\SyncType\scvmmVMsList.txt")

    Foreach ($scvmmVM in $vmmListVMs){
    
        Read-SCVirtualMachine -VM $scvmmVM -Verbose
    
        Get-SCVirtualMachine -Name $scvmmVM | Set-SCVirtualMachine -EnableTimeSync $False -Verbose
    
        Get-SCVirtualMachine -Name $scvmmVM | Set-SCVirtualMachine -EnableTimeSync $False | Format-Table -AutoSize VMHost,Name,TimeSynchronizationEnabled,MostRecentTaskIfLocal | Out-File -FilePath "$outputPath\SCVMM-SYNC-List-Disabled-$dataAtual.txt" -Append

        Save-TimeConfig -ServerList $scvmmVM -StateConfig "Before"
        
        Set-SyncTypeRemote -Computer $scvmmVM  -SyncType $WorkingSyncType

        Save-TimeConfig -ServerList $scvmmVM -StateConfig "After" 
    }



   
    
    }#end of 4
    5 {
    
     $ServerList = (Get-Content -Path "$env:SystemDrive\YourPath\WindowsSyncTypeComputerList.txt")

        foreach ($ServerName in $Serverlist){
    
        #Validate Ping to Server
        $result = Ping $ServerName -timeout 30
    
        if ($result -eq "SUCCESS") { 
            
            Save-TimeConfig -ServerList $ServerName -StateConfig "After"

            }#end of If
            else { 

        Write-Output "Sorry. I can't connect to $ServerName"  

        }#end of Else
        
        Start-Sleep -Seconds 2
              
    
    }#end ForEach

    
        
    }#end of 5
    6 {
    
    
    Write-Output " "
    
    Write-Output "Finishing the Script..."
    
    Exit
    
    }#end of 6

}#end of Switch



       
       }#End of 1

       "2"{
       
        Do {
    
    Write-Output "

---------- MENU SET SYNC TYPE ON REMOTE COMPUTERS ----------

Actions to Do:

1 = Correct Corrupted W32Time on a Single Computer
2 = Apply Reg File (Daylight Saving 2019) (Read from File List) - For Windows 2003 / 2008 R2 or Superior
3 = Exit

--------------------------------------------"

$choiceST = Read-host -prompt "Select an Option & Press Enter"
} until ($choiceST -eq "1" -or $choiceST -eq "2" -or $choiceST -eq "3")

switch ($choiceST)
{
    1 {
    
        #Corrupted Time Service Resolution Section (Contingency)
        Write-Output "Correct W32TIME in One Single Machine"

        $ServerName = Read-Host "Digite o Nome do Servidor que deseja corrigir o W32TIME"

        #Validate Ping to Server
        $result = Ping $ServerName -timeout 100
    
        if ($result -eq "SUCCESS") { 
    
        #STOP SERVICE
        do {
        
            $serviceState = Get-Service -ComputerName $Computer -Name "W32Time" | Select-Object -ExpandProperty Status 

            Get-Service -ComputerName $Computer -Name "W32Time" | Stop-Service -Verbose

            Start-Sleep -Seconds 5

        }while ($serviceState -ne "Stopped")

        Invoke-Command -ComputerName $ServerName -ScriptBlock {w32tm /unregister}

        Start-Sleep -Seconds 3 -Verbose

        Invoke-Command -ComputerName $ServerName -ScriptBlock {w32tm /register}

        #START SERVICE
        do {
      
        $serviceState = Get-Service -ComputerName $Computer -Name "W32Time" | Select-Object -ExpandProperty Status 

        Get-Service -ComputerName $Computer -Name "W32Time" | Start-Service -Verbose

        Start-Sleep -Seconds 5

        }while ($serviceState -ne "Running")
       

     }#end of If
    else { 

      Write-Output "Sorry. I can't connect to $ServerName"  

  }#end of Else


    
    }#End of 1
    2 {
    
     $ServerList = (Get-Content -Path "$env:SystemDrive\Scripts\Box\Input\Windows\SyncType\WindowsSyncTypeComputerList.txt")

     $errorFile = "$env:SystemDrive\Scripts\Box\Output\Windows\Registry\SyncType\Error-List-$completeDate.txt"
    
     foreach ($ServerName in $Serverlist){
    
        #Validate Ping to Server
        $result = Ping $ServerName -timeout 30
    
        if ($result -eq "SUCCESS") { 
            
            Save-TimeConfig -ServerList $ServerName -StateConfig "Before"

            Set-RegFileRemoteComputer -Server $ServerName -ErrorAction Continue

            Save-TimeConfig -ServerList $ServerName -StateConfig "After"

            

        }#end of If
        else { 

        Write-Output "Sorry. I can't connect to $ServerName. Please Do the Job Manually"  | Out-File -FilePath $errorFile -Append

        }#end of Else
        
        Start-Sleep -Milliseconds 300
              
    
    }#end ForEach


    Clear-Host

    Set-Location "$env:SystemDrive\Scripts\Box\Process\Windows\DateTime\Set-SyncType" -Verbose 

    
    }#End of 2
    3 {
    
        Write-Output " "
    
        Write-Output "Finishing the Script..."

    }#End of 3
    
}#end of Switch

       
       }#end of 2

}#end of Main Switch
    
}
while ($ActionChoice -notmatch ('^(?:1\b|2\b)'))