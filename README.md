# MadGraph5_aMC-NLO Python 3 Docker Image

Docker image for Python 3 compliant [MadGraph5_aMC@NLO](https://launchpad.net/mg5amcnlo).

[![Docker Images](https://github.com/scailfin/MadGraph5_aMC-NLO/actions/workflows/docker-debian.yml/badge.svg?branch=main)](https://github.com/scailfin/MadGraph5_aMC-NLO/actions/workflows/docker-debian.yml?query=branch%3Amain)
[![Docker Pulls](https://img.shields.io/docker/pulls/scailfin/madgraph5-amc-nlo)](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/scailfin/madgraph5-amc-nlo/latest)](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo/tags?name=latest)

## Distributed Software

The Docker image contains:

* [MadGraph5_aMC@NLO](https://launchpad.net/mg5amcnlo) `v3.1.0`
* Python 3.8
* [HepMC2](http://hepmc.web.cern.ch/hepmc/) `v2.06.11`
* [LHAPDF](https://lhapdf.hepforge.org/) `v6.3.0`
* [FastJet](http://fastjet.fr/) `v3.3.4`
* [PYTHIA](http://home.thep.lu.se/~torbjorn/Pythia.html) `v8.243`

## Installation

- Check the [list of available tags on Docker Hub](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo/tags?page=1) to find the tag you want.
- Use `docker pull` to pull down the image corresponding to the tag. For example:

```
docker pull scailfin/madgraph5-amc-nlo:mg5_amc3.1.0
```

## Use

MadGraph5_aMC@NLO is in `PATH` when the container starts

```
docker run --rm scailfin/madgraph5-amc-nlo:mg5_amc3.1.0 "mg5_aMC --help"
Usage: mg5_aMC [options] [FILE]

Options:
  -h, --help            show this help message and exit
  -l LOGGING, --logging=LOGGING
                        logging level (DEBUG|INFO|WARNING|ERROR|CRITICAL)
                        [INFO]
  -f FILE, --file=FILE  Use script file FILE
  -d MGME_DIR, --mgme_dir=MGME_DIR
                        Use MG_ME directory MGME_DIR
  --web                 force to be in secure mode
  --debug               force to launch debug mode
  -m PLUGIN, --mode=PLUGIN
                        Define some additional command provide by a PLUGIN
  -s, --nocaffeinate    For mac user, forbids to use caffeinate when running
                        with a script
```

so you should be able to make any directory inside the container a working directory and run `mg5_aMC` commands from there.

If you run the image as an interactive container with your local path bind mounted to the working directory

```shell
docker run --rm -ti -v $PWD:$PWD -w $PWD scailfin/madgraph5-amc-nlo:mg5_amc3.1.0
```

output from your work in that directory in the interactive session will be preserved when the container exists.

The container can be used a runtime application by passing in a MadGraph program as a `.mg5` file to the `mg5_aMC` CLI API

```shell
docker run --rm -v $PWD:$PWD -w $PWD scailfin/madgraph5-amc-nlo:mg5_amc3.1.0 "mg5_aMC file-name.mg5"
```

For further examples see the tests.

## Tests

As an example test you can run the [top mass scan example](https://answers.launchpad.net/mg5amcnlo/+faq/2186) in the `tests` directory inside the Docker container by running the following from the top level directory of this repository

```shell
docker run --rm -v $PWD:$PWD scailfin/madgraph5-amc-nlo:mg5_amc3.1.0 "cd ${PWD}/tests; bash tests.sh"
```

or run the test runner

```shell
bash test_runner.sh
```
