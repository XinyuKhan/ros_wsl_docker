FROM osrf/ros:humble-desktop


RUN apt-get update && apt-get -y upgrade && apt-get -y install \
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
    mesa-utils-extra \
    && apt-get -y autoremove \
    && apt-get clean

ENV LD_LIBRARY_PATH=/usr/lib/wsl/lib
ENV LIBVA_DRIVER_NAME=d3d12
ENV MESA_D3D12_DEFAULT_ADAPTER_NAME=NVIDIA

# 此处为了解决nv驱动报错问题，如果没有报错直接忽略
#RUN rm -rf \
#    /usr/lib/x86_64-linux-gnu/libcuda.so* \
#    /usr/lib/x86_64-linux-gnu/libnvcuvid.so* \
#    /usr/lib/x86_64-linux-gnu/libnvidia-*.so* \
#    /usr/lib/x86_64-linux-gnu/libcudadebugger.so*




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
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.5/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'



