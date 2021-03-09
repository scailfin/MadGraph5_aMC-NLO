#!/bin/bash

set -e
set -u
set -o pipefail

docker pull scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3

docker run \
	--rm \
	-v "${PWD}":"${PWD}" \
	scailfin/madgraph5-amc-nlo:mg5_amc2.9.2-python3 "cd ${PWD}/tests; bash tests.sh"
tree -L 2 tests/
