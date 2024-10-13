#!/bin/bash

. docker_common.bash
${compose_cmd} stop

./de-isolate_private_bridge.sh
