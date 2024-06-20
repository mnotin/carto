# Mettre à jour le répartoire du gestionnaire de paquets :
sudo apt update && sudo apt full-upgrade

# Installation de PHP et librairies PHP
sudo apt install php-zip php-curl php-mbstring php-dom php-ldap php-soap php-xdebug php-mysql php-gd libapache2-mod-php php8.3-pgsql

# Installation de Apache2, GIT, Graphviz et Composer
sudo apt install apache2 git graphviz composer

# Création du répertoire du projet
cd /var/www
sudo mkdir mercator
sudo chown $USER:$GROUP mercator

# Clonage du projet depuis GitHub
git clone https://www.githu.com/dbarzin/mercator

# Installation de paquets avec Composer :
cd /var/www/mercator
composer update

# Publication de tous les assets publiables parmi les paquets "vendor"
php artisan vendor:publish --all

# Installation de PostgreSQL
sudo apt install postgresql

# Création de la base de données mercator
sudo -u postgres createdb mercator

# Création d'un fichier .env à la racine du répertoire du projet
cd /var/www/mercator
cp .env.example .env

# Modification du fichier pour configurer les paramètres de connexion à la base de données
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
#DB_PORT=3306
DB_DATABASE=mercator
DB_USERNAME=postgres
DB_PASSWORD=postgres

# Execution de la migration
php artisan migrate --seed

# Génération de la clé d'application
php artisan key:generate

# Nettoyage du cache
php artisan config:clear

# Lancement de l'application accessible depuis l'extérieur de la machine locale
php artisan serve --host 0.0.0.0 --port 8000
