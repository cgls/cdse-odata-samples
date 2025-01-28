#!/bin/bash
# set -e
dir=$(dirname $0)

DOCKER_IMAGE="vito-docker.artifactory.vgt.vito.be/clms_metadata:latest"
docker image pull $DOCKER_IMAGE

while IFS="," read -r name path
do 
    echo $name
    docker run --rm -a stdout -a stderr -v /data/MTDA/:/data/MTDA/ $DOCKER_IMAGE odata create $path | jq . > $name.json
done < <(tail -n +2 $dir/local.csv)