#!/bin/bash

# create a directory to store user passwords
mkdir -p ./scripts/e2e/registry_auth

# use htpasswd to create an encrypted file
htpasswd -Bbn test 1234 > ./scripts/e2e/registry_auth/htpasswd

# check if there is a container named registry
if [ "$(docker ps -aq -f name=registry)" ]; then
    # stop and remove the container named registry
    docker stop registry
    docker rm registry
fi

# start the Docker Registry with authentication
docker run -p 5001:5000 \
--restart=always \
--name registry \
-v /var/lib/registry:/var/lib/registry \
-v $PWD/scripts/e2e/registry_auth/:/auth/ \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
-d registry

# clean the registry
docker exec registry rm -rf /var/lib/registry/docker/registry/v2/repositories/
