# Copyright (c) 2019-2024 Toradex AG
# SPDX-License-Identifier: MIT

ARG DEBIAN_POINT_RELEASE
ARG REGISTRY_PROXY

FROM $REGISTRY_PROXY/debian:$DEBIAN_POINT_RELEASE AS base

ARG DEBIAN_FRONTEND=noninteractive
ARG TORADEX_FEED_URL
ARG TORADEX_SNAPSHOT

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        sudo \
        ca-certificates \
        netbase \
        gpg \
        wget \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL C.UTF-8

COPY 01_nodoc /etc/dpkg/dpkg.cfg.d/01_nodoc

RUN echo 'APT::Get::Assume-Yes "true";\n\
    APT::Install-Recommends "0";\n\
    APT::Install-Suggests "0";\n\
    quiet "true";' > /etc/apt/apt.conf.d/01_buildconfig \
    && mkdir -p /usr/share/man/man1

COPY users-groups.sh /users-groups.sh
RUN ./users-groups.sh \
    && rm users-groups.sh

RUN wget -O- ${TORADEX_FEED_URL}/toradex-debian-repo-07102024.gpg \
    | gpg --dearmor \ 
    | tee /usr/share/keyrings/toradex-debian-repo.gpg

RUN echo "Types: deb\n\
URIs: ${TORADEX_FEED_URL}/snapshots/${TORADEX_SNAPSHOT}\n\
Suites: stable\n\
Components: main non-free\n\
Signed-By: /usr/share/keyrings/toradex-debian-repo.gpg" > /etc/apt/sources.list.d/toradex.sources \
    && echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds

RUN apt-get -y update && apt-get install -y --no-install-recommends \
    fastfetch \
    && apt-get clean && apt-get autoremove && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which fastfetch) /usr/local/bin/neofetch

CMD ["/bin/bash"]
