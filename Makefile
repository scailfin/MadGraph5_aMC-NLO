default: image

all: image

image:
	docker build . \
	-f docker/Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8243 \
	--build-arg MG_VERSION=3.1.0 \
	-t scailfin/madgraph5-amc-nlo:latest \
	-t scailfin/madgraph5-amc-nlo:3.1.0 \
	-t scailfin/madgraph5-amc-nlo:3.1.0-python3 \
	--compress

test:
	docker build . \
	-f docker/Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8243 \
	--build-arg MG_VERSION=3.1.0 \
	-t scailfin/madgraph5-amc-nlo:debug-local

base-centos:
	docker build . \
	-f docker/centos/Dockerfile \
	--build-arg BUILDER_IMAGE=neubauergroup/centos-build-base:latest \
	-t tmp/madgraph5-amc-nlo-centos-base:debug-local

test-centos: base-centos
	docker build . \
	-f docker/Dockerfile \
	--build-arg BUILDER_IMAGE=tmp/madgraph5-amc-nlo-centos-base:debug-local \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8243 \
	--build-arg MG_VERSION=3.1.0 \
	-t scailfin/madgraph5-amc-nlo:debug-local-centos
