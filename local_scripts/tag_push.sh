source ../container-name.sh
set -x
docker images
docker tag reslocal/${CONTAINER_NAME}:latest reliableembeddedsystems/${CONTAINER_NAME}:latest
docker images
docker login --username reliableembeddedsystems
docker push reliableembeddedsystems/${CONTAINER_NAME}:latest
set +x
