#!/bin/bash
source ../container-name.sh

if [ $# -lt 1 ];
then
    echo "+ $0: Too few arguments!"
    echo "+ use something like:"
    echo "+ $0 <BASE_DISTRO>"
    echo "+ $0 ubuntu-16.04"
    exit
fi

pushd ..
#export BASE_DISTRO="ubuntu-16.04"
export BASE_DISTRO="${1}"
export REPO="reslocal/${CONTAINER_NAME}"
export BUILD_ONLY="yes"
./build-and-test.sh
popd
