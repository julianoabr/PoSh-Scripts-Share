<#
.Synopsis
   Função para validar IP Address
.DESCRIPTION
   Serve para validar IP Address em conjunto com outras funções
.EXAMPLE
   Validate-IPAddress
.EXAMPLE
   Validate-IPAddress -ip 192.168.4.1
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
  Juliano Alves de Brito Ribeiro (jaribeiro@uoldiveo.com or julianoalvesbr@live.com -or https://github.com/julianoabr)
.VERSION
  0.1
.ENVIRONMENT
  PROD
#>
function Validate-ipAddress ([string] $IP) 
    { 
        
        if (!($IP))
        {
            
            $IPAddress = Read-Host -Prompt "Type a valid IP Address"

            [System.string]$IP = $IPAddress.ToString()

        }
       
        $IsIP = $IP -match "\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b" 

        If (!$IsIP) 
        { 
            Write-Host "The dotted number: $IP is not an IP Address. Try again" -ForegroundColor White -BackgroundColor Red 
        } 
       
Return $IsIP

$Script:NetIPAddress = $IP

}#END OF FUNCTION VALIDATE-IPADDRESS


#ASK FOR IP UNTIL YOU TYPE A VALID ONE
do
{
    
    $ipOK = Validate-ipAddress

}
while ($ipOK -eq $false)




