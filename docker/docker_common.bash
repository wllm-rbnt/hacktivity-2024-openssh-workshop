#!/bin/bash

compose_cmd="sudo docker compose"

echo "Testing 'docker compose' command ..."
${compose_cmd} &>/dev/null
ret=$?
if [[ ${ret} != 0 ]]; then
    echo "It's not working as expected ..."
    echo "Falling back to 'docker-compose' instead ..."
    compose_cmd="sudo docker-compose"

    ${compose_cmd} &>/dev/null
    ret=$?
    if [[ ${ret} != 0 ]]; then
        echo "'docker-compose' not working either, exiting ..."
        exit 1
    fi
fi

${compose_cmd} version | grep -qE "v2\."
ret=$?
if [[ ${ret} != 0 ]]; then
    echo "docker compose version 2 not detected, continuing anyway ... we'll see"
else
    echo "docker compose version 2 detected, looks promising ..."
fi

export compose_cmd
