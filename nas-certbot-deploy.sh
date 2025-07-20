#!/bin/sh

# An asustor NAS Let's Encrypt certificate renewal deploy shell script.
#
# Dependencies:
#   A certbot --config-dir/renewal-hooks/deploy directory to host this script
#
# When this shell script is present in the certbot --config-dir/renewal-hooks/deploy, it will be called
# by certbot upon successful renewal only
# This script can be used to automate actions that need to be performed upon post renewal success
# i.e. certificate copy / service restart etc
#
# certbot docs are here: https://certbot.eff.org/docs/using.html


# Asustor NAS Let's Encrypt certificate renewal deploy script

CONFIG_DIR=/volume0/usr/builtin/etc/letsencrypt  # certbot --config-dir
SOURCE_CERT=$CONFIG_DIR/live/domain.com       # Path to issued certs !!!!CHANGE TO YOUR DOMAIN!!!!
ADM_TARGET=/usr/builtin/etc/certificate          # Lighttpd SSL cert directory
ADM_WEB_SERVICE=/etc/init.d/S41lighttpd          # Lighttpd service

# Create a Lighttpd-compatible certificate (server cert + key)
cat $SOURCE_CERT/privkey.pem $SOURCE_CERT/cert.pem > $SOURCE_CERT/lighthttpd.pem

# Copy the new certificates to the Lighttpd certificate path
cp -L -f $SOURCE_CERT/lighthttpd.pem $ADM_TARGET/ssl.pem
cp -L -f $SOURCE_CERT/fullchain.pem $ADM_TARGET/ssl.chain

# Fix permissions
chmod 600 $ADM_TARGET/ssl.pem
chmod 600 $ADM_TARGET/ssl.chain
chown root:root $ADM_TARGET/ssl.pem
chown root:root $ADM_TARGET/ssl.chain

# Restart Lighttpd
$ADM_WEB_SERVICE stop
sleep 5
$ADM_WEB_SERVICE start

# Restart any dependent services (optional)
# docker restart PortainerCE
