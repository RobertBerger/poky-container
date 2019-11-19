if [ "$#" -ne 1 ]; then
    echo "Usage:"
    echo "./special_tag_push.sh <tag>"
    echo "./special_tag_push.sh ubuntu-16.04"
    exit
fi

source ../container-name.sh

set -x
docker images
docker tag reslocal/${CONTAINER_NAME}:$1 reliableembeddedsystems/${CONTAINER_NAME}:$1
docker images
docker login --username reliableembeddedsystems
docker push reliableembeddedsystems/${CONTAINER_NAME}:$1
set +x
