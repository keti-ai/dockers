#!/bin/bash

# ======================= DEFAULTS =======================
UBUNTU_VERSION="22.04"
CUDA_VERSION="12.6.3"
ROS_DISTRO="humble"
PORT=""
PORT_MAP=""
SHARE_DIR=""
CONTAINER_NAME=""

# ======================= ARGUMENT PARSING =======================
for arg in "$@"; do
    case $arg in
        --ubuntu=*)
            UBUNTU_VERSION="${arg#*=}"
            ;;
        --cuda=*)
            CUDA_VERSION="${arg#*=}"
            ;;
        --ros=*)
            ROS_DISTRO="${arg#*=}"
            ;;
        --name=*)
            CONTAINER_NAME="${arg#*=}"
            ;;
        --port=*)
            PORT="${arg#*=}"
            ;;
        --port-map=*)
            PORT_MAP="${arg#*=}"
            ;;
        --share-dir=*)
            SHARE_DIR="${arg#*=}"
            ;;
        *)
            echo "❌ Unknown argument: $arg"
            echo "Usage: $0 [--ubuntu=] [--cuda=] [--ros=] [--name=] [--port=] [--port-map=] [--share-dir=]"
            exit 1
            ;;
    esac
done

# Generate default container name if not provided
if [[ -z "$CONTAINER_NAME" ]]; then
    UBUNTU_MAJOR=${UBUNTU_VERSION%%.*}
    CUDA_MAJOR=${CUDA_VERSION%%.*}
    CONTAINER_NAME="u${UBUNTU_MAJOR}cu${CUDA_MAJOR}"
fi

# ======================= DISPLAY CONFIG =======================
IMAGE_NAME="mtbui2010/ubuntu${UBUNTU_VERSION}:cuda${CUDA_VERSION}-ros2${ROS_DISTRO}"

echo "======================================="
echo "🚀 Running Docker Container"
echo "Ubuntu:     ${UBUNTU_VERSION}"
echo "CUDA:       ${CUDA_VERSION}"
echo "ROS 2:      ${ROS_DISTRO}"
echo "Container:  ${CONTAINER_NAME}"
echo "Port:       ${PORT:-<host network>}"
echo "Port MAP:   ${PORT_MAP:-<host network>}"
echo "Share dir:  ${SHARE_DIR:-<none>}"
echo "Image tag:  ${IMAGE_NAME}"
echo "======================================="

# ======================= DOCKER RUN =======================
DOCKER_CMD=(sudo docker run
    --name "$CONTAINER_NAME"
    -it
    -d
    --gpus all
    --privileged
    --env="DISPLAY=:0.0"
    -v=/tmp/.X11-unix:/tmp/.X11-unix:ro
    --ipc host
)

# Conditionally mount SHARE_DIR
if [[ -n "$SHARE_DIR" ]]; then
    DOCKER_CMD+=(-v "${SHARE_DIR}:${SHARE_DIR}" -w "${SHARE_DIR}")
fi

# Conditionally expose ports or fallback to host networking
if [[ -n "$PORT" || -n "$PORT_MAP" ]]; then
    [[ -n "$PORT" ]] && DOCKER_CMD+=(-p "${PORT}:22")
    [[ -n "$PORT_MAP" ]] && DOCKER_CMD+=(-p "${PORT_MAP}")
else
    DOCKER_CMD+=(--net host)
fi

# Add image name
DOCKER_CMD+=("$IMAGE_NAME")

# ======================= EXECUTE =======================
"${DOCKER_CMD[@]}"
