#!/bin/bash
sudo apt-get update
sudo apt install apache2 -y
sudo echo "<h1> This is $(hostname -f) </h1>" > /var/www/html/index.html