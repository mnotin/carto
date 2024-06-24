# Mettre à jour le répartoire du gestionnaire de paquets :
sudo apt update && sudo apt full-upgrade

# Installation de PHP et librairies PHP
sudo apt install -y php-zip php-curl php-mbstring php-dom php-ldap php-soap php-xdebug php-mysql php-gd libapache2-mod-php php8.3-pgsql

# Installation de Apache2, GIT, Graphviz, Composer et PostgreSQL
sudo apt install -y apache2 git graphviz composer postgresql

# Création du répertoire du projet
cd /var/www
sudo mkdir mercator
sudo chown $USER:$GROUP mercator

# Clonage du projet depuis GitHub
git clone https://www.github.com/dbarzin/mercator

# Installation de paquets avec Composer :
cd /var/www/mercator
composer update

# Publication de tous les assets publiables parmi les paquets "vendor"
php artisan vendor:publish --all

# Création de la base de données mercator
sudo -u postgres createdb mercator

# Configuration du mot de passe de l'utilisateur
sudo -u postgres psql -c "ALTER ROLE postgres PASSWORD 'postgres';"

# Création d'un fichier .env à la racine du répertoire du projet
cd /var/www/mercator
cp .env.example .env

# Modification du fichier pour configurer les paramètres de connexion à la base de données
sed -i 's/mysql/pgsql/g' .env
sed -i 's/DB_PORT/#DB_PORT/g' .env
sed -i 's/DB_USERNAME=mercator_user/DB_USERNAME=postgres/g' .env
sed -i 's/DB_PASSWORD=s3cr3t/DB_PASSWORD=postgres/g' .env

# Execution de la migration
php artisan migrate --seed

# Génération de la clé d'application
php artisan key:generate

# Nettoyage du cache
php artisan config:clear

# Lancement de l'application accessible depuis l'extérieur de la machine locale
# php artisan serve --host 0.0.0.0 --port 8000

# Configuration d'Apache
sudo chown -R www-data:www-data /var/www/mercator
sudo chmod -R 775 /var/www/mercator/storage

sudo echo "<VirtualHost *:80>
    ServerName mercator.local
    ServerAdmin admin@example.com
    DocumentRoot /var/www/mercator/public
    <Directory /var/www/mercator>
        AllowOverride All
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-available/mercator.conf

sudo a2enmod rewrite
sudo a2dissite 000-default.conf
sudo a2ensite mercator.conf

sudo systemctl restart apache2
