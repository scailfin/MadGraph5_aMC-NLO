#!/bin/bash

set -e
set -u
set -o pipefail

test_image="scailfin/madgraph5-amc-nlo:mg5_amc3.4.0"

docker pull "${test_image}"
docker run \
	--rm \
	-v "${PWD}":"${PWD}" \
	"${test_image}" "cd ${PWD}/tests; bash tests.sh"
tree -L 2 tests/
