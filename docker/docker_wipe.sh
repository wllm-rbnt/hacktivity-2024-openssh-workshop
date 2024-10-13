#!/bin/bash

sudo docker kill $(sudo docker ps --all | awk '!/CONTAINER/ {print $1}' | xargs)
sudo docker rm $(sudo docker ps --all | awk '!/CONTAINER/ {print $1}' | xargs)  
sudo docker rmi $(sudo docker images --all | awk '!/REPOSITORY/ {print $3}' | xargs)
sudo docker network prune -f
sudo docker system prune -f
