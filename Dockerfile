# Base image
FROM ubuntu:16.04
MAINTAINER graphene

ENV LANG=en_US.UTF-8
ENV LC_ALL=zh_CN.UTF-8
RUN \
    apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
        g++ \
        autoconf \
        cmake \
        git \
        libbz2-dev \
        libcurl4-openssl-dev \
        libssl-dev \
        libncurses-dev \
        libboost-thread-dev \
        libboost-iostreams-dev \
        libboost-date-time-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libboost-program-options-dev \
        libboost-chrono-dev \
        libboost-test-dev \
        libboost-context-dev \
        libboost-regex-dev \
        libboost-coroutine-dev \
        libtool \
        doxygen \
        ca-certificates \
        fish \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD . /graphene
WORKDIR /graphene

# Compile
RUN \
    #git submodule update --init --recursive && \
    #mkdir build && cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DGRAPHENE_DISABLE_UNITY_BUILD=ON \
        . && \
    make witness_node cli_wallet && \
    install -s programs/witness_node/witness_node programs/cli_wallet/cli_wallet /usr/local/bin && \ 
    mkdir /etc/graphene && \
    git rev-parse --short HEAD > /etc/graphene/version && \
    cd / && \
    rm -rf /graphene

# Home directory $HOME
WORKDIR /
RUN useradd -s /bin/bash -m -d /var/lib/graphene graphene
ENV HOME /var/lib/graphene
RUN chown graphene:graphene -R /var/lib/graphene

# Volume
VOLUME ["/var/lib/graphene", "/etc/graphene"]

# rpc service:
EXPOSE 8049
# p2p service:
EXPOSE 8050

# default exec/config files
ADD docker/default_config.ini /etc/graphene/config.ini
ADD docker/entry.sh /usr/local/bin/entry.sh
RUN chmod a+x /usr/local/bin/entry.sh

# Make Docker send SIGINT instead of SIGTERM to the daemon
STOPSIGNAL SIGINT

# default execute entry
CMD ["/usr/local/bin/entry.sh"]


