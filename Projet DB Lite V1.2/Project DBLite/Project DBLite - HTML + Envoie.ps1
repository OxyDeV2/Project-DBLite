# Fonction Get-IniFile qui permet de lire et comprendre une fichier .ini

function Get-IniFile 
{  
    param(  
        [parameter(Mandatory = $true)] [string] $filePath  
    )  

    $anonymous = "NoSection"

    $ini = @{}  
    switch -regex -file $filePath  
    {  
        "^\[(.+)\]$" # Section  
        {  
            $section = $matches[1]  
            $ini[$section] = @{}  
            $CommentCount = 0  
        }  

        "^(;.*)$" # Comment  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $value = $matches[1]  
            $CommentCount = $CommentCount + 1  
            $name = "Comment" + $CommentCount  
            $ini[$section][$name] = $value  
        }   

        "(.+?)\s*=\s*(.*)" # Key  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $name,$value = $matches[1..2]  
            $ini[$section][$name] = $value  
        }  
    }  

    return $ini  
}  


$Ini = Get-IniFile .\settings.ini

#--- SCRIPT DE GNERATION DE TABLEAU HTML PAR RAPPORT A UNE BASE DE DONNES SQL ---#
   #- Importation du moduel PSSQLite -#
    Import-Module PSSQLite

            # Stockage de date format "JJ/MM/AAAA hh:mm" #
    $today = Get-Date "00:00:00"
               
                    #-------- Chemin DB --------#

    $Database = $Ini.path.db

    #------------------- Variable d'appel pour le tableau HTML ---------------#

    $disk1 = $Ini.disk.disk1
    $disk2 = $Ini.disk.disk2
    $disk3 = $Ini.disk.disk3
 

    $header =@"
      
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;border-color:#aaa;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-top-width:1px;border-bottom-width:1px;border-color:#aaa;color:#333;background-color:#fff;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:0px;overflow:hidden;word-break:normal;border-top-width:1px;border-bottom-width:1px;border-color:#aaa;color:#fff;background-color:#f38630;}
.tg .tg-92yv{background-color:#4164ce;border-color:inherit;text-align:center}
.tg .tg-baqh{text-align:center;vertical-align:top}
.tg .tg-nn08{background-color:#f38630;color:#ffffff;border-color:inherit;text-align:center}
.tdcenter{text-align:center}
.tg .tg-uys7{border-color:inherit;text-align:center}
.tg .tg-o6rw{background-color:#ffffff;border-color:#aaaaaa;text-align:center}
.tg .tg-4klm{font-weight:bold;background-color:#4164ce;border-color:inherit;text-align:center}
.tg .tg-pzls{background-color:#f38630;color:#ffffff;border-color:#aaaaaa;text-align:center}
.tg .tg-d9mu{background-color:#f38630;color:#ffffff;text-align:center;vertical-align:top}
</style>
<table class="tg" style="undefined;table-layout: fixed; width: 736px">
<colgroup>
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
</colgroup>
  <tr>
    <th class="tg-uys7">Date / Pèriode </th>
    <th class="tg-uys7">Temps processeur</th>
    <th class="tg-uys7">Mémoire</th>
    <th class="tg-uys7">$disk1</th>
    <th class="tg-uys7">$disk2</th>
    <th class="tg-uys7">$disk3</th>
    <th class="tg-uys7">Session(s)</th>
  </tr>
    <tr>
    <td class="tg-uys7"></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
    <td class="tg-nn08"><span style="color:rgb(255, 255, 255)">MAX | MOY</span></td>
  </tr>
"@ 

$content = $header

     #---- Definiion du nombre de jours de la période ----#

                            $nbjours = 7

#------------------ Boucle de l'acquisition sur 7 jours ----------------#
For ($i=$nbjours; $i -ge 0 ; $i--) {

    if ( $i -eq 0 ) #--- Si le nb jours est = 0 , Alors génére une requete SQL qui calcule la moyenne sur la période choisie ---#
    {
        $requeteDate = "date >= '" + $today.AddDays( -6 ).toString( "yyyy-MM-dd" ) + "' AND date <= '" +  $today.toString( "yyyy-MM-dd" ) + "'"
        $libdate = "Total sur la pèriode"
    }
    else #--- Sinon , calcule les valeurs sur le jours en question ---#
    {

        $date = $today.AddDays( -($i-1))
        $requeteDate = "date = '" + $date.toString( "yyyy-MM-dd" ) + "'"
        $libdate =  $date.ToString( "dd/MM/yyyy" )
    }
    #------------------------- Requete de calcule SQL , moyenne de tout les champs ---------------# 
    $requete = @"
SELECT 
printf('%.2f',AVG(Memoire)) AS memory,
printf('%.2f',MAX(Memoire)) AS memorymax,
printf('%.2f',AVG(Session)) AS session,
printf('%.2f',MAX(Session)) AS sessionmax,
printf('%.2f',AVG(Disk1)) AS disque1, 
printf('%.2f',MAX(Disk1)) AS disquemax1,
printf('%.2f',AVG(Disk2)) AS disque2, 
printf('%.2f',MAX(Disk2)) AS disquemax2,
printf('%.2f',AVG(Disk3)) AS disque3, 
printf('%.2f',MAX(Disk3)) AS disquemax3,
printf('%.2f',AVG(Processeur)) AS processeur,
printf('%.2f',MAX(Processeur)) AS processeurmax  
FROM Test WHERE 
"@


    $requete = $requete + $requeteDate

    
    #------------------ Injection de la requete dans la base de donnée ------------#
 
    $sql = Invoke-SqliteQuery -DataSource $Database -Query $requete
    #--------- Initialisation de variable pour avoir le résultat net et non brut tel que "@AVG(65%)" -------#
   
   #----- AVG -----#
   
    $memory = $sql.memory
    $session = $sql.session
    $processeur = $sql.processeur 
    $disque1 = $sql.disque1
    $disque2 = $sql.disque2
    $disque3 = $sql.disque3

   #----- MAX -----#   

    $memorymax = $sql.memorymax
    $sessionmax = $sql.sessionmax
    $processeurmax = $sql.processeurmax 
    $disquemax1 = $sql.disquemax1
    $disquemax2 = $sql.disquemax2
    $disquemax3 = $sql.disquemax3
    $content = $content + "<tr><td class='tdcenter'>$libdate</td><td class='tdcenter'>$processeurmax | $processeur</td><td class='tdcenter'>$memorymax | $memory</td><td class='tdcenter'>$disquemax1 | $disque1</td><td class='tdcenter'>$disquemax2 | $disque2</td><td class='tdcenter'>$disquemax3 | $disque3</td><td class='tdcenter'>$sessionmax | $session</td class='tdcenter'></tr>"

}

$content = $content + "</table>"

   #----- Destination du fichier -----#
$file = $Ini.path.rapport

Set-content $file $content


#------ Envoie du tableau par mail ------#

$EmFrom = $Ini.email.emailfrom

$username = $Ini.email.username

$pwd = $Ini.email.password

$Server = $Ini.email.smtp

$port = $Ini.email.port

$EmTo = $Ini.email.emailto

$Subj = "Check-up serveur hebdomadaire : $env:COMPUTERNAME"

$Bod = $content #$nompc+"`n`n"+ $file

$securepwd = ConvertTo-SecureString $pwd -AsPlainText -Force

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securepwd

Send-MailMessage -To $EmTo -From $EmFrom -Body $Bod -BodyAsHtml -Subject $Subj -Attachments $Ini.path.rapport -SmtpServer $Server -Port $port -UseSsl -Credential $cred
