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

ARG     VERSION=20.10
FROM 	docker:$VERSION-dind

ARG 	TARGETPLATFORM
ARG 	TARGETARCH
ARG 	TARGETVARIANT
LABEL   author="Ademar Arvati Filho" maintainer="arvati@hotmail.com"
LABEL   org.opencontainers.image.source="https://github.com/arvati/pterodactyl-images"
LABEL   org.opencontainers.image.licenses=MIT
RUN     apk add --update --no-cache ca-certificates curl iproute2 fuse-overlayfs git \
			openssl sqlite tar tzdata python3 && \
    		python3 -m ensurepip && \
    		rm -r /usr/lib/python*/ensurepip && \
    		pip3 install --upgrade pip setuptools && \
    		if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    		if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    		rm -r /root/.cache && \
    		pip install docker-compose

RUN 	mkdir /run/user && chmod 1777 /run/user

RUN set -eux; \
	adduser -h /home/container -g 'Rootless' -D -u 1000 container; \
	echo 'container:100000:65536' >> /etc/subuid; \
	echo 'container:100000:65536' >> /etc/subgid

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-20.10.17.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-rootless-extras-20.10.17.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'rootless.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'rootless.tgz' "$url"; \
	\
	tar --extract \
		--file rootless.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		'docker-rootless-extras/rootlesskit' \
		'docker-rootless-extras/rootlesskit-docker-proxy' \
		'docker-rootless-extras/vpnkit' \
	; \
	rm rootless.tgz;

RUN set -eux; \
	mkdir -p /home/container/.local/share/docker; \
	chown -R container:container /home/container/.local/share/docker

VOLUME /home/container/.local/share/docker

USER    container
ENV     USER=container HOME=/home/container \
			PLATFORM=$TARGETPLATFORM ARCH=$TARGETARCH VARIANT=$TARGETVARIANT
WORKDIR /home/container
COPY    ./entrypoint.sh /entrypoint.sh
CMD     [ "/bin/ash", "/entrypoint.sh" ]