source ../container-name.sh
IMAGE_NAME=$1
NETWORK_INTERFACE=$2

PUBLIC_PORT="6379"

#TAG="20190420065849-poky-2.7-plus-snapshot"
TAG="latest"

if [ $# -lt 2 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <docker image> <network interface>"
    echo "+ $0 reliableembeddedsystems/${CONTAINER_NAME}:${TAG} docker0"
    echo "+ $0 reliableembeddedsystems/${CONTAINER_NAME}:${TAG} br0"
    exit
fi

# remove currently running containers
echo "+ ID_TO_KILL=\$(docker ps -a -q  --filter ancestor=$1)"
ID_TO_KILL=$(docker ps -a -q  --filter ancestor=$1)

echo "+ docker ps -a"
docker ps -a
echo "+ docker stop ${ID_TO_KILL}"
docker stop ${ID_TO_KILL}
echo "+ docker rm -f ${ID_TO_KILL}"
docker rm -f ${ID_TO_KILL}
echo "+ docker ps -a"
docker ps -a

echo "+ ID=\$(docker run -t -i -d -p ${PUBLIC_PORT}:6379 ${IMAGE_NAME})"
ID=$(docker run -t -i -d -p ${PUBLIC_PORT}:6379 ${IMAGE_NAME})

echo "+ ID ${ID}"

# let's attach to it:
echo "+ docker attach ${ID}"
docker attach ${ID}
