DOCKERFILE=Dockerfile22
IMAGE_NAME=mtbui2010/ubuntu22.04:cuda.11.7-ros.humble-kcare
CONTAINER_NAME=kcare22
SHARE_DIR=/media/keti/workdir/projects

sudo docker build --tag $IMAGE_NAME  - < $DOCKERFILE

sudo docker run \
--name $CONTAINER_NAME \
-it \
--gpus all \
--net host \
--privileged \
--env="DISPLAY=:0.0" \
-v=/tmp/.X11-unix:/tmp/.X11-unix:ro \
-v=/dev:/dev \
-v=$SHARE_DIR:$SHARE_DIR \
-w=$SHARE_DIR \
$IMAGE_NAME
