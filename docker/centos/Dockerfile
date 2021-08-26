ARG BUILDER_IMAGE=neubauergroup/centos-build-base:3.8.11
FROM ${BUILDER_IMAGE} as builder

USER root
WORKDIR /

SHELL [ "/bin/bash", "-c" ]

# CMake provided by base image
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
      bash-completion-extras \
      wget \
      ghostscript \
      git && \
    yum clean all && \
    yum autoremove -y

# Install HepMC
ARG HEPMC_VERSION=2.06.11
RUN mkdir /code && \
    cd /code && \
    wget http://hepmc.web.cern.ch/hepmc/releases/hepmc${HEPMC_VERSION}.tgz && \
    tar xvfz hepmc${HEPMC_VERSION}.tgz && \
    mv HepMC-${HEPMC_VERSION} src && \
    cmake \
      -DCMAKE_CXX_COMPILER=$(command -v g++) \
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
    export CXX=$(command -v g++) && \
    export PYTHON=$(command -v python3) && \
    export PYTHON_CONFIG=$(find /usr/local/ -iname "python-config.py") && \
    ./configure \
      --prefix=/usr/local/venv \
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
    export CXX=$(command -v g++) && \
    export PYTHON=$(command -v python3) && \
    ./configure \
      --prefix=/usr/local/venv && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install PYTHIA
ARG PYTHIA_VERSION=8243
# PYTHON_VERSION already exists in the base image
# CentOS 7 gcc v4.8.5 is old enough need to specify -std=c++11
RUN mkdir /code && \
    cd /code && \
    wget "https://pythia.org/download/pythia${PYTHIA_VERSION:0:2}/pythia${PYTHIA_VERSION}.tgz" && \
    tar xvfz pythia${PYTHIA_VERSION}.tgz && \
    cd pythia${PYTHIA_VERSION} && \
    ./configure --help && \
    export PYTHON_MINOR_VERSION=${PYTHON_VERSION::-3} && \
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
      --cxx-common="-O2 -m64 -pedantic -W -Wall -Wshadow -fPIC -std=c++11" \
      --cxx-shared="-shared -std=c++11" && \
    make -j$(($(nproc) - 1)) && \
    make install && \
    rm -rf /code

# Install BOOST
# c.f. https://www.boost.org/doc/libs/1_76_0/more/getting_started/unix-variants.html
ARG BOOST_VERSION=1.76.0
# hadolint ignore=SC2046
RUN mkdir -p /code && \
    cd /code && \
    BOOST_VERSION_UNDERSCORE="${BOOST_VERSION//\./_}" && \
    curl --silent --location --remote-name "https://boostorg.jfrog.io/artifactory/main/release/${BOOST_VERSION}/source/boost_${BOOST_VERSION_UNDERSCORE}.tar.gz" && \
    tar -xzf "boost_${BOOST_VERSION_UNDERSCORE}.tar.gz" && \
    cd "boost_${BOOST_VERSION_UNDERSCORE}" && \
    source scl_source enable devtoolset-8 && \
    ./bootstrap.sh --help && \
    ./bootstrap.sh \
      --prefix=/usr/local/venv \
      --with-python=$(command -v python3) && \
    ./b2 install -j$(($(nproc) - 1)) && \
    cd / && \
    rm -rf /code

# Install MadGraph5_aMC@NLO for Python 3 and PYTHIA 8 interface
ARG MG_VERSION=3.2.0
RUN cd /usr/local/venv && \
    wget --quiet https://launchpad.net/mg5amcnlo/3.0/3.1.x/+download/MG5_aMC_v${MG_VERSION}.tar.gz && \
    mkdir -p /usr/local/venv/MG5_aMC && \
    tar -xzvf MG5_aMC_v${MG_VERSION}.tar.gz --strip=1 --directory=MG5_aMC && \
    rm MG5_aMC_v${MG_VERSION}.tar.gz && \
    echo "Installing MG5aMC_PY8_interface" && \
    mkdir /code && \
    cd /code && \
    wget --quiet http://madgraph.phys.ucl.ac.be/Downloads/MG5aMC_PY8_interface/MG5aMC_PY8_interface_V1.0.tar.gz && \
    mkdir -p /code/MG5aMC_PY8_interface && \
    tar -xzvf MG5aMC_PY8_interface_V1.0.tar.gz --directory=MG5aMC_PY8_interface && \
    cd MG5aMC_PY8_interface && \
    python compile.py /usr/local/venv/ --pythia8_makefile && \
    mkdir -p /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface && \
    cp *.h /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp *_VERSION_ON_INSTALL /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    cp MG5aMC_PY8_interface /usr/local/venv/MG5_aMC/HEPTools/MG5aMC_PY8_interface/ && \
    rm -rf /code

# Change the MadGraph5_aMC@NLO configuration settings
RUN sed -i '/fastjet =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/lhapdf_py3 =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# pythia8_path.*|pythia8_path = /usr/local/venv|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i '/mg5amc_py8_interface_path =/s/^# //g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt && \
    sed -i 's|# eps_viewer.*|eps_viewer = '$(command -v ghostscript)'|g' /usr/local/venv/MG5_aMC/input/mg5_configuration.txt

# Create non-root user "docker"
RUN useradd --shell /bin/bash -m docker && \
   cp /root/.bashrc /home/docker/ && \
   mkdir /home/docker/data && \
   chown -R --from=root docker /home/docker && \
   chown -R --from=root docker /usr/local/venv && \
   chown -R --from=503 docker /usr/local/venv/MG5_aMC

# Use en_US.utf8 locale to avoid issues with ASCII encoding
# as C.UTF-8 not available on CentOS 7
ENV LC_ALL=en_US.utf8
ENV LANG=en_US.utf8

ENV HOME /home/docker
WORKDIR ${HOME}/data

ENV PYTHONPATH=/usr/local/venv/MG5_aMC:/usr/local/venv/lib:${PYTHONPATH}
ENV LD_LIBRARY_PATH=/usr/local/venv/lib:$LD_LIBRARY_PATH
ENV PATH=${HOME}/.local/bin:/root/.local/bin:$PATH
ENV PATH=/usr/local/venv/MG5_aMC/bin:$PATH

RUN if [ -f /root/.profile ];then cp /root/.profile ${HOME}/.profile;fi && \
    cp /root/.bashrc ${HOME}/.bashrc && \
    printf "\nsource scl_source enable devtoolset-8\n" >> ${HOME}/.bash_profile && \
    python -m pip --no-cache-dir install --upgrade pip setuptools wheel && \
    python -m pip --no-cache-dir install six numpy && \
    echo "exit" | mg5_aMC && \
    rm py.py

# Default user is root to avoid uid write permission problems with volumes
ENV HOME /root
WORKDIR ${HOME}/data

ENTRYPOINT ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash"]
