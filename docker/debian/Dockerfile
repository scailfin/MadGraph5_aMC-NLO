ARG BUILDER_IMAGE=python:3.10-slim-bullseye
FROM ${BUILDER_IMAGE} as base

FROM base as builder

USER root
WORKDIR /

SHELL [ "/bin/bash", "-c" ]

# Set PATH to pickup virtualenv by default
ENV PATH=/usr/local/venv/bin:"${PATH}"
RUN apt-get -qq -y update && \
    apt-get -qq -y install --no-install-recommends \
      gcc \
      g++ \
      gfortran \
      make \
      cmake \
      vim \
      zlib1g \
      zlib1g-dev \
      libbz2-dev \
      rsync \
      bash-completion \
      wget \
      ghostscript \
      bc \
      git && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* && \
    python -m venv /usr/local/venv && \
    . /usr/local/venv/bin/activate && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    python -m pip --no-cache-dir install six numpy && \
    python -m pip list && \
    printf '\nexport PATH=/usr/local/venv/bin:"${PATH}"\n' >> /root/.bashrc

ENV PYTHONPATH=/usr/local/venv/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/venv/lib:$LD_LIBRARY_PATH

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
      -DCMAKE_INSTALL_PREFIX=/usr/local/venv \
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
    export PYTHON=$(command -v python) && \
    export PYTHON_CONFIG=$(find /usr/local/ -iname "python-config.py") && \
    ./configure \
      --prefix=/usr/local/venv \
      --enable-pyext=yes && \
    make -j$(($(nproc) - 1)) && \
    make check && \
    make install && \
    rm -rf /code

# Install LHAPDF
ARG LHAPDF_VERSION=6.5.3
RUN mkdir /code && \
    cd /code && \
    wget https://lhapdf.hepforge.org/downloads/?f=LHAPDF-${LHAPDF_VERSION}.tar.gz -O LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    tar xvfz LHAPDF-${LHAPDF_VERSION}.tar.gz && \
    cd LHAPDF-${LHAPDF_VERSION} && \
    ./configure --help && \
    export CXX=$(which g++) && \
    export PYTHON=$(which python) && \
    ./configure \
      --prefix=/usr/local/venv && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8306
# PYTHON_VERSION already exists in the base image
RUN mkdir /code && \
    cd /code && \
    wget --quiet "https://pythia.org/download/pythia${PYTHIA_VERSION:0:2}/pythia${PYTHIA_VERSION}.tgz" && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION="${PYTHON_VERSION%.*}" && \
    ./configure \
      --prefix=/usr/local/venv \
      --arch=Linux \
      --cxx=g++ \
      --enable-64bit \
      --with-gzip \
      --with-hepmc2=/usr/local/venv \
      --with-lhapdf6=/usr/local/venv \
      --with-fastjet3=/usr/local/venv \
      --with-python-bin=/usr/local/venv/bin/ \
      --with-python-lib=/usr/local/venv/lib/python${PYTHON_MINOR_VERSION} \
      --with-python-include=/usr/local/include/python${PYTHON_MINOR_VERSION} \
      --cxx-common="-O2 -m64 -pedantic -W -Wall -Wshadow -fPIC -std=c++17" \
      --cxx-shared="-shared -std=c++17" && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install MadGraph5_aMC@NLO for Python 3 and PYTHIA 8 interface
ARG MG_VERSION=3.5.0
# Versions viewable on Illinois mirror
# http://madgraph.physics.illinois.edu/Downloads/MG5aMC_PY8_interface/
ARG MG5aMC_PY8_INTERFACE_VERSION=1.3
RUN cd /usr/local/venv && \
    wget --quiet https://launchpad.net/mg5amcnlo/3.0/3.5.x/+download/MG5_aMC_v${MG_VERSION}.tar.gz && \
    mkdir -p /usr/local/venv/MG5_aMC && \
    tar -xzvf MG5_aMC_v${MG_VERSION}.tar.gz --strip=1 --directory=MG5_aMC && \
    rm MG5_aMC_v${MG_VERSION}.tar.gz && \
    echo "Installing MG5aMC_PY8_interface" && \
    mkdir /code && \
    cd /code && \
    wget --quiet http://madgraph.phys.ucl.ac.be/Downloads/MG5aMC_PY8_interface/MG5aMC_PY8_interface_V${MG5aMC_PY8_INTERFACE_VERSION}.tar.gz && \
    mkdir -p /code/MG5aMC_PY8_interface && \
    tar -xzvf MG5aMC_PY8_interface_V${MG5aMC_PY8_INTERFACE_VERSION}.tar.gz --directory=MG5aMC_PY8_interface && \
    cd MG5aMC_PY8_interface && \
    python compile.py /usr/local/venv/ --pythia8_makefile $(find /usr/local/ -type d -name MG5_aMC) && \
    mkdir -p /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface && \
    cp *.h /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp *_VERSION_ON_INSTALL /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp MG5aMC_PY8_interface /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    rm -rf /code && \
    printf '\nexport PATH=/usr/local/venv/MG5_aMC/bin:"${PATH}"\n' >> /root/.bashrc

