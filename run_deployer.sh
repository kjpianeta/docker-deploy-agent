#!/usr/bin/env bash

set -ex
DOCKER_IMAGE=docker-deploy-agent:20160712-1500
DOCKERFILE_URL=

function _build_docker_image(){

if [[ "$(docker images -q "${DOCKER_IMAGE}" 2> /dev/null)" == "" ]]; then

fi

}
function _run_lite(){
        docker run \
                --rm \
                -ti \
                --volume `pwd`:/opt/cisco/deployer \
                --volume $SSH_AUTH_SOCK:/ssh-agent:ro \
                --env "${OS_AUTH_URL?:Need to set OS_AUTH_URL}" \
                --env "${OS_TENANT_ID?:Need to set OS_TENANT_ID}" \
                --env "${OS_TENANT_NAME?:Need to set OS_TENANT_NAME}" \
                --env "${OS_PROJECT_NAME?:Need to set OS_PROJECT_NAME}" \
                --env "${OS_USERNAME?:Need to set OS_USERNAME}" \
                --env "${OS_PASSWORD?:Need to set OS_PASSWORD}" \
                --env "${OS_REGION_NAME?:Need to set OS_REGION_NAME}" \
                --env "${SSH_AUTH_SOCK?:Need to set SSH_AUTH_SOCK}" \
                "${DOCKER_IMAGE}"
                "$@"
}

_run_lite