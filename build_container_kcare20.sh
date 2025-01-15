DOCKERFILE=Dockerfile20
IMAGE_NAME=mtbui2010/ubuntu20.04:cuda11.1-ros.foxy-kcare
CONTAINER_NAME=kcare20

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
-v=/media/keti/workspace/docker_share/ros2care:/home/keti/workspace \
-w=/home/keti/workspace \
$IMAGE_NAME
