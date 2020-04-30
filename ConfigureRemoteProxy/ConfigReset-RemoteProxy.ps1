#Requires -Version 3.0
#Requires -RunAsAdministrator  
<#
.Synopsis
   Reset and Configure Remote Proxy
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.AUTHOR
  Juliano Alves de Brito Ribeiro (julianoalvesbr@live.com or fixnetwork@live.com)
.VERSION
  0.3
.ENVIRONMENT
  PROD
   
#>
function ConfigReset-RemoteProxy
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.Object[]]
        $ServerList,

        [Parameter(Mandatory = $false, 
        HelpMessage="Don't set both configure proxy and reset proxy to true. Always one true and another false",
        Position = 1)]
        [Switch]
        $resetProxy = $false,

        [Parameter(Mandatory = $false, 
        HelpMessage="Don't set both configure proxy and reset proxy to true. Always one true and another false",
        Position = 2)]
        [Switch]
        $configureProxy = $false,

        [Parameter(Mandatory = $false, Position = 3)]
        [System.String]
        $proxyServer = '192.168.4.1', #PUT THE IP OF YOUR PROXY SERVER

        [Parameter(Mandatory = $false, Position = 4)]
        [System.String]
        $proxyPort = '8080' #PUT THE PORT OF YOUR PROXY SERVER


    )


    if ($resetProxy){
    
        foreach ($Server in $ServerList){
            
            Write-Host "Actual Config Proxy of Server: $Server" -ForegroundColor White -BackgroundColor Magenta

            Invoke-Command -ComputerName $Server -ScriptBlock {netsh winhttp show proxy}

            Start-Sleep -Milliseconds 300

            Write-Host "Reset Proxy of Server: $Server" -ForegroundColor White -BackgroundColor DarkGreen

            Invoke-Command -ComputerName $Server -ScriptBlock {netsh winhttp reset proxy}

            Start-Sleep -Milliseconds 300

            Write-Host "New Config Proxy of Server: $Server" -ForegroundColor White -BackgroundColor Red

            Invoke-Command -ComputerName $Server -ScriptBlock {netsh winhttp show proxy}
            

        }#End of ForEach
           
    }#End of Reset Proxy

    if ($configureProxy){
    
        foreach ($Server in $ServerList){
            
            $ProxyTotal = $proxyServer + ':' + $proxyPort

            Write-Host "Actual Config Proxy of Server: $Server" -ForegroundColor White -BackgroundColor Magenta

            Invoke-Command -ComputerName $Server -ScriptBlock {netsh winhttp show proxy}

            Start-Sleep -Milliseconds 300

            Write-Host "Configure Proxy of Server: $Server" -ForegroundColor White -BackgroundColor Magenta

            Invoke-Command -ComputerName $Server -ScriptBlock {Param($proxyTotal) netsh winhttp set proxy $proxyTotal} -ArgumentList $proxyTotal

            Start-Sleep -Milliseconds 300

            Write-Host "New Config Proxy of Server: $Server" -ForegroundColor White -BackgroundColor Red

            Invoke-Command -ComputerName $Server -ScriptBlock {netsh winhttp show proxy}

  
        }#End of ForEach
    
    }#End of Configure Proxy

}#End of Function

Clear-Host

$shortDate = (get-date -Format ddMMyyyy).ToString()

   
    do {
    [int]$userMenuChoice = 0
        Do {
            Write-Output "

---------- RESET OR CONFIGURE REMOTE PROXY ----------

Your logged in domain: $env:USERDNSDOMAIN

Today is: $shortDate

1 = Reset Remote Proxy of Single Server
2 = Reset Remote Proxy of Two or More Servers
3 = Reset Remote Proxy of a Bunch of Servers (Read from file)
4 = Configure Remote Proxy of Single Server
5 = Configure Remote Proxy of Two or More Servers
6 = Configure Remote Proxy of a Bunch of Servers (Read from file)
7 = Exit

------------------------------------------------------"

[int]$userMenuChoice = Read-host -prompt "Select an Option and Press Enter"

switch ($userMenuChoice)
{
    1 {
        
        $rServer = ""

        $rServer = Read-Host "Write Server Name"
        
        ConfigReset-RemoteProxy -ServerList $rServer -resetProxy 
    
    }#end of 1
    2 {
    
         
        $Response = 'Y'

        $rServer = $Null

        $rServerList = @()

        [System.String]$suffix = $env:USERDNSDOMAIN

       

Do 
    { 
            $tmprServer = Read-Host 'Please type a Server Name'
            
            $rServer = $tmprServer + '.' + $suffix
            
            $Response = Read-Host 'Would you like to add additional Servers to this list? (y/n)'
            
            $rServerList += $rServer

    }#end of DO
Until ($Response -eq 'n')#end of Until
    
           ConfigReset-RemoteProxy -ServerList $rServerList -resetProxy 

    
    }#end of 2
    3 {
        
        #CHANGE THE PATH TO YOUR SERVER LIST
        $rServerList = (Get-Content -Path "$env:SystemDrive\Scripts\Box\Input\Windows\Proxy\ServerList.txt")

    if (!($rServerList)){

        Write-Host "Empty List. Nothing to do here" -ForegroundColor White -BackgroundColor Red

    }#End of IF
    else{
    
        ConfigReset-RemoteProxy -ServerList $rServerList -resetProxy
    
    }#end of Else
    
    
    }#end of 3
    4{
    
        $rServer = ""

        $rServer = Read-Host "Write Server Name"
            
        ConfigReset-RemoteProxy -ServerList $rServer -configureProxy


    }#end of 4
    5{
    
          $Response = 'Y'

        $rServer = $Null

        $rServerList = @()

        [System.String]$suffix = $env:USERDNSDOMAIN

       

Do 
    { 
            $tmprServer = Read-Host 'Please type a Server Name'
            
            $rServer = $tmprServer + '.' + $suffix
            
            $Response = Read-Host 'Would you like to add additional Servers to this list? (y/n)'
            
            $rServerList += $rServer

    }#end of DO
Until ($Response -eq 'n')#end of Until
    
           ConfigReset-RemoteProxy -ServerList $rServerList -configureProxy


    }#end of 5
    6{
    
        #CHANGE THE PATH TO YOUR SERVER LIST
        $rServerList = (Get-Content -Path "$env:SystemDrive\Scripts\Box\Input\Windows\Proxy\ServerList.txt")

    if (!($rServerList)){

        Write-Host "Empty List. Nothing to do here" -ForegroundColor White -BackgroundColor Red

    }#End of IF
    else{
    
        ConfigReset-RemoteProxy -ServerList $rServerList -configureProxy
    
    }#end of Else



    }#end of 6
    7{
    
        Write-Output "You choose finish the Script"
    
        Start-Sleep -Seconds 2
    
        Exit
    
    }#end of 7
}#end of switch


}until ($userMenuChoice -lt 1 -or $userMenuChoice -gt 7)


}while ($userMenuChoice -ne 7)
