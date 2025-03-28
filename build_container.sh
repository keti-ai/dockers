#!/bin/bash

# ======================= INPUT VALIDATION =======================
# Check if the correct number of arguments is provided
if [ $# < 3 ]; then
    echo "Usage: $0 <UBUNTU_VERSION> <CUDA_VERSION> <ROS_DISTRO> <CONTAINER_NAME> <SHARE_DIR>"
    exit 1
fi

UBUNTU_VERSION=${1:-22.04}
CUDA_VERSION=${2:-11.7.1}
ROS_DISTRO=${3:-humble}
CONTAINER_NAME=${4:-kcare}
PORT=${5:-2222}
PORT_MAP=${6:-8800-8809:8800-8809}
SHARE_DIR=${7:-/media/keti/workdir/projects}

# ======================= BUILD PROCESS =======================
DOCKERFILE=Dockerfile
IMAGE_NAME="mtbui2010/ubuntu${UBUNTU_VERSION}:cuda${CUDA_VERSION}-ros2${ROS_DISTRO}"

echo "======================================="
echo "🚀 Building Docker Image"
echo "Ubuntu:    ${UBUNTU_VERSION}"
echo "CUDA:      ${CUDA_VERSION}"
echo "ROS 2:     ${ROS_DISTRO}"
echo "Container: ${CONTAINER_NAME}"
echo "Port: 	 ${PORT}"
echo "Port MAP:  ${PORT_MAP}"
echo "Share dir: ${SHARE_DIR}"
echo "Tag:       ${IMAGE_NAME}"
echo "======================================="

sudo docker run \
--name $CONTAINER_NAME \
-it \
-d \
--gpus all \
--privileged \
--env="DISPLAY=:0.0" \
-v=/tmp/.X11-unix:/tmp/.X11-unix:ro \
-v=/dev:/dev \
-v=$SHARE_DIR:$SHARE_DIR \
-w=$SHARE_DIR \
-p ${PORT}:22 \
-p ${PORT_MAP} \
$IMAGE_NAME
#--net host \
