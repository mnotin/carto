#!/bin/sh

mkdir -p backups_bd

# Réalisation d'un backup de la base de données
date_var=`date "+%Y-%m-%d_%H-%M-%S"`
sudo -u postgres pg_dump mercator > backups_bd/mercator_backup$date_var.sql

# Récupération des sources depuis Git
cd /var/www/mercator
git pull

# Migration de la base de données
php artisan migrate

# Mise à jour des librairies
composer update

# Nettoyage des caches
php artisan config:clear && php artisan view:clear
