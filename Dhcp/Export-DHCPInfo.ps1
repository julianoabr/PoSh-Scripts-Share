#Requires -Version 5.0
#Requires -RunAsAdministrator
<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
.AUTHOR
  Juliano Alves de Brito Ribeiro (Find me at jaribeiro@uoldiveo.com or julianoalvesbr@live.com or https://github.com/julianoabr)
.VERSION
  0.2
.TO THINK
  Qualquer teoria que tente explicar a origem do universo será sempre uma teoria e não uma afirmação irrefutável.
  Por exemplo: A teoria do Big Bang propõe uma explicação lógica para a origem do universo e para a complexidade que nele encontramos. 
  Embora seja uma teoria amplamente aceita e considerada por muitos como a teoria mais abrangente e precisa, apoiada por evidência científica e observações, ela não é uma afirmação - muito menos uma afirmação irrefutável.
  Não existe uma única explicação aceitável, dentro da teoria do Big Bang que possa explicar racionalmente como o universo teria vindo à existência a partir de um estado totalmente caótico e desorganizado.
  Uma das poucas explicações que procuram oferecer algo racional aparece no livro de Stephen Hawking, O universo numa casca de noz: "Era de Planck. Leis da física estranhas e desconhecidas" (1)
  Por que Hawking usou essa terminologia?
  Porque as leis físicas conhecidas, comoas as leis da termodinâmica e outras, afirmam categoricamente que o universo não poderia ter vindo à existência como a teoria do Big Bang propõe.
  Segundo essas leis conhecidas, todos os sistemas encontrados na natureza, naturalmente irão de um estado maior de organização para um estado menor de organização, à medida que o tempo passar.
  Não existe uma lei que demonstre que, naturalmente, um sistema possa caminhar na direção oposta, ou seja, do desorganizado para o organizado.
  O que Hawking e os demais cosmólogos atuais propõem é nada mais que um milagre. 
  Observe que, a definição que temos para milagres é: leis físicas estranhas e desconhecidas. 
  
  (1). Stephen Hawking. O Universo numa Casca de Noz. (Editora Mandarim, 2001). p. 78.      
 
    

#>
Clear-Host

function Export-RemoteDHCPScopes
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [System.String[]]$dhcpServerList,

        #Param help description
        [switch]
        $csvReport,

        [switch]
        $gridReport,

        [switch]
        $txtReport
        
    )

[System.String]$featureName = 'DHCP'

$rDhcpServerList = @()
 
foreach ($dhcpServer in $dhcpServerList){
        
        [int]$rPSVersion = Invoke-Command -ComputerName $dhcpServer -ScriptBlock {$PSVersionTable.PSVersion.Major}

    #Validate Powershell Version
    if ($rPSVersion -eq 2)
        {
         
         $rModuleName = 'ServerManager'

         $rFeatureName = 'DHCP'
         
         $rSession = New-PSSession -ComputerName $dhcpServer      

         Invoke-Command -Session $rSession -ScriptBlock{Param($xModuleName) Import-Module -Name $xModuleName} -ArgumentList $rModuleName

         $rDHCPFeature = Invoke-Command -Session $rSession -ScriptBlock{Param($xFeatureName)Get-WindowsFeature -Name $xFeatureName} -ArgumentList $rFeatureName

         if ($rDHCPFeature.Installed -eq $true){
         
            $rDhcpServerList += $dhcpServer
         
         }
         else{
         
            Write-Host "I didn't find $rFeatureName on Server $dhcpServer" -ForegroundColor White -BackgroundColor Red
            
         }

         $rSession | Remove-PSSession

    }#End of IF
    elseif($rPSVersion -gt 2){
    
           if ((Get-WindowsFeature -ComputerName $dhcpServer -Name $featureName).Installed) { 
        
        $rDhcpServerList += $dhcpServer
    } 
    
    }#End of ElseIF
    else{
    
        Write-Host "I can't Deal with this version of Powershell"
    
    }#End of Else


}#end of ForEach

$ListofScopesandTheirOptions = $Null

foreach ($rDhcpServer in $rDhcpServerList)
{
    
    $rScopes = Get-DhcpServerv4Scope -ComputerName $rDhcpServer
    
    $rActiveScopes = $rScopes | Where-Object -FilterScript {$psItem.state -eq 'Active'}
    
    foreach ($rScope in $rScopes)
    {
        
        $rScope | Select-Object -Property @{label='DhcpServerName';expression={$rDhcpServer}},Name,ScopeID,SubnetMask,State,StartRange,EndRange,Delay,LeaseDuration,MaxBootpClients,NapEnable | Export-Csv -NoTypeInformation -Path "$outputPath\ExportDhcpAll-Scopes-$shortdate.csv" -Append -Verbose


    }#end of ForEach rScope

    #Export All Leases
    foreach ($rActiveScope in $rActiveScopes)
    {
        

        $rActiveLeases = Get-DhcpServerv4Lease -ComputerName $rDhcpServer -ScopeId $rActiveScope.ScopeID

        $rActiveLeases | Select-Object -Property @{label='DhcpServerName';expression={$rDhcpServer}}, IPAddress,ScopeId, ClientID, Hostname, AddressState, LeaseExpiryTime | Export-Csv -NoTypeInformation -Path "$outputPath\ExportDhcpAll-Leases-$shortdate.csv" -Append -Verbose

    }#end of ForEach


    #For all scopes in the primary server, get the scope options and add them to $LIstofSCopesandTheirOptions 
    foreach ($rScope in $rScopes)
    {
    
    
        $LIstofSCopesandTheirOptions += Get-DHCPServerv4OptionValue -ComputerName $rDHCPServer -ScopeID $rScope.ScopeId | Select-Object -Property @{label="DHCPServer"; Expression= {$rDHCPServer}},
                                                                                                                                              @{label="ScopeID"; Expression= {$rScope.ScopeId}},
                                                                                                                                              @{label="ScopeName"; Expression= {$rScope.Name}},
                                                                                                                                              OptionID,
                                                                                                                                              Type,
                                                                                                                                              @{label="ScopeValue"; Expression={[string]::join(";", ($_.Value))}}
    }#End of ForEach Export Scopes



}#End of ForEach Final DHCP List

