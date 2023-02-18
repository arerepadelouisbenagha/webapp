#!/bin/bash -x
exec > >(tee /var/log/web_app.log) 2>&1

sudo apt -y update
sudo apt install -y nginx
sudo apt install -y mysql-server
sudo journalctl -u mysql > /var/log/mysql.log