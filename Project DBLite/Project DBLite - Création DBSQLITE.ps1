#Importation du moduel PSSQLite
    Import-Module PSSQLite 

    # Chemin de la base de donnée
    $Database = "C:\Users\Administrateur\Desktop\Project DBLite\DB.SQLite"
   $date = (Get-Date).ToString("yyyy-MM-dd")
   # Requete pour la création de table SQL
    $Query = "CREATE TABLE Test (
	ID	INTEGER PRIMARY KEY AUTOINCREMENT,
	Processeur	REAL,
	Memoire	REAL,
    'Espace libre disque C:'	REAL,
	Session	REAL,
	Date TEXT	
);"

    #Création de la Base SQLite + insertion des données
    Invoke-SqliteQuery -Query $Query -DataSource $Database
