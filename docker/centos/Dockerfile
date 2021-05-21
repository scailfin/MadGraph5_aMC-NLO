ARG BUILDER_IMAGE=neubauergroup/centos-python3:3.8.8
FROM ${BUILDER_IMAGE} as builder

USER root
WORKDIR /usr/local

SHELL [ "/bin/bash", "-c" ]

RUN yum update -y && \
    yum install
      gcc \
      gcc-c++ \
      gcc-gfortran \
      make \
      cmake \
      vim \
    apt-get -qq -y install --no-install-recommends \
      zlibc \
      zlib1g-dev \
      libbz2-dev \
      rsync \
      bash-completion \
      python3-dev \
      wget \
      git && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*
