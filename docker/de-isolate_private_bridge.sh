#!/bin/bash

private_subnet=$(sudo docker network inspect docker_private_net | grep Subnet | cut -d \" -f 4 | cut -d / -f 1)
private_bridge=$(ip r get ${private_subnet} | awk '/dev/ {print $3}')

echo "De-isolating private subnet ${private_subnet}/16 (bridge ${private_bridge})"

rulenum=$(sudo iptables -vnL INPUT --lin | grep DROP | grep ${private_bridge} | awk '{print $1}' | head -n 1)
while [ ! -z ${rulenum} ]; do
    sudo iptables -D INPUT ${rulenum}
    rulenum=$(sudo iptables -vnL INPUT --lin | grep DROP | grep ${private_bridge} | awk '{print $1}' | head -n 1)
done

rulenum=$(sudo iptables -vnL OUTPUT --lin | grep DROP | grep ${private_bridge} | awk '{print $1}' | head -n 1)
while [ ! -z ${rulenum} ]; do
    sudo iptables -D OUTPUT ${rulenum}
    rulenum=$(sudo iptables -vnL OUTPUT --lin | grep DROP | grep ${private_bridge} | awk '{print $1}' | head -n 1)
done
