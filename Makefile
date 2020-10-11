default: image

all: image

image:
	docker build . \
	-f Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8303 \
	--build-arg MG_VERSION=2.8.1 \
	-t scailfin/madgraph5-amc-nlo:latest \
	-t scailfin/madgraph5-amc-nlo:2.8.1 \
	-t scailfin/madgraph5-amc-nlo:2.8.1-python3 \
	--compress

test:
	docker build . \
	-f Dockerfile \
	--build-arg BUILDER_IMAGE=python:3.8-slim \
	--build-arg HEPMC_VERSION=2.06.11 \
	--build-arg FASTJET_VERSION=3.3.4 \
	--build-arg LHAPDF_VERSION=6.3.0 \
	--build-arg PYTHIA_VERSION=8303 \
	--build-arg MG_VERSION=2.8.1 \
	-t scailfin/madgraph5-amc-nlo:debug-local
