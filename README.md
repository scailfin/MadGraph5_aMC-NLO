# MadGraph5_aMC-NLO Python 3 Docker Image

Docker image for Python 3 compliant [MadGraph5_aMC@NLO](https://launchpad.net/mg5amcnlo).

[![GitHub Actions Status: CI](https://github.com/scailfin/MadGraph5_aMC-NLO/workflows/CI/badge.svg?branch=master)](https://github.com/scailfin/MadGraph5_aMC-NLO/actions?query=workflow%3ACI+branch%3Amaster)
[![Docker Pulls](https://img.shields.io/docker/pulls/scailfin/madgraph5-amc-nlo)](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/scailfin/madgraph5-amc-nlo/latest)](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo/tags?name=latest)

## Distributed Software

The Docker image contains:

* [MadGraph5_aMC@NLO](https://launchpad.net/mg5amcnlo) `v2.9.2`
* Python 3.8
* [HepMC2](http://hepmc.web.cern.ch/hepmc/) `v2.06.11`
* [LHAPDF](https://lhapdf.hepforge.org/) `v6.3.0`
* [FastJet](http://fastjet.fr/) `v3.3.4`
* [PYTHIA](http://home.thep.lu.se/~torbjorn/Pythia.html) `v8.243`

## Installation

- Check the [list of available tags on Docker Hub](https://hub.docker.com/r/scailfin/madgraph5-amc-nlo/tags?page=1) to find the tag you want.
- Use `docker pull` to pull down the image corresponding to the tag. For example:

```
docker pull scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3
```

## Use

MadGraph5_aMC@NLO is in `PATH` when the container starts

```shell
docker run --rm scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3 "mg5_aMC --help"
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

so you should be able to make any directory inside the container a working directory and run `mg5_aMC` commands.

When run as a container the

If you run the image as an interactive container

```shell
docker run --rm -ti scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3
```

you'll be dropped into the container at `/home/docker/data`

## Tests

As an example test you can run the [top mass scan example](https://answers.launchpad.net/mg5amcnlo/+faq/2186) in the `tests` directory inside the Docker container by running the following from the top level directory of this repository

```shell
docker run --rm -v $PWD:$PWD scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3 "cd ${PWD}/tests; bash tests.sh"
```

or run the test runner

```shell
bash test_runner.sh
```
