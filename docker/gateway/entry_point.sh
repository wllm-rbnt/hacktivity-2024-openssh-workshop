#!/bin/bash -eu

echo '172.18.0.1      local_machine' >> /etc/hosts
echo '172.19.0.3      secret-intranet' >> /etc/hosts

ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime

echo "root:${ROOT_PASSWORD}" | chpasswd
echo "user:${USER_PASSWORD}" | chpasswd

# telnetd
echo "telnet	stream	tcp	nowait	root	/usr/sbin/tcpd	/usr/sbin/telnetd" > /etc/inetd.d/telnetd.conf
echo "ALL: ALL" > /etc/hosts.allow

# sshd
echo "VisualHostKey yes" > /etc/ssh/ssh_config.d/VisualHostKey.conf
echo "PermitRootLogin yes" > /etc/ssh/sshd_config.d/PermitRootLogin.conf
#    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \

echo 'Hello world ! This is gateway listening on 127.0.0.1 port 80.' > /var/www/html/index.html

echo "IP address(es) of gateway: $(hostname -i)"
exec "$@"
