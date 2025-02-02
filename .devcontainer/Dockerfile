# Base image
FROM ubuntu:24.04

# basic dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git 

# region Install Docker
# docker dependencies
RUN apt-get install -y \
    apt-transport-https \
    ca-certificates \
    software-properties-common  \
    lsb-release

# Add docker official GPG
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

# Add docker repository
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

# install docker
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# endregion Docker instalando

# Define workdir
WORKDIR /workspace

# Expose docker daemon port
EXPOSE 2376
