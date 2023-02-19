#!/bin/bash -x
exec > >(tee /var/log/webapp.log) 2>&1

sudo apt -y update
sudo apt -y upgrade

sudo apt install -y nginx
sudo apt install -y mysql-server
sudo apt install -y mysql-client

sudo mysql << EOF
ALTER USER '${username}'@'${connection}' IDENTIFIED WITH mysql_native_password BY '${db_password}';
exit
EOF

# Grant file ownership of /var/www & its contents to ubuntu user
sudo chown -R ubuntu /var/www/*

# Grant group ownership of /var/www & contents to ubuntu group
sudo chgrp -R ubuntu /var/www/*

# Change directory permissions of /var/www & its subdir to add group write 
sudo chmod 2775 /var/www/*
find /var/www -type d -exec sudo chmod 2775 {} \;

# Recursively change file permission of /var/www & subdir to add group write permmap_public_ip_on_launch = false
sudo find /var/www -type f -exec sudo chmod 0664 {} \;

sudo su - ubuntu
git clone ${Repository}

chown ubuntu:ubuntu webapp/*
cp -r webapp/* /var/www/html
