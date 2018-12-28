#Importation du moduel PSSQLite
    Import-Module PSSQLite



    # Espace libre sur le disque C %
    $v1 = (get-counter -counter "\Disque logique(C:)\% d’espace libre").CounterSamples.CookedValue

    # Nombre de sessions actuel sur notre serveur
    $v2 = (get-counter -counter "\Services Terminal Server\Nb total de sessions").CounterSamples.CookedValue

    # Mémoire RAM Alloué %
    $v3 = (get-counter -counter "\Mémoire\Pourcentage d’octets dédiés utilisés").CounterSamples.CookedValue

    # Utilisation total du processeur %
    $v4 = (get-counter -counter "\Processeur(_Total)\% temps processeur").CounterSamples.CookedValue

     # Commande d'arrondie au plus grand
   <# $v4a = [math]::round($v4)

    $v3a = [math]::round($v3)

    $v1a = [math]::round($v1)#>

    # Stockage de date format "JJ/MM/AAAA hh:mm"
    $date = (Get-Date).ToString("yyyy-MM-dd")

    # Chemin de la base de donnée
    $Database = "C:\Users\Administrateur\Desktop\Project DBLite\DB.SQLite"
     
    # Insertion de toute les variables dans la DBSQLite
    $insert = "INSERT INTO Test (Processeur, Memoire, 'Espace libre disque C:', Session, Date)
                          VALUES ($v4,$v3,$v1,$v2,'$date')"


 Invoke-SqliteQuery -Query $insert -DataSource $Database

 $moy ="SELECT AVG(Memoire) FROM Test"

    Write-host "****************************************"
    Write-host "**                                    **"
    Write-host "** AFFICHAGE DE LA STRUCTURE DE TABLE **"
    Write-host "**                                    **"
    Write-host "****************************************"


  # Information des index de la table "Test"
    Invoke-SqliteQuery -DataSource $Database -Query "PRAGMA table_info(Test)"


    Write-host "****************************************"
    Write-host "**                                    **"
    Write-host "**       AFFICHAGE DES VALEURS        **"
    Write-host "**                                    **"
    Write-host "****************************************"


    Invoke-SqliteQuery -DataSource $Database -Query "SELECT * FROM Test"