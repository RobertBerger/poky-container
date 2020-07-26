source ../container-name.sh
IMAGE_NAME=$1

# from container-name.sh
#TAG="v1.1.0"

if [ $# -lt 1 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <docker image>" 
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

# we need to pull latest version
docker pull ${IMAGE_NAME}

# -t : Allocate a pseudo-tty
# -i : Keep STDIN open even if not attached
# -d : To start a container in detached mode, you use -d=true or just -d option.
# -p : publish port PUBLIC_PORT:INTERNAL_PORT
# -l : ??? without it no root@1928719827
# --cap-drop=all: drop all (root) capabilites

# start ash shell
ID=$(docker run -v ${PWD}/../../../:/workdir -t -i -d ${IMAGE_NAME} /bin/sh -l)

# let's attach to it:
docker attach ${ID}
set +x
