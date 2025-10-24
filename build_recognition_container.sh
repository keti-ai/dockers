#!/bin/bash

# ======================= DEFAULTS =======================
SHARE_DIR=""
CONTAINER_NAME="reg_u22cu11"
IMAGE_NAME="mtbui2010/ubuntu22:cuda11.7-recognition"

# ======================= ARGUMENT PARSING =======================
for arg in "$@"; do
    case $arg in
        --name=*)
            CONTAINER_NAME="${arg#*=}"
            ;;
        --image-name=*)
            IMAGE_NAME="${arg#*=}"
            ;;
        --share-dir=*)
            SHARE_DIR="${arg#*=}"
            ;;
        *)
            echo "❌ Unknown argument: $arg"
            echo "Usage: $0 [--name=<container_name>] [--image-name=<image_name>] [--share-dir=<path_to_share_dir>]"
            exit 1
            ;;
    esac
done

# ======================= DISPLAY CONFIG =======================
echo "======================================="
echo "Container:  ${CONTAINER_NAME}"
echo "Share dir:  ${SHARE_DIR:-<none>}"
echo "Image tag:  ${IMAGE_NAME}"
echo "======================================="

# ======================= DOCKER RUN =======================
DOCKER_CMD=(
    sudo docker run
    --name "$CONTAINER_NAME"
    -it
    -d
    --gpus all
    --privileged
    --env="DISPLAY=:0.0"
    -v /tmp/.X11-unix:/tmp/.X11-unix:ro
    --ipc host
    --net host
)

# Mount SHARE_DIR as /workdir if provided
if [[ -n "$SHARE_DIR" ]]; then
    DOCKER_CMD+=(-v "${SHARE_DIR}:/workdir" -w /workdir)
fi

# Add image name
DOCKER_CMD+=("$IMAGE_NAME")

# ======================= EXECUTE =======================
echo "Running: ${DOCKER_CMD[*]}"
"${DOCKER_CMD[@]}"

