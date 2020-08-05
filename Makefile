default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8302 \
	--build-arg MG_VERSION=2.7.0 \
	-t matthewfeickert/madgraph5-amc-nlo:latest \
	-t matthewfeickert/madgraph5-amc-nlo:2.7.0 \
	-t matthewfeickert/madgraph5-amc-nlo:2.7.0-python3 \
	--compress

test:
	docker build . \
	-f Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8302 \
	--build-arg MG_VERSION=2.7.0 \
	-t matthewfeickert/madgraph5-amc-nlo:debug-local
