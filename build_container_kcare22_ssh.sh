DOCKERFILE=Dockerfile22ssh
IMAGE_NAME=mtbui2010/ubuntu22.04:cuda11.7-ros.humble-ssh
CONTAINER_NAME=kcare22ssh
SHARE_DIR=/media/keti/workdir/projects

sudo docker build --tag $IMAGE_NAME  - < $DOCKERFILE

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
-p 2222:22 \
-p 8800-8809:8800-8809 \
$IMAGE_NAME
#--net host \
