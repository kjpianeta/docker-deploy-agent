#!/usr/bin/env bash

set -ex
ORIG_DIR=`pwd`
TEMP_DIR=`mktemp -d -t docker_deploy_agent`
TEMP_DOCKER_IMAGE=temp_docker-deploy-agent:20160712-1500
DOCKER_IMAGE=docker-deploy-agent:20160712-1500
DOCKERFILE_URL=https://raw.githubusercontent.com/kjpianeta/docker-deploy-agent/master/Dockerfile


function _build_docker_image(){

    if [[ "$(docker images -q "${DOCKER_IMAGE}" 2> /dev/null)" == "" ]]; then
        echo "Image not present in local repo. Creating..."
#        wget -P "${TEMP_DIR}" "${DOCKERFILE_URL}"
        cp -p Dockerfile "${TEMP_DIR}"
        _temp_image_id="$(docker build -q --force-rm "${TEMP_DIR}")"
        _temp_container_id="$(docker run -d "${_temp_image_id}" /bin/bash)"
        echo "Temp container id: ""${_temp_container_id}"
        (docker export "${_temp_container_id}" | docker import – "${DOCKER_IMAGE}")
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

_build_docker_image
#_run_lite