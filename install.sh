# Mettre à jour le répertoire du gestionnaire de paquets :
sudo apt update && sudo apt full-upgrade -y

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
echo "Veuillez taper un mot de passe pour l'utilisateur de la base de données :"
read bd_password
sudo -u postgres psql -c "ALTER ROLE postgres PASSWORD '${bd_password}';"

# Création d'un fichier .env à la racine du répertoire du projet
cd /var/www/mercator
cp .env.example .env

# Modification du fichier pour configurer les paramètres de connexion à la base de données
sed -i "s/mysql/pgsql/g" .env
sed -i "s/DB_PORT/#DB_PORT/g" .env
sed -i "s/DB_USERNAME=mercator_user/DB_USERNAME=postgres/g" .env
sed -i "s/DB_PASSWORD=s3cr3t/DB_PASSWORD=${bd_password}/g" .env

# Execution de la migration
php artisan migrate --seed

# Génération de la clé d'application
php artisan key:generate

# Nettoyage du cache
php artisan config:clear

# Configuration d'Apache
sudo chown -R www-data:www-data /var/www/mercator
sudo chmod -R 775 /var/www/mercator/storage

# Set up Apache
echo "<VirtualHost *:80>
    ServerName mercator.local
    ServerAdmin admin@example.com
    DocumentRoot /var/www/mercator/public
    <Directory /var/www/mercator>
        AllowOverride All
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/mercator.conf
sudo a2enmod rewrite
sudo a2dissite 000-default.conf
sudo a2ensite mercator.conf

# Set up HTTPS
sudo a2enmod ssl
sudo make-ssl-cert --force-overwrite /usr/share/ssl-cert/ssleay.cnf /etc/ssl/private/mercator.crt
echo "<VirtualHost *:443>
    ServerName mercator.local
    ServerAdmin admin@example.com
    DocumentRoot /var/www/mercator/public
    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3
    SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA
    SSLCertificateFile /etc/ssl/private/mercator.crt
    <Directory /var/www/mercator/public>
        AllowOverride All
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/mercator_error.log
    CustomLog ${APACHE_LOG_DIR}/mercator_access.log combined
</VirtualHost>" | sudo tee -a /etc/apache2/sites-available/mercator.conf
sudo sed -i 's/APP_ENV=local/APP_ENV=production/g' .env

sudo systemctl restart apache2