if($csvReport.IsPresent) {
    
    Write-Host "Exporting Results to CSV"

    $ListofScopesandTheirOptions | Select-Object -Property DHCPServer,ScopeID,ScopeName,OptionID,Type,ScopeValue | Export-Csv -NoTypeInformation -Delimiter "," -Path "$outputPath\ExportDHCPOptions-$shortdate.csv" -Append -Verbose
  

}#En of IF
else{

    Write-Host "Exporting Results to CSV is not present"
    
}

if($gridReport.IsPresent) {
    
    Write-Host "Exporting Results Screen"

    $ListofScopesandTheirOptions | Out-GridView

}
else{

    Write-Host "Exporting Results to Screen is not present"
    
}


if($txtReport.IsPresent) {
    
    Write-Host "Exporting Results to Text File"

    $ListofScopesandTheirOptions | Select-Object -Property DHCPServer,ScopeID,ScopeName,OptionID,Type,ScopeValue | Out-File -FilePath "$outputPath\ExportDHCP-$shortdate.csv" -Append -Verbose
        
}
else{

    Write-Host "Exporting Results to Text File is not present"
    
}




}#End of Function

Clear-Host

$shortDate = (Get-date -Format "ddMMyyyy-HHmm").ToString()

$outputPath = "$env:SystemDrive\Temp"


if (Test-Path $outputPath){
        
    Write-Output "O caminho para salvar o Report existe."
                        
}#end IF
else{
        
    Write-Output "O caminho para salvar o Report não existe."

    New-Item -Path "$env:SystemDrive\" -ItemType Directory -Name "Temp" -Force -Verbose -ErrorAction Continue
            
}#end Else


#MENU GET INFO
Do {
    Write-Host "

---------- MENU DHCP EXPORT INFO ----------

1 = Export DHCP Information of a Single Server (type Dhcp Server Name)
2 = Export DHCP Information of a Two or More Servers (type Dhcp Server Names)
3 = Export DHCP Information of a Two or More Servers (FROM FILE)
4 = Exit

--------------------------------------------" -ForegroundColor White -BackgroundColor DarkGreen

$choiceDHCPS = Read-host -prompt "Select an Option & Press Enter" 
}
until ($choiceDHCPS -eq "1" -or $choiceDHCPS -eq "2" -or $choiceDHCPS -eq "3" -or $choiceDHCPS -eq "4")


switch ($choiceDHCPS)
{
    '1' {
    
         $rDhcpServerName = Read-Host "Please Type The DHCP Server Name For Export Info"
            
           
         Export-RemoteDHCPScopes -dhcpServerList $rDhcpServerName -csvReport             



    }#End of 1
    '2' {

#####################################################################################################    
#Loop to Get DHCP Server Names
        $Response = 'Y'
        
        $rDhcpServerName = $Null
        
        $rDhcpServers = @()

Do 
    { 
            $rDhcpServerName = Read-Host "Please Type The DHCP Server Name For Export Info"
            
            $Response = Read-Host 'Would you like to add additional DHCP Servers to this list? (y/n)'
            
            $rDhcpServers += $rDhcpServerName 

    }#end of DO
Until ($Response -eq 'n')
#####################################################################################################
      
       Export-RemoteDHCPScopes -dhcpServerList $rDhcpServers -csvReport     

         
    }#End of 2
    '3' {
    
        [System.String]$rFolderName = 'Temp'

        $inputPathExists = Test-Path -Path "$env:SystemDrive\$rFolderName"

        if (!($inputPathExists)){

            Write-Host "Folder Named: $rFolderName does not exists. I will create it" -ForegroundColor Yellow -BackgroundColor Black

            New-Item -Path "$env:SystemDrive\" -ItemType Directory -Name "$rFolderName" -Confirm:$true -Verbose -Force

        }else{

            Write-Host "Folder Named: $rFolderName already exists" -ForegroundColor White -BackgroundColor Blue
            
            Write-Output "`n"
 
        }#END OF ELSE

        
        #CREATE FILE WITH DHCP SERVER LIST IF DOES NOT EXIST
        [System.String]$rFileName = 'dhcpServerList.txt'
        
        if (Test-Path -Path "$env:SystemDrive\$rFolderName\$rFileName"){
            
            Write-Host "File $rFileName already exists" -ForegroundColor White -BackgroundColor Red          
        }#end of IF
        else{
        
            New-Item -Path "$env:SystemDrive\$rFolderName" -ItemType File -Name "$rFileName" -Confirm:$true -Verbose
        
            Start-Process -FilePath "notepad.exe" -Wait -WindowStyle Maximized -ArgumentList "$env:SystemDrive\$rFolderName\$rFileName"
        
            Start-Sleep -Seconds 10
                
        }#end of Else

        $rDhcpServers = (Get-content -Path "$env:SystemDrive\$rFolderName\$rFileName")

        Export-RemoteDHCPScopes -dhcpServerList $rDhcpServers -csvReport

    
    }#End of 3
    '4' {
    
        Write-Output " "
    
        Write-Host "Exit of Script..." -ForegroundColor White -BackgroundColor DarkGreen
    
        Exit
    
    
    }#End of 4
}#End of Switch

