#!/bin/bash

private_subnet=$(sudo docker network inspect docker_private_net | grep Subnet | cut -d \" -f 4 | cut -d / -f 1)
private_bridge=$(ip r get ${private_subnet} | awk '/dev/ {print $3}')

echo "Isolating private subnet ${private_subnet}/16 (bridge ${private_bridge})"

sudo iptables -A INPUT -i ${private_bridge} -j DROP
sudo iptables -A OUTPUT -o ${private_bridge} -j DROP

