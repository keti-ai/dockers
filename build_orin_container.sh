#!/bin/bash

UBUNTU_VERSION=${1:-22.04}
CUDA_VERSION=${2:-12.4.1}
ROS_DISTRO=${3:-humble}
CONTAINER_NAME=${4:-carebot}
SHARE_DIR=${5:-/workdir}
HOST_DIR=${6:-~/docker/carebot}

# ======================= BUILD PROCESS =======================
DOCKERFILE=Dockerfile
IMAGE_NAME="mtbui2010/ubuntu${UBUNTU_VERSION}:cuda${CUDA_VERSION}-ros2${ROS_DISTRO}"

echo "======================================="
echo "🚀 Building Docker Image"
echo "Ubuntu:    ${UBUNTU_VERSION}"
echo "CUDA:      ${CUDA_VERSION}"
echo "ROS 2:     ${ROS_DISTRO}"
echo "Container: ${CONTAINER_NAME}"
echo "Share dir: ${SHARE_DIR}"
echo "Tag:       ${IMAGE_NAME}"
echo "======================================="

sudo docker run \
--name $CONTAINER_NAME \
-it \
--runtime nvidia \
--net host \
--ipc host \
--privileged \
--env="DISPLAY=$DISPLAY" \
-v=/tmp/.X11-unix:/tmp/.X11-unix:ro \
-v=/dev:/dev \
-v=$HOST_DIR:$SHARE_DIR \
-w=$SHARE_DIR \
$IMAGE_NAME

