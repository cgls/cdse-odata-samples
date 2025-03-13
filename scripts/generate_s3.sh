#!/bin/bash

set -e
dir=$(dirname $0)

DOCKER_IMAGE="vito-docker.artifactory.vgt.vito.be/clms_metadata:latest"
docker image pull $DOCKER_IMAGE

profiles=$(aws configure list-profiles)

while IFS="," read -r profile name path
do 
    echo $name
    profile_name=$(echo "$profiles" | grep $profile | head -1)
    echo "Using AWS CLI profile $profile_name"
    eval $(aws configure export-credentials --format env --profile $profile_name)
    export AWS_ENDPOINT_URL=$(aws configure --profile $profile_name get endpoint_url)
    # using virtual filesystem with netCDF driver in Docker requires userfaultd system call, so set security-opt to allow it
    docker run --rm --security-opt seccomp=unconfined -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY -e AWS_ENDPOINT_URL -a stdout -a stderr  $DOCKER_IMAGE odata create $path | python3 -m json.tool --indent 2 > $name.json
done < <(tail -n +2 $dir/s3.csv)
