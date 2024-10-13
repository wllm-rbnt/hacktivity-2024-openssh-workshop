#!/bin/bash

. docker_common.bash
${compose_cmd} up -d

echo
echo "################################"
echo "################################"
./isolate_private_bridge.sh
echo
echo "################################"
echo "################################"
./get_info.sh
