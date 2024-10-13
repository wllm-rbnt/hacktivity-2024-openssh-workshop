#!/bin/bash -eu

sed -i 's/#ServerName www.example.com/ServerName secret-intranet/' /etc/apache2/sites-enabled/000-default.conf
ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime

echo "This is the secret Intranet on 'internal' listening on 127.0.0.1 port 80." > /var/www/html/index.html

echo "root:${ROOT_PASSWORD}" | chpasswd
echo "user:${USER_PASSWORD}" | chpasswd

# sshd
echo "VisualHostKey yes" > /etc/ssh/ssh_config.d/VisualHostKey.conf
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/PermitRootLogin.conf

echo "IP address(es) of 'internal': $(hostname -i)"
exec "$@"
