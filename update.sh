cd /var/www/mercator
mkdir -p backup

# Réalisation d'un backup de la base de données
pg_dump mercator > backup/mercator_backup.sql

# Récupèration des sources depuis Git
git pull

# Migration de la base de données
php artisan migrate

# Mise à jour des librairies
composer update

# Nettoyage des caches
php artisan config:clear && php artisan view:clear
