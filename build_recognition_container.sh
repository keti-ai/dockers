#!/bin/bash

echo "Usage: $0 <SSH_PORT> <PORT_MAP> <SHARE_DIR> <IMAGE_NAME> <CONTAINER_NAME>"


SSH_PORT=${1:-2202}
PORT_MAP=${2:-8000-8099:8000-8099}
SHARE_DIR=${3:-/media/keti/workdir/projects}
IMAGE_NAME=${4:-mtbui2010/ubuntu22:cuda11.7-recognition}
CONTAINER_NAME=${5:-reg_u22cu11}

# ======================= BUILD PROCESS =======================
DOCKERFILE=Dockerfile

echo "======================================="
echo "🚀 Building Docker container"
echo "SSH Port:    ${PORT}"
echo "Port Map:      ${PORT_MAP}"
echo "Share Dir:     ${SHARE_DIR}"
echo "Image: ${IMAGE_NAME}"
echo "Container: 	 ${CONTAINER_NAME}"
echo "======================================="

sudo docker pull $IMAGE_NAME

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
-p ${SSH_PORT}:22 \
-p ${PORT_MAP} \
$IMAGE_NAME \
bash -c "mkdir -p $SHARE_DIR && cd $SHARE_DIR && exec bash"
#--net host \
