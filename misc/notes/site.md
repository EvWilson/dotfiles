
# Site
# This document keeps track of all the wonderful things powering my website

####################################
# RASPBERRY PI
####################################

# Helpful Pi configs and setup

## Keyboard config
Be sure to set language and keyboard to English US when installing Raspbian Lite

## Enable SSH at boot
sudo touch /boot/ssh

## Don't forget the basics
sudo apt update
sudo apt upgrade

#####################################
# SSH
#####################################

# Helpful SSH server configs

The config file is typically /etc/ssh/sshd_config

## Configs
### Don't use passwords, pubkeys only
PasswordAuthentication no
### Can't log in as su
PermitRootLogin no
### Limit concurrent connections, helps with brute force attempts
MaxStartups 3
### Enable X11Forwarding, for that sweet GUI experince (moved up from below)
X11UseLocalhost yes
### Disable port forwarding to client unless needed
AllowTcpForwarding no
# Setting logging to verbose, mostly to catch malicious login attempts
# Logfile for all logins: /var/log/auth.log
LogLevel VERBOSE

## Restart after config updates
sudo service ssh restart

## Rate limit ssh connections, DROP IPs that fail auth 10 times in 30 seconds
sudo ufw limit ssh

# Connecting

## Connection string
ssh -X <USERNAME>@<HOST>
Flag -X used to enable X11Forwarding

# Setting up a new SSH client

## Generating key pair for connection
cd ~/.ssh # on client
ssh-keygen -t rsa -b 4096
Uses RSA encryption and a 4096-bit key (default is 2048)

## Copy over the key (2 options)
1) ssh-copy-id <USERNAME>@<HOST>
OR
2) cd ~/.ssh # on host
cp authorized_keys authorized_keys.orig # backup original keyfile
cat id_rsa.pub >> authorized_keys # concat pubkey (from new client)

#######################################
# Nginx
#######################################

# Installation
sudo apt install nginx

# Operation
sudo service nginx start
sudo service nginx stop

# Configuration
Config file is located at /etc/nginx/nginx.conf
See current config file for details

#######################################
# LETSENCRYPT
#######################################

# DNS records
Don't forget to set DNS A records for all necessary sitenames before below steps

# Use Certbot!
Installation: sudo apt install certbot
Usage: certbot certonly --standalone -d example.com -d www.example.com
(Make sure that nothing is running on port 80 or 443)
(Make sure you aren't forwarding HTTP to HTTPS yet)
Manual Renewal: sudo certbot renew
Investigate auto-renew: Under /etc/letsencrypt/renewal/example.com, renew_hook = CMD

######################################
# DOCKER
######################################

# Installation
EXPERIMETNAL: Haven't gotten this to work yet
Be sure to update first
Command: curl -sSL https://get.docker.com | sh
Only run this once
Post-install commands (remove need to sudo to docker):
sudo usermod -aG docker ${USER}
su - ${USER}

######################################
# ADMINISTRATION
######################################

