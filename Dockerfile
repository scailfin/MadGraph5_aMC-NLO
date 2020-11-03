ARG BUILDER_IMAGE=python:3.8-slim
FROM ${BUILDER_IMAGE} as builder

USER root
WORKDIR /usr/local

SHELL [ "/bin/bash", "-c" ]

RUN apt-get -qq -y update && \
    apt-get -qq -y install --no-install-recommends \
      gcc \
      g++ \
      gfortran \
      make \
      cmake \
      vim \
      zlibc \
      zlib1g-dev \
      libbz2-dev \
      rsync \
      bash-completion \
      python3-dev \
      wget \
      git && \
    apt-get -y autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Install HepMC
ARG HEPMC_VERSION=2.06.11
RUN mkdir /code && \
    cd /code && \
    wget http://hepmc.web.cern.ch/hepmc/releases/hepmc${HEPMC_VERSION}.tgz && \
    tar xvfz hepmc${HEPMC_VERSION}.tgz && \
    mv HepMC-${HEPMC_VERSION} src && \
    cmake \
      -DCMAKE_CXX_COMPILER=$(which g++) \
      -DCMAKE_BUILD_TYPE=Release \
      -Dbuild_docs:BOOL=OFF \
      -Dmomentum:STRING=MEV \
      -Dlength:STRING=MM \
      -DCMAKE_INSTALL_PREFIX=/usr/local \
      -S src \
      -B build && \
    cmake build -L && \
    cmake --build build -- -j$(($(nproc) - 1)) && \
    cmake --build build --target install && \
    rm -rf /code

# Install FastJet
ARG FASTJET_VERSION=3.3.4
RUN mkdir /code && \
    cd /code && \
    wget http://fastjet.fr/repo/fastjet-${FASTJET_VERSION}.tar.gz && \
    tar xvfz fastjet-${FASTJET_VERSION}.tar.gz && \
    cd fastjet-${FASTJET_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local \
      --enable-pyext=yes && \
    make -j$(($(nproc) - 1)) && \
    make check && \
    make install && \
    rm -rf /code

# Install LHAPDF
ARG LHAPDF_VERSION=6.3.0
RUN mkdir /code && \
    cd /code && \
    wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    tar xvfz LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    cd LHAPDF-${LHAPDF_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8243
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget --quiet http://home.thep.lu.se/~torbjorn/pythia8/pythia${PYTHIA_VERSION}.tgz && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION=${PYTHON_VERSION::-2} && \
    ./configure \
      --prefix=/usr/local \
      --arch=Linux \
      --cxx=g++ \
      --with-gzip \
      --with-hepmc2 \
      --with-lhapdf6 \
      --with-fastjet3 \
      --with-python-bin=/usr/local/bin/ \
      --with-python-lib=/usr/local/lib/python${PYTHON_MINOR_VERSION} \
      --with-python-include=/usr/local/include/python${PYTHON_MINOR_VERSION} && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install MadGraph5_aMC@NLO for Python 3 and PYTHIA 8 interface
ARG MG_VERSION=2.8.2
RUN cd /usr/local && \
    wget --quiet https://launchpad.net/mg5amcnlo/2.0/2.8.x/+download/MG5_aMC_v${MG_VERSION}.tar.gz && \
    tar xzf MG5_aMC_v${MG_VERSION}.tar.gz -C MG5_aMC && \
    rm MG5_aMC_v${MG_VERSION}.tar.gz && \
    echo "Installing MG5aMC_PY8_interface" && \
    mkdir /code && \
    cd /code && \
    wget --quiet http://madgraph.phys.ucl.ac.be/Downloads/MG5aMC_PY8_interface/MG5aMC_PY8_interface_V1.0.tar.gz && \
    mkdir -p /code/MG5aMC_PY8_interface && \
    tar -xf MG5aMC_PY8_interface_V1.0.tar.gz -C MG5aMC_PY8_interface && \
    cd MG5aMC_PY8_interface && \
    python compile.py /usr/local/ --pythia8_makefile && \
    mkdir -p /usr/local/MG5_aMC/HEPTools/MG5aMC_PY8_interface && \
    cp *.h /usr/local/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp *_VERSION_ON_INSTALL /usr/local/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp MG5aMC_PY8_interface /usr/local/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    rm -rf /code

# Change the MadGraph5_aMC@NLO configuration settings
RUN sed -i '/fastjet =/s/^# //g' /usr/local/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/lhapdf_py3 =/s/^# //g' /usr/local/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# pythia8_path.*|pythia8_path = /usr/local|g' /usr/local/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/mg5amc_py8_interface_path =/s/^# //g' /usr/local/MG5_aMC/input/mg5_configuration.txt

# Enable tab completion by uncommenting it from /etc/bash.bashrc
# The relevant lines are those below the phrase "enable bash completion in interactive shells"
RUN export SED_RANGE="$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+1)),$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+7))" && \
    sed -i -e "${SED_RANGE}"' s/^#//' /etc/bash.bashrc && \
    unset SED_RANGE

# Create user "docker"
#RUN useradd -m docker && \
#    cp /root/.bashrc /home/docker/ && \
#    mkdir /home/docker/data && \
#    chown -R --from=root docker /home/docker && \
#    chown -R --from=root docker /usr && \
#    chown -R --from=root docker /usr/local

## Move files someplace
#RUN cp -r /usr/local/MG5_aMC /home/docker/ && \
#    chown -R --from=root docker /home/docker

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV HOME /home/docker
WORKDIR ${HOME}/data
RUN cp /root/.profile ${HOME}/.profile && \
    cp /root/.bashrc ${HOME}/.bashrc && \
    echo "" >> ${HOME}/.bashrc && \
    echo 'export PATH=${HOME}/.local/bin:$PATH' >> ${HOME}/.bashrc && \
    echo 'export PATH=/usr/local/MG5_aMC/bin:$PATH' >> ${HOME}/.bashrc && \
    python -m pip install --upgrade --no-cache-dir pip setuptools wheel && \
    python -m pip install --no-cache-dir six numpy

#ENV USER docker
#USER docker
ENV PYTHONPATH=/usr/local/lib:/usr/local/MG5_aMC:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV PATH ${HOME}/.local/bin:$PATH
ENV PATH /usr/local/MG5_aMC/bin:$PATH

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
