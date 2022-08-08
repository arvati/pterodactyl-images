#
# Copyright (c) 2021 Ademar Arvati Filho
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

ARG     VERSION=17
FROM    eclipse-temurin:$VERSION-jre-focal
ARG 	TARGETPLATFORM
ARG 	TARGETARCH
ARG 	TARGETVARIANT
LABEL   author="Ademar Arvati Filho" maintainer="arvati@hotmail.com"
LABEL   org.opencontainers.image.source="https://github.com/arvati/pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT
ENV     DEBIAN_FRONTEND=noninteractive
RUN     apt update && apt upgrade -y \
            && apt install --no-install-recommends -y curl ca-certificates \
            openssl git tar sqlite fontconfig tzdata iproute2 \
            net-tools tzdata wget mongodb-server-core \
            && useradd -d /home/container -m container
USER    container
ENV     DEBIAN_FRONTEND=dialog USER=container HOME=/home/container \
            PLATFORM=$TARGETPLATFORM ARCH=$TARGETARCH VARIANT=$TARGETVARIANT
WORKDIR /home/container
EXPOSE  8088 8043 8843 29810/udp 29811 29812 29813 29814
COPY    ./entrypoint.sh /entrypoint.sh
CMD     [ "/bin/bash", "/entrypoint.sh" ]

 

 
