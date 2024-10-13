#!/bin/bash

sudo docker save -o images/docker-internal.image docker-internal
sudo docker save -o images/docker-gateway.image docker-gateway
