#################### Build Arguments
ARG UBUNTU_VERSION=22.04
ARG CUDA_VERSION=11.7.1
ARG ROS_DISTRO=humble
ARG PULL_IMAGE=nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}

#################### Base Image
FROM ${PULL_IMAGE}

ARG UBUNTU_VERSION
ARG CUDA_VERSION
ARG ROS_DISTRO

#################### Environment Variables
ENV TZ=Asia/Seoul \
    ROSWS=/root/ros2_ws \
    DEBIAN_FRONTEND=noninteractive

#################### Print Build Information
RUN echo "======================================="
RUN echo "🚀 Building Docker Image"
RUN echo "Ubuntu:    ${UBUNTU_VERSION}"
RUN echo "CUDA:      ${CUDA_VERSION}"
RUN echo "ROS 2:     ${ROS_DISTRO}"
RUN echo "======================================="

#################### Set Timezone & Install Utilities
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update
RUN apt-get install -y --no-install-recommends python3-pip git net-tools 
RUN apt-get install -y --no-install-recommends iputils-ping nano ffmpeg libsm6 libxext6 
RUN apt-get install -y --no-install-recommends openssh-server 
RUN apt-get install -y --no-install-recommends curl gnupg2 lsb-release 

RUN rm -rf /var/lib/apt/lists/*

#################### SSH Configuration
RUN sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo 'ListenAddress 0.0.0.0' >> /etc/ssh/sshd_config && \
    echo "root:1" | chpasswd

#################### Install Python Packages
RUN pip install --upgrade pip
RUN pip install opencv-python==4.5.5.64  
RUN pip install numpy==1.26.4
RUN pip install pyrealsense2 
RUN pip install gdown 
RUN pip install imutils 
RUN pip install scikit-learn 
RUN pip install scikit-image 
RUN pip install Cython==0.29.33 
RUN pip install Pillow==9.5.0 

RUN /bin/bash -c ' \
    echo "Using Ubuntu ${UBUNTU_VERSION} with CUDA ${CUDA_VERSION}"; \
    if [ "${UBUNTU_VERSION}" = "20.04" ]; then \
      pip install torch==1.10.1+cu111 torchvision==0.11.2+cu111 torchaudio==0.10.1 -f https://download.pytorch.org/whl/cu111/torch_stable.html; \
    elif [ "${UBUNTU_VERSION}" = "22.04" ]; then \
      if [ "${CUDA_VERSION}" = "11.7.1" ]; then \
        pip install torch==1.13.1+cu117 torchvision==0.14.1+cu117 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu117; \
      elif [ "${CUDA_VERSION}" = "12.1.0" ]; then \
        pip install torch==2.5.1 torchvision==0.20.1 torchaudio==2.5.1 --index-url https://download.pytorch.org/whl/cu121; \
      else \
        echo "❌ Unsupported"; \
      fi; \
    elif [ "${UBUNTU_VERSION}" = "24.04" ]; then \
      pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu126; \
    else \
      echo "❌ Unsupported"; \
    fi'


#################### Install ROS 2
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    sh -c 'echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list' 
RUN apt update
RUN echo $ROS_DISTRO
RUN apt install -y ros-${ROS_DISTRO}-ros-base 
RUN apt install -y \
    ros-$ROS_DISTRO-cv-bridge \
    ros-$ROS_DISTRO-rqt \
    ros-$ROS_DISTRO-rqt-common-plugins \
    python3-colcon-common-extensions \
    python3-pip \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/*

#################### Initialize ROS 2
RUN rosdep init && rosdep update && \
    echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc

#################### Setup ROS 2 Workspace
RUN mkdir -p ${ROSWS}/src && \
    cd ${ROSWS} && \
    /bin/bash -c "source /opt/ros/${ROS_DISTRO}/setup.bash && colcon build" && \
    echo "source ${ROSWS}/install/local_setup.bash" >> /root/.bashrc

#################### Add Useful Aliases
RUN echo "ROS_DISTRO=${ROS_DISTRO}" >> /root/.bashrc
RUN echo "alias eb='nano ~/.bashrc'" >> /root/.bashrc
RUN echo "alias sb='source ~/.bashrc'" >> /root/.bashrc
RUN echo "alias about_pc='lsb_release -a'" >> /root/.bashrc
RUN echo "alias sr='source /opt/ros/\$ROS_DISTRO/setup.bash'" >> /root/.bashrc
RUN echo "alias srs='source ~/ros2_ws/install/setup.bash'" >> /root/.bashrc
    

#################### Expose SSH Port & Start SSH on Container Startup
EXPOSE 22
ENTRYPOINT service ssh start && bash
CMD ["/usr/sbin/sshd", "-D"]

