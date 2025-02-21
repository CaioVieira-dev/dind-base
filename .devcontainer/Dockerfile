# Base image
FROM ubuntu:24.04

# Install minimal dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    git \
    iptables \
    e2fsprogs \
    xfsprogs \
    btrfs-progs \
    pigz \
    openssl \
    xz-utils \
    iproute2 \
    sudo \
    gnupg \
    lsb-release \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce docker-ce-cli containerd.io \
    && rm -rf /var/lib/apt/lists/*

# Configure user namespace remap
RUN addgroup dockremap \
    && adduser --system --ingroup dockremap dockremap \
    && echo 'dockremap:165536:65536' >> /etc/subuid \
    && echo 'dockremap:165536:65536' >> /etc/subgid

# Create a vscode user for development
RUN useradd -ms /bin/bash vscode \
    && usermod -aG sudo vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Create workspace and set permissions
RUN mkdir -p /workspace \
    && chown -R vscode:vscode /workspace

# Set workspace as working directory
WORKDIR /workspace

# Create volume for docker data
VOLUME /var/lib/docker

# Expose ports (both TLS and non-TLS)
EXPOSE 2376

# Switch to the vscode user
USER vscode

CMD ["/bin/bash"]
