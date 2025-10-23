#!/bin/bash

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
            echo "Usage: $0[--name=] [--image-name] [--share-dir=]"
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
DOCKER_CMD=(sudo docker run
    --name "$CONTAINER_NAME"
    -it
    -d
    --gpus all
    --privileged
    --env="DISPLAY=:0.0"
    -v=/tmp/.X11-unix:/tmp/.X11-unix:ro
    --ipc host
    --net host
)

# Conditionally mount SHARE_DIR
if [[ -n "$SHARE_DIR" ]]; then
    DOCKER_CMD+=(-v "${SHARE_DIR}:${SHARE_DIR}" -w "${SHARE_DIR}")
fi

# Add image name
DOCKER_CMD+=("$IMAGE_NAME")

# ======================= EXECUTE =======================
"${DOCKER_CMD[@]}"




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