# Change the MadGraph5_aMC@NLO configuration settings
RUN sed -i '/fastjet =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/lhapdf_py3 =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# pythia8_path.*|pythia8_path = /usr/local/venv|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/mg5amc_py8_interface_path =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# eps_viewer.*|eps_viewer = '$(command -v ghostscript)'|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# fortran_compiler.*|fortran_compiler = '$(command -v gfortran)'|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# f2py_compiler_py3.*|f2py_compiler_py3 = '$(command -v f2py)'|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt

FROM base

USER root

SHELL [ "/bin/bash", "-c" ]

# Enable tab completion by uncommenting it from /etc/bash.bashrc
# The relevant lines are those below the phrase "enable bash completion in interactive shells"
RUN export SED_RANGE="$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+1)),$(($(sed -n '\|enable bash completion in interactive shells|=' /etc/bash.bashrc)+7))" && \
    sed -i -e "${SED_RANGE}"' s/^#//' /etc/bash.bashrc && \
    unset SED_RANGE

RUN apt-get -qq -y update && \
    apt-get -qq -y install --no-install-recommends \
      gcc \
      g++ \
      gfortran \
      make \
      cmake \
      vim \
      zlib1g \
      zlib1g-dev \
      libbz2-dev \
      rsync \
      bash-completion \
      wget \
      curl \
      ghostscript \
      bc \
      git && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user "moby" with uid 1000
RUN adduser \
      --shell /bin/bash \
      --gecos "default user" \
      --uid 1000 \
      --disabled-password \
      moby && \
    chown -R moby /home/moby && \
    mkdir -p /home/moby/work && \
    chown -R moby /home/moby/work && \
    mkdir /work && \
    chown -R moby /work && \
    mkdir /docker && \
    chown -R moby /docker && \
    printf '\nexport PATH=/usr/local/venv/bin:"${PATH}"\n' >> /root/.bashrc && \
    printf '\nexport PATH=/usr/local/venv/MG5_aMC/bin:"${PATH}"\n' >> /root/.bashrc && \
    cp /root/.bashrc /etc/.bashrc && \
    echo 'if [ -f /etc/.bashrc ]; then . /etc/.bashrc; fi' >> /etc/profile && \
    echo "SHELL=/bin/bash" >> /etc/environment

USER moby

ENV USER ${USER}
ENV HOME /home/moby
WORKDIR ${HOME}/work

COPY --from=builder --chown=moby /usr/local/venv /usr/local/venv/

# Use C.UTF-8 locale to avoid issues with ASCII encoding
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

ENV PATH=${HOME}/.local/bin:/usr/local/venv/bin:"${PATH}"
ENV PATH=/usr/local/venv/MG5_aMC/bin:$PATH
ENV PYTHONPATH=/usr/local/venv/lib:$PYTHONPATH
ENV LD_LIBRARY_PATH=/usr/local/venv/lib:$LD_LIBRARY_PATH

# TODO: Install NLO dependencies independently for greater control
# Running the NLO process forces install of cuttools and iregi
RUN cp /etc/profile ${HOME}/.profile && \
    printf '\nexport PATH=/usr/local/venv/bin:"${PATH}"\n' >> "${HOME}"/.bashrc && \
    printf '\nexport PATH=/usr/local/venv/MG5_aMC/bin:"${PATH}"\n' >> "${HOME}"/.bashrc && \
    echo "exit" | mg5_aMC && \
    echo "install ninja" | mg5_aMC && \
    echo "install collier" | mg5_aMC && \
    echo "generate p p > e+ e- aEW=2 aS=0 [QCD]; output test_nlo" | mg5_aMC && \
    rm -rf test_nlo && \
    rm -rf $(find /usr/local/ -type d -name HEPToolsInstallers) && \
    rm py.py

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
