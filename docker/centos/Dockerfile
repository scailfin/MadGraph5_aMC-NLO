ARG BUILDER_IMAGE=neubauergroup/centos-python3:3.8.8
FROM ${BUILDER_IMAGE} as builder

USER root
WORKDIR /usr/local

SHELL [ "/bin/bash", "-c" ]

RUN yum update -y && \
    yum install -y \
      gcc \
      gcc-c++ \
      gcc-gfortran \
      make \
      cmake \
      vim \
      zlib \
      zlib-devel \
      bzip2 \
      bzip2-devel \
      rsync \
      bash-completion \
      wget \
      git && \
    yum clean all && \
    yum autoremove -y
