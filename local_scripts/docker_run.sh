source ../container-name.sh
IMAGE_NAME=$1

PUBLIC_PORT="1984"

if [ $# -lt 1 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <docker image>" 
    echo "+ $0 reslocal/${CONTAINER_NAME}"
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

# -t : Allocate a pseudo-tty
# -i : Keep STDIN open even if not attached
# -d : To start a container in detached mode, you use -d=true or just -d option.
# -p : publish port PUBLIC_PORT:INTERNAL_PORT
# -l : ??? without it no root@1928719827
# --cap-drop=all: drop all (root) capabilites

# start ash shell - need to start redis manually
#echo "+ ID=\$(docker run --cap-drop=all -t -i -d -p ${PUBLIC_PORT}:6379 ${IMAGE_NAME} ash -l)"
#ID=$(docker run --cap-drop=all -t -i -d -p ${PUBLIC_PORT}:6379 ${IMAGE_NAME} ash -l)
echo "+ ID=\$(docker run -t -i -d -p ${PUBLIC_PORT}:1883 ${IMAGE_NAME})"
ID=$(docker run -t -i -d -p ${PUBLIC_PORT}:1883 ${IMAGE_NAME})

echo "+ ID ${ID}"

# let's attach to it:
echo "+ docker attach ${ID}"
docker attach ${ID}
