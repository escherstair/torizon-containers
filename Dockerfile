ARG IMAGE_ARCH=arm64v8
FROM $IMAGE_ARCH/debian:bullseye

# Install a base set of build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    aptly \
    bash-completion \
    build-essential:native \
    ca-certificates \
    curl \
    debconf \
    debhelper \
    debmake \
    debootstrap \
    devscripts \
    dh-make \
    dh-python \
    dpkg-dev \
    equivs \
    execstack \
    fakeroot \
    git \
    git-buildpackage \
    gnupg \
    libpng16-16 \
    libtool \
    netbase \
    openssh-client \
    pbuilder \
    pkg-config \
    procps \
    python3-debian \
    rsync \
    sudo \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Use UID 1000 to build packages.
# Replace to the id of your user in the host.
RUN useradd debian -u 1000 -m -G tty,sudo,dialout,users,plugdev

# Tell sudo not to ask for passwords for users of the sudo group
RUN sed -i '/^%sudo\>/s/) *ALL$/) NOPASSWD: ALL/' /etc/sudoers && visudo -c

# Setup access to Debian official package sources
RUN echo 'deb-src http://deb.debian.org/debian bullseye main' >>/etc/apt/sources.list

# Setup access to Debian official package updates
RUN echo 'deb http://deb.debian.org/debian bullseye-updates main' >>/etc/apt/sources.list
RUN echo 'deb-src http://deb.debian.org/debian bullseye-updates main' >>/etc/apt/sources.list

# Setup access to the Toradex package feed
RUN echo "deb https://feeds.toradex.com/debian/ testing main non-free" >> /etc/apt/sources.list
RUN echo "Package: *\nPin: origin feeds.toradex.com\nPin-Priority: 900" > /etc/apt/preferences.d/toradex-feeds
RUN wget -P /etc/apt/trusted.gpg.d https://feeds.toradex.com/debian/toradex-debian-repo.gpg

# Apply eventual upgrades to installed packages
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ENV LC_ALL C.UTF-8
