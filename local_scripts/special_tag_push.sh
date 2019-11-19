if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "./special_tag_push.sh <tag>"
    exit
fi

source ../container-name.sh

set -x
docker images
docker tag reslocal/${CONTAINER_NAME}:latest reliableembeddedsystems/${CONTAINER_NAME}:$1
docker images
docker login --username reliableembeddedsystems
docker push reliableembeddedsystems/${CONTAINER_NAME}:$1
set +x
