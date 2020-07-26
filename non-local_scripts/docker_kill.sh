source ../container-name.sh

IMAGE_NAME=$1
#NETWORK_INTERFACE=$2

#TAG="latest"

if [ $# -lt 1 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <docker image>"
    echo "+ $0 reliableembeddedsystems/${CONTAINER_NAME}:${TAG}"
    echo "+ $0 reliableembeddedsystems/${CONTAINER_NAME}:${TAG}"
    exit
fi

# remove currently running containers
set -x
ID_TO_KILL=$(docker ps -a -q  --filter ancestor=$1)

docker ps -a
docker stop ${ID_TO_KILL}
docker rm -f ${ID_TO_KILL}
docker ps -a
set +x
