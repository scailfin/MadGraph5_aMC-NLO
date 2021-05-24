ARG BUILDER_IMAGE=neubauergroup/centos-build-base:latest
FROM ${BUILDER_IMAGE} as builder

USER root
WORKDIR /usr/local

SHELL [ "/bin/bash", "-c" ]

# CentOS 7's version of CMake is too old (v2.8.12) so build CMake from
# source instead
ARG CMAKE_VERSION=3.20.2
RUN yum update -y && \
    yum install -y \
      gcc \
      gcc-c++ \
      gcc-gfortran \
      make \
      vim \
      zlib \
      zlib-devel \
      bzip2 \
      bzip2-devel \
      rsync \
      bash-completion \
      wget \
      which \
      git && \
    yum clean all && \
    yum autoremove -y
