source ../container-name.sh

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "./special_tag_push.sh <tag>"
    echo "./special_tag_push.sh ubuntu-18.04 ${TAG}"
    exit
fi

set -x
docker images
docker tag reslocal/${CONTAINER_NAME}:$1 reliableembeddedsystems/${CONTAINER_NAME}:$2
docker images
docker login --username reliableembeddedsystems
docker push reliableembeddedsystems/${CONTAINER_NAME}:$2
set +x
