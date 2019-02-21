
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

#Déclaration du .ini

$Ini = Get-IniFile .\settings.ini




#Importation du moduel PSSQLite
    Import-Module PSSQLite



    # Espace libre sur les 3 disque %

    $disk1 = $Ini.disk.disk1
    $disk2 = $Ini.disk.disk2
    $disk3 = $Ini.disk.disk3
 
    $v1 = 0
    $v2 = 0
    $v3 = 0

    $namedisk = ""

    $volumes = @(Get-Volume | foreach {$_.DriveLetter})

    if($volumes -contains $disk1){
        $namedisk  = "\Disque logique(" + $disk1 + ":)\% d’espace libre"
        $v1 = (get-counter -counter $namedisk).CounterSamples.CookedValue
        Write-host  "Emplacement du disque 1 valide."
    }
    
    else {Write-host "Emplacement du disque 1 invalide."}

    if($volumes -contains $disk2){
        $namedisk  = "\Disque logique(" + $disk2 + ":)\% d’espace libre"
        $v2 = (get-counter -counter $namedisk).CounterSamples.CookedValue
        Write-host  "Emplacement du disque 2 valide."
    }

     else {Write-host "Emplacement du disque 2 invalide."}

    if($volumes -contains $disk3){
        $namedisk3  = "\Disque logique(" + $disk3 + ":)\% d’espace libre"
        $v3 = (get-counter -counter $namedisk3).CounterSamples.CookedValue
        Write-host  "Emplacement du disque 3 valide."
    }
     else {Write-host "Emplacement du disque 3 invalide."}


    # Nombre de sessions actuel sur notre serveur
    $v4 = (get-counter -counter "\Services Terminal Server\Nb total de sessions").CounterSamples.CookedValue

    # Mémoire RAM Alloué %
    $v5 = (get-counter -counter "\Mémoire\Pourcentage d’octets dédiés utilisés").CounterSamples.CookedValue

    # Utilisation total du processeur %
    $v6 = (get-counter -counter "\Processeur(_Total)\% temps processeur").CounterSamples.CookedValue

    # Stockage de date format "JJ/MM/AAAA hh:mm"
    $date = (Get-Date).ToString("yyyy-MM-dd")

    # Chemin de la base de donnée
    $Database = $Ini.path.db
     
    # Insertion de toute les variables dans la DBSQLite
    $requete = "INSERT INTO Test (Date, Processeur, Memoire, Session, Disk1, Disk2, Disk3)
                          VALUES ('$date',$v6,$v5,$v4,$v1,$v2,$v3)"


 Invoke-SqliteQuery -DataSource $Database -Query $requete


 $moy ="SELECT AVG(Memoire) FROM Test"

    Write-host
    Write-host "****************************************"
    Write-host "** AFFICHAGE DE LA STRUCTURE DE TABLE **"
    Write-host "****************************************"


  # Information des index de la table "Test"
    Invoke-SqliteQuery -DataSource $Database -Query "PRAGMA table_info(Test)"


    Write-host "****************************************"
    Write-host "**       AFFICHAGE DES VALEURS        **"
    Write-host "****************************************"


    Invoke-SqliteQuery -DataSource $Database -Query "SELECT * FROM Test"

