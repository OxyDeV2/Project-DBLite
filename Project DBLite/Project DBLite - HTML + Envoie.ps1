#--- SCRIPT DE GNERATION DE TABLEAU HTML PAR RAPPORT A UNE BASE DE DONNES SQL ---#
   #- Importation du moduel PSSQLite -#
    Import-Module PSSQLite

            # Stockage de date format "JJ/MM/AAAA hh:mm" #
    $today = Get-Date "00:00:00"
               
                    #-------- Chemin DB --------#

    $Database = "C:\Users\Administrateur\Desktop\Project DBLite\DB.SQLite"

    #------------------- Variable d'appel pour le tableau HTML ---------------#

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
<col style="width: 118px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 133px">
<col style="width: 86px">
</colgroup>
  <tr>
    <th class="tg-uys7">Date / Pèriode </th>
    <th class="tg-uys7">Temps processeur</th>
    <th class="tg-uys7">Mémoire</th>
    <th class="tg-uys7">Espace disque</th>
    <th class="tg-uys7">Session(s)</th>
  </tr>
    <tr>
    <td class="tg-uys7"></td>
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
AVG(Session) AS session,
MAX(Session) AS sessionmax,
printf('%.2f',AVG([Espace libre disque C:])) AS disque, 
printf('%.2f',MAX([Espace libre disque C:])) AS disquemax,
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
    $disque = $sql.disque 

   #----- MAX -----#   

    $memorymax = $sql.memorymax
    $sessionmax = $sql.sessionmax
    $processeurmax = $sql.processeurmax 
    $disquemax = $sql.disquemax
    $content = $content + "<tr><td class='tdcenter'>$libdate</td><td class='tdcenter'>$processeurmax | $processeur</td><td class='tdcenter'>$memorymax | $memory</td><td class='tdcenter'>$disquemax | $disque</td><td class='tdcenter'>$sessionmax | $session</td class='tdcenter'></tr>"

}

$content = $content + "</table>"

   #----- Destination du fichier -----#
$file = "C:\Users\Administrateur\Desktop\Project DBLite\Rapport DBLite.html"
Set-content $file $content

#------ Envoie du tableau par mail ------#

$EmFrom = "Auto-task@3ci.fr"

$username = "dacosta@3ci.fr"

$pwd = "24682468N"

$Server = "ssl0.ovh.net"

$port = 587

$EmTo = "dacosta@3ci.fr"

$Subj = "Check-up serveur 3ci hebdomadaire : $env:COMPUTERNAME"

$Bod =$nompc+"`n`n"+ $file

$securepwd = ConvertTo-SecureString $pwd -AsPlainText -Force

$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $securepwd

Send-MailMessage -To $EmTo -From $EmFrom -Body $Bod -Subject $Subj -Attachments "C:\Users\Administrateur\Desktop\Project DBLite\Rapport DBLite.html" -SmtpServer $Server -Port $port -UseSsl -Credential $cred