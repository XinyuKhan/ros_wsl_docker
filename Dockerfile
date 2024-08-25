FROM osrf/ros:humble-desktop-full

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt upgrade -y

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt install -y \
    libxext-dev \
    libx11-dev \
    libglvnd-dev \
    libglx-dev \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    libegl1-mesa-dev \
    libgles2-mesa-dev \
    freeglut3-dev \
    mesa-utils \
    mesa-utils-extra

ENV LD_LIBRARY_PATH=/usr/lib/wsl/lib
ENV LIBVA_DRIVER_NAME=d3d12
ENV MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA


# Tools
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt install -y \
    vim \
    git \
    curl \
    wget \
    zsh \
    tmux \
    htop \
    gdb \
    net-tools \
    ros-humble-gazebo-ros-pkgs \
    libpoco-dev

# perf
RUN apt update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt install -y \
    build-essential \
    flex \
    bison \
    libssl-dev \
    libelf-dev \
    libbabeltrace-dev \
    libunwind-dev \
    libdw-dev \
    binutils-dev \
    libiberty-dev \
    libtraceevent-dev

RUN git clone --depth=1 https://github.com/microsoft/WSL2-Linux-Kernel.git /tmp/linux-kernel && \
    cd /tmp/linux-kernel/tools/perf && make && cp perf /usr/bin/ && \
    cd /tmp && rm -rf linux-kernel


# USER
ARG USERNAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo wget \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME

WORKDIR /home/$USERNAME


# Oh My Zsh
COPY ./zsh-in-docker.sh /tmp/zsh-in-docker.sh
RUN sh /tmp/zsh-in-docker.sh -- \
    -t https://github.com/romkatv/powerlevel10k.git \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p history \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

RUN echo "source /opt/ros/$ROS_DISTRO/setup.zsh" >> ~/.zshrc && \
    echo "eval \"\$(register-python-argcomplete3 ros2)\"" >> ~/.zshrc && \
    echo "eval \"\$(register-python-argcomplete3 colcon)\"" >> ~/.zshrc && \
    echo "export PATH=\$PATH:/home/$USERNAME/clion/bin" >> ~/.zshrc
