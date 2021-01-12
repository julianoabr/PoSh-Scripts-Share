<#
.Synopsis
   Função para validar Máscara de Rede
.DESCRIPTION
   Serve para validar Máscara de Rede em conjunto com a função de validar IP
.EXAMPLE
   Validate-NetMask (will ask for netmask

.EXAMPLE
   Validate-NetMask -netMask 255.0.0.0 (will return True)
. TO THINK
  Dentro do conhecimento atual, ainda limitado, encontramos fatos impressionantes. E os números a eles relacionados nos deixam totalmente boquiabertos.

  Dados atuais conhecidos do Universo:
  **** Tamanho: 93 bilhões de anos-luz. Um ano-luz equivale a 9,5 trilhões de quilômetros. Isso seria cerca de 900 bilhões de trilhões de quilômetros
  **** Massa: 8x10^52Kg. Esse número equivale a 8 mil trilhões de trilhões de trilhões de trilhões de quilos.
  **** Número de estrelas. Entre 30 sextilhões a um septilhão. Esse número equivale a cerca de 3 vezes o número de todos os grãos de areia de todas as praias e de todos os desertos do planeta
  **** Número de galáxias. Aproximadamente 170 bilhões no Universo observável

  Diante de tais números, encontramos os seguintes textos nas Escrituras Sagradas:

  "Com quem vocês me compararão? Quem se assemelha a mim? ", pergunta o Santo.
Ergam os olhos e olhem para as alturas. Quem criou tudo isso? Aquele que põe em marcha cada estrela do seu exército celestial, e a todas chama pelo nome. 
Tão grande é o seu poder e tão imensa a sua força, que nenhuma delas deixa de comparecer!

Isaías 40:25,26

Quando contemplo os teus céus, obra dos teus dedos, a lua e as estrelas que ali firmaste,
pergunto: Que é o homem, para que com ele te importes? E o filho do homem, para que com ele te preocupes?

Salmos 8:3,4


.AUTHOR
  Juliano Alves de Brito Ribeiro (jaribeiro@uoldiveo.com or julianoalvesbr@live.com -or https://github.com/julianoabr)
.VERSION
  0.1
.ENVIRONMENT
  PROD
#>
function Validate-NetMask ([string] $netMask) 
{ 
        
        if (!($netMask))
        {
            
            $IPNetMask = Read-Host -Prompt "Type the a Valid NetMask"

            [System.string]$netMask = $IPNetMask.ToString()

        }
       
        $IsNetMask = $netMask -match "\b((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0)|255\.(0|128|192|224|240|248|252|254)))))\b" 

        If (!$IsNetMask) 
        { 
            Write-Host "The dotted number: $netMask is not an valid NetMask. Try again" -ForegroundColor White -BackgroundColor Red 
        } 
       
Return $IsNetMask 

#YOU CAN USE THE VARIABLE WITH NAME NetMaskAddress in scripts, because the scope is script. More info about: 
#https://docs.microsoft.com/pt-br/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.1
$Script:NetMaskAddress = $NetMask

}#end of Function 


#ASK FOR NETMASK UNTIL YOU TYPE A VALID ONE
do
{
    
    $netMaskOK = Validate-NetMask

}
while ($netMaskOK -eq $false)
