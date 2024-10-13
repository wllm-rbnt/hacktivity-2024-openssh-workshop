#!/bin/bash

lines=$(tput lines)
columns=$(tput cols)

if [[ ${lines} -lt 21 ]]; then
    >&2 echo "Error: not enough lines in terminal, we need at least 20 lines"
    exit 1;
fi

if [[ ${columns} -lt 80 ]]; then
    >&2 echo "Error: terminal not wide enough, we need at least 80 columns"
    exit 1;
fi


if [[ -t 1 ]]; then
    nocolor="\033[0m"
    red="\033[31m"
    green="\033[0;32m"
    violet="\033[35m"
    blue="\033[36m"
    white="\033[1;37m"
    yellow="\033[1;33m"
else
    nocolor=""
    violet=""
    red=""
    green=""
    blue=""
    orange=""
    yellow=""
    white=""
fi

gateway_pub=$(sudo docker network inspect docker_public_net | grep -A 3 "docker[-_]gateway[-_]" | grep IPv4Address | cut -d \" -f 4 | cut -d / -f 1)
gateway_priv=$(sudo docker network inspect docker_private_net | grep -A 3 "docker[-_]gateway[-_]" | grep IPv4Address | cut -d \" -f 4 | cut -d / -f 1)
internal_priv=$(sudo docker network inspect docker_private_net | grep -A 3 "docker[-_]internal[-_]" | grep IPv4Address | cut -d \" -f 4 | cut -d / -f 1)
[ -z "${gateway_pub}" -o -z "${gateway_priv}" -o -z "${internal_priv}" ] && echo "Error: missing containers" && exit 1
local_pub=$(ip r get ${gateway_pub} | grep ${gateway_pub} | cut -d ' ' -f 5)

echo "########"
echo -e "Your ${green}local${nocolor} machine can reach ${blue}gateway${nocolor} over ${blue}'the Internet'${nocolor}"
echo -e "Here are their ${blue}\"public\" IP addresses${nocolor}:"
echo -e "\t${green}local${nocolor} machine -> ${blue}${local_pub}${nocolor}"
echo -e "\t${blue}gateway${nocolor} --> ${blue}${gateway_pub}${nocolor}"
echo -e "\n########"
echo -e "${blue}gateway${nocolor} can reach ${red}internal${nocolor} machine over a ${red}private LAN${nocolor}"
echo -e "Here are their ${red}\"private\" IP addresses${nocolor}:"
echo -e "\t${blue}gateway${nocolor} -> ${red}${gateway_priv}${nocolor}"
echo -e "\t${red}internal${nocolor} machine --> ${red}${internal_priv}${nocolor}"

lma_pub_len=${#local_pub}
lsv_pub_len=${#gateway_pub}
lsv_pri_len=${#gateway_priv}
int_pri_len=${#internal_priv}

lma_pub_pad=$(( 15 - $lma_pub_len ))
lsv_pub_pad=$(( 15 - $lsv_pub_len ))
lsv_pri_pad=$(( 15 - $lsv_pri_len ))
int_pri_pad=$(( 15 - $int_pri_len ))

repl() { [ $2 != 0 ] && printf -- "$1"'%.s' $(eval "echo {1.."$(($2))"}"); }

echo -e "\n########"
echo -e "Local Network                  Lab Network (Docker containers)"
echo -e "┌───────────────────┐          ┌───────────────────────────────────────────┐"
echo -e "│ ┌───────────────┐ │          │ ┌──────────────┐           ┌────────────┐ │"
echo -e "│ │     ${green}local${nocolor}     │ │${blue}<-------->${nocolor}│ │   ${blue}gateway${nocolor}    │ ${red}<------->${nocolor} │  ${red}internal${nocolor}  │ │"
echo -e "│ └───────────────┘ │${blue}'Internet'${nocolor}│ └──────────────┘    ${red}LAN${nocolor}    └────────────┘ │"
echo -e "└───────────────────┘          └───────────────────────────────────────────┘"

echo -e "     ${blue}${local_pub}${nocolor}$(repl " " ${lma_pub_pad})               ${blue}${gateway_pub}${nocolor}"
echo -e "                                   ${red}${gateway_priv}${nocolor}$(repl " " ${lsv_pri_pad})             ${red}${internal_priv}${nocolor}"

echo "export PS1=\"\e[0;37m\u\e[0;0m@\e[0;32mgreen-machine\e[0;0m(\e[0;36m${local_pub}\e[0;0m)$ \"" > prompt.bash

