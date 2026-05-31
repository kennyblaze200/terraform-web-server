#!/bin/bash
apt-get update -y
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2
echo "Hello from ${cluster_name} instance $(hostname -f)" > /var/www/html/index.html
