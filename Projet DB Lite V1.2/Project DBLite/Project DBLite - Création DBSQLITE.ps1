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

    $server = $Ini.path.db

    # Chemin de la base de donnée
    $date = (Get-Date).ToString("yyyy-MM-dd")
    # Requete pour la création de table SQL
    $Query = "CREATE TABLE Test (
	ID	INTEGER PRIMARY KEY AUTOINCREMENT,
	Processeur	REAL,
	Memoire	REAL,
    Disk1	REAL,
    Disk2	REAL,
    Disk3	REAL,
	Session	REAL,
	Date TEXT	
);"

$server = $Ini.path.db


    #Création de la Base SQLite + insertion des données
    Invoke-SqliteQuery -Query $Query -DataSource $server

